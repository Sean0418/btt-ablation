#!/bin/bash
#SBATCH --job-name=noaug_1
#SBATCH --output=logs/noaug_1.out
#SBATCH --error=logs/noaug_1.err
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=volta-gpu
#SBATCH --qos=gpu_access
#SBATCH --gres=gpu:1
#SBATCH --time=1:00:00
#SBATCH --mail-type=begin,end,fail
#SBATCH --mail-user=sjshen@email.unc.edu

cd $SLURM_SUBMIT_DIR

mkdir -p logs

echo "Starting No Augmentation Ablation Study"

./env/bin/python ablation/train_model.py ablation/rnn_args_noaug.yaml

echo "Job Complete."