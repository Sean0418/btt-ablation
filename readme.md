# Analysis of Architectural Design Choices for Brain-to-Text Decoding

This repository contains the code and the documents for my Master's essay.

This project systematically investigates the architectural components of an intracortical speech decoding pipeline, focusing on the optimization of a recurrent neural network (RNN) backbone. By performing extensive ablation studies, this research evaluates the impact of model depth, width, and temporal processing on decoding performance.


### Key Results
* **Phoneme Error Rate (PER):** 9.68%
* **Identification:** Determined that temporal compression (patching and striding) is the most critical pipeline component, reducing error rate by 11.5%

### Project Documents
To understand the full theoretical background and the systematic ablation studies conducted in this project, please refer to the documents below:
* **Master's Essay**: [View Essay](https://drive.google.com/file/d/1-Ru8DWrHMcM1AaeBZ0eQDpViN0vJi3TG/view?usp=sharing)

* **Defense Slides**: [View Defense Slides](https://drive.google.com/file/d/1tM3sqrhL0X9y46M96j9AMjvXKfDmaWB7/view?usp=sharing)


## Setup and Reproducibility
This project was developed on the UNC Longleaf cluster using NVIDIA Volta GPUs.


### Computational Environment
* **OS**: Linux (HPC Cluster Environment)
* **Hardware**: NVIDIA Volta GPU (V100 or equivalent), 8-core CPU, 16GB+ System RAM
* **Scheduler**: SLURM

### Environment
* **Python:** 3.10
* **Frameworks:** PyTorch, Pandas, Scikit-learn
* **Compute:** NVIDIA GPU with 8+ GB VRAM recommended 

### Installation on Longleaf

This project is configured for a Linux-based HPC environment using the Slurm workload manager. 

1. **Clone the repository** to your work directory on the cluster.
   ```bash
   git clone https://github.com/Sean0418/btt-ablation
   cd btt-attention
   ```
2. **Submit the installation job from the root directory**: 
   ```bash
   sbatch install_env.slurm
   ```

3. **Sample output log for successful installation**: 
    * [install_log.txt](./documents/install_log.txt)



### Usage

1. **Activate the Environment**

    ```bash
    conda activate ./env
    ```

2. **Deactivate When Done**

    ```bash
    conda deactivate
    ```

### Load Data
Navigate to the [NEJM Data Github](https://github.com/Neuroprosthetics-Lab/nejm-brain-to-text/tree/main/data) to find instructions for downloading the correct dataset.

The data directory should appear as follows: 

```
data/
├── hdf5_data_final/       <-- Processed HDF5 neural features
├── sampled_dataset/       <-- Sampled trial data for training
├── doi_10_5061_.../       <-- Raw repository data
└── t15_copyTaskData_description.csv
```

### Pre-trained Model & Weights
The final trained weights are hosted on Zenodo. To use them, you must manually create the `checkpoint` directory in the project root.

1. **Download the files** from [Zenodo](https://doi.org/10.5281/zenodo.20060036).

Your trained_models directory should be arranged as follows after downloading the weights: 

```
ablation/
├── trained_models/
│   └── final/
│       ├── checkpoint/
│       │   ├── args.yaml          <-- Model hyperparameters
│       │   ├── best_checkpoint    <-- Pre-trained weights (~897MB)
│       │   └── val_metrics.pkl    <-- Validation performance logs
│       ├── train_val_trials.json
│       ├── training_log
│       └── training_metrics.csv
└── data_augmentations.py
```

Your root directory structure should appear as follows after setup:

```
.
├── ablation/
│   ├── trained_models/      <-- Pre-trained checkpoints
│   └── data_augmentations.py
├── baseline/                <-- Baseline model configurations
├── data/                    <-- Neural datasets and CSV descriptions
├── documents/               <-- Master's Essay and Presentation PDFs
├── install_env.slurm        <-- Slurm submission script
├── setup.sh                 <-- Environment setup script
└── README.md
```

## Credits
This project builds upon the brain-to-text decoding framework developed by **Card et al. (2024)**.
* **Original Architecture**: Based on the research in *"An Accurate and Rapidly Calibrating Speech Neuroprosthesis"* [Original GitHub Repository](https://github.com/Neuroprosthetics-Lab/nejm-brain-to-text)
* **Research Goal**: This repository contains the systematic ablation studies and architectural optimizations (specifically regarding temporal compression and GRU scaling) detailed in my Master's essay