#!/bin/bash
#SBATCH --job-name=nopatch
#SBATCH --output=logs/nopatch_%j.out
#SBATCH --error=logs/nopatch_%j.err
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --partition=l40-gpu
#SBATCH --qos=gpu_access
#SBATCH --gres=gpu:1
#SBATCH --time=12:00:00

cd $SLURM_SUBMIT_DIR

mkdir -p logs

echo "Starting No Dropout Ablation Study"

./env/bin/python train_model.py rnn_args_nodropout.yaml

echo "Job Complete."