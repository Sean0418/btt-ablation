#!/bin/bash
#SBATCH --job-name=2layer
#SBATCH --output=logs/2layer_1.out
#SBATCH --error=logs/2layer_1.err
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=volta-gpu
#SBATCH --qos=gpu_access
#SBATCH --gres=gpu:1
#SBATCH --time=10:00:00

cd $SLURM_SUBMIT_DIR

mkdir -p logs

echo "Starting 2Layer Ablation Study"

./env/bin/python ablation/train_model.py ablation/rnn_args_2layers.yaml

echo "Job Complete."