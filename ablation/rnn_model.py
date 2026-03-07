import torch 
from torch import nn

class GRUDecoder(nn.Module):
    '''
    Defines the GRU decoder

    This class combines day-specific input layers, a GRU, and an output classification layer
    '''
    def __init__(self,
                 neural_dim,
                 n_units,
                 n_days,
                 n_classes,
                 rnn_dropout = 0.0,
                 input_dropout = 0.0,
                 n_layers = 5, 
                 patch_size = 0,
                 patch_stride = 0,
                 use_day_alignment = True, 
                 bidirectional = False
                 pad_remainder = False
                 ):
        '''
        neural_dim  (int)      - number of channels in a single timestep (e.g. 512)
        n_units     (int)      - number of hidden units in each recurrent layer - equal to the size of the hidden state
        n_days      (int)      - number of days in the dataset
        n_classes   (int)      - number of classes 
        rnn_dropout    (float) - percentage of units to droupout during training
        input_dropout (float)  - percentage of input units to dropout during training
        n_layers    (int)      - number of recurrent layers 
        patch_size  (int)      - the number of timesteps to concat on initial input layer - a value of 0 will disable this "input concat" step 
        patch_stride(int)      - the number of timesteps to stride over when concatenating initial input 
        use_day_alignment (bool)     - whether to use day-specific input layers to try to align neural data from different days to the same latent space. If False, then day-specific layers will be bypassed and the model will just learn a single shared input layer.
        bidirectional (bool)  - whether to use a bidirectional RNN architecture. If True, then the model will have separate forward and backward GRU layers and the output of the forward and backward layers will be concatenated before being passed to the output layer. If False, then the model will just have a single unidirectional GRU layer.
        pad_remainder (bool) - whether to pad the remainder of the sequence when using strided inputs.
        '''
        super(GRUDecoder, self).__init__()
        
        self.neural_dim = neural_dim
        self.n_units = n_units
        self.n_classes = n_classes
        self.n_layers = n_layers 
        self.n_days = n_days

        self.rnn_dropout = rnn_dropout
        self.input_dropout = input_dropout
        
        self.patch_size = patch_size
        self.patch_stride = patch_stride
        self.pad_remainder = pad_remainder

        # Parameters for the day-specific input layers
        self.day_layer_activation = nn.Softsign() # basically a shallower tanh 

        # Set weights for day layers to be identity matrices so the model can learn its own day-specific transformations
        
        self.use_day_alignment = use_day_alignment
        self.bidirectional = bidirectional

        if self.use_day_alignment:
            self.day_weights = nn.ParameterList(
                [nn.Parameter(torch.eye(self.neural_dim)) for _ in range(self.n_days)]
            )
            self.day_biases = nn.ParameterList(
                [nn.Parameter(torch.zeros(1, self.neural_dim)) for _ in range(self.n_days)]
            )

        self.day_layer_dropout = nn.Dropout(input_dropout)
        
        self.input_size = self.neural_dim

        if self.pad_remainder and self.patch_size > 0:
            seq_len = x.size(1)
            
            # If the recording is shorter than a single patch
            if seq_len < self.patch_size:
                pad_len = self.patch_size - seq_len
            # If the recording is longer, calculate the missing remainder
            else:
                remainder = (seq_len - self.patch_size) % self.patch_stride
                if remainder > 0:
                    pad_len = self.patch_stride - remainder
                else:
                    pad_len = 0
            
            # Apply zero padding to the end of the temporal dimension
            if pad_len > 0:
                x = torch.nn.functional.pad(x, (0, 0, 0, pad_len), "constant", 0)
        # If we are using "strided inputs", then the input size of the first recurrent layer will actually be in_size * patch_size
        if self.patch_size > 0:
            self.input_size *= self.patch_size

        self.gru = nn.GRU(
            input_size = self.input_size,
            hidden_size = self.n_units,
            num_layers = self.n_layers,
            dropout = self.rnn_dropout, 
            batch_first = True, # The first dim of our input is the batch dim
            bidirectional = self.bidirectional,
        )
        
        # Calculate the proper output dimension for the prediction head
        
        # Set recurrent units to have orthogonal param init and input layers to have xavier init
        for name, param in self.gru.named_parameters():
            if "weight_hh" in name:
                nn.init.orthogonal_(param)
            if "weight_ih" in name:
                nn.init.xavier_uniform_(param)
        
        self.num_directions = 2 if self.bidirectional else 1
        gru_output_dim = self.n_units * self.num_directions

        # Prediciton head. Weight init to xavier
        self.out = nn.Linear(gru_output_dim, self.n_classes)
        nn.init.xavier_uniform_(self.out.weight)

        # Learnable initial hidden states
        self.h0 = nn.Parameter(nn.init.xavier_uniform_(torch.zeros(1, 1, self.n_units)))

    def forward(self, x, day_idx, states = None, return_state = False):
        '''
        x        (tensor)  - batch of examples (trials) of shape: (batch_size, time_series_length, neural_dim)
        day_idx  (tensor)  - tensor which is a list of day indexs corresponding to the day of each example in the batch x. 
        '''

        # Apply day-specific layer to (hopefully) project neural data from the different days to the same latent space
        
        if self.use_day_alignment:
            day_weights = torch.stack([self.day_weights[i] for i in day_idx], dim=0)
            day_biases = torch.cat([self.day_biases[i] for i in day_idx], dim=0).unsqueeze(1)

            x = torch.einsum("btd,bdk->btk", x, day_weights) + day_biases
            x = self.day_layer_activation(x)

        # Apply dropout to the ouput of the day specific layer
        if self.input_dropout > 0:
            x = self.day_layer_dropout(x)

        # (Optionally) Perform input concat operation
        if self.patch_size > 0: 
  
            x = x.unsqueeze(1)                      # [batches, 1, timesteps, feature_dim]
            x = x.permute(0, 3, 1, 2)               # [batches, feature_dim, 1, timesteps]
            
            # Extract patches using unfold (sliding window)
            x_unfold = x.unfold(3, self.patch_size, self.patch_stride)  # [batches, feature_dim, 1, num_patches, patch_size]
            
            # Remove dummy height dimension and rearrange dimensions
            x_unfold = x_unfold.squeeze(2)           # [batches, feature_dum, num_patches, patch_size]
            x_unfold = x_unfold.permute(0, 2, 3, 1)  # [batches, num_patches, patch_size, feature_dim]

            # Flatten last two dimensions (patch_size and features)
            x = x_unfold.reshape(x.size(0), x_unfold.size(1), -1) 
        
        # Determine initial hidden states
        if states is None:
            states = self.h0.expand(self.n_layers * self.num_directions, x.shape[0], self.n_units).contiguous()

        # Pass input through RNN 
        output, hidden_states = self.gru(x, states)

        # Compute logits
        logits = self.out(output)
        
        if return_state:
            return logits, hidden_states
        
        return logits
        

