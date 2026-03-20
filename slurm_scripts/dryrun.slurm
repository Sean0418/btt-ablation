#!/bin/bash
#SBATCH --job-name=dryrun
#SBATCH --output=logs/dryrun.out
#SBATCH --error=logs/dryrun.err
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --partition=gpu
#SBATCH --qos=gpu_access
#SBATCH --gres=gpu:1
#SBATCH --time=00:30:00
#SBATCH --mail-type=begin,end,fail
#SBATCH --mail-user=sjshen@email.unc.edu

cd $SLURM_SUBMIT_DIR

mkdir -p logs

echo "Starting Dryrun Phase One: Training"
./env/bin/python ablation/train_model.py ablation/dryrun_train.yaml

echo "Starting Dryrun Phase Two: Testing"
./env/bin/python ablation/train_model.py ablation/dryrun_test.yaml

echo "Job Complete."