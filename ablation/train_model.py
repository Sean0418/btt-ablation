import sys
from omegaconf import OmegaConf
from rnn_trainer import BrainToTextDecoder_Trainer

if __name__ == "__main__":
    # Default to your sampled configuration if no argument is provided
    config_file = sys.argv[1] if len(sys.argv) > 1 else "rnn_args.yaml"
    
    print(f"Loading configuration from: {config_file}")
    args = OmegaConf.load(config_file)
    
    trainer = BrainToTextDecoder_Trainer(args)
    
    if args["mode"] == "train":
        metrics = trainer.train()
    elif args["mode"] == "test":
        metrics = trainer.evaluate_test_set()