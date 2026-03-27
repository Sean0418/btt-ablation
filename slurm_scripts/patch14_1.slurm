#!/bin/bash
#SBATCH --job-name=patch14_1
#SBATCH --output=logs/patch14_1_1.out
#SBATCH --error=logs/patch14_1_1.err
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=volta-gpu
#SBATCH --qos=gpu_access
#SBATCH --gres=gpu:1
#SBATCH --time=10:00:00
#SBATCH --mail-type=begin,end,fail
#SBATCH --mail-user=sjshen@email.unc.edu

cd $SLURM_SUBMIT_DIR

mkdir -p logs

echo "Starting Patch14_1 Ablation Study"

./env/bin/python ablation/train_model.py ablation/rnn_args_patch14_1.yaml

echo "Job Complete."