#!/bin/bash
#SBATCH --job-name=nodropout
#SBATCH --output=logs/nodropout_4.out
#SBATCH --error=logs/nodropout_4.err
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=volta-gpu
#SBATCH --qos=gpu_access
#SBATCH --gres=gpu:1
#SBATCH --time=00:15:00

cd $SLURM_SUBMIT_DIR

mkdir -p logs

echo "Starting Dryrun"

./env/bin/python ablation/train_model.py ablation/rnn_args_dryrun.yaml

echo "Job Complete."