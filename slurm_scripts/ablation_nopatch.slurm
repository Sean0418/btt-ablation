#!/bin/bash
#SBATCH --job-name=nopatch
#SBATCH --output=logs/nopatch_2.out
#SBATCH --error=logs/nopatch_2.err
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=volta-gpu
#SBATCH --qos=gpu_access
#SBATCH --gres=gpu:1
#SBATCH --time=4:00:00

cd $SLURM_SUBMIT_DIR

mkdir -p logs

echo "Starting No Patch Ablation Study"

./env/bin/python ablation/train_model.py ablation/rnn_args_nopatch.yaml

echo "Job Complete."