#!/bin/bash
#SBATCH --job-name=patch25_4
#SBATCH --output=logs/patch25_4_2.out
#SBATCH --error=logs/patch25_4_2.err
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=volta-gpu
#SBATCH --qos=gpu_access
#SBATCH --gres=gpu:1
#SBATCH --time=5:00:00
#SBATCH --mail-type=begin,end,fail
#SBATCH --mail-user=sjshen@email.unc.edu

cd $SLURM_SUBMIT_DIR

mkdir -p logs

echo "Starting Patch25_4 Ablation Study"

./env/bin/python ablation/train_model.py ablation/rnn_args_patch25_4.yaml

echo "Job Complete."