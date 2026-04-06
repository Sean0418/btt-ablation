#!/bin/bash
#SBATCH --job-name=1layer
#SBATCH --output=logs/1layer_2.out
#SBATCH --error=logs/1layer_2.err
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

echo "Starting 1Layer Ablation Study"

./env/bin/python ablation/train_model.py ablation/rnn_args_1layer.yaml

echo "Job Complete."