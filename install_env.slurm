#!/bin/bash
#SBATCH -N 1
#SBATCH --job-name=install_env
#SBATCH --output=install_log_%j.out
#SBATCH --error=install_log_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=general

# Ensure the script runs in the directory where you submitted it
cd $SLURM_SUBMIT_DIR

# Create the logs folder if it does not exist
mkdir -p logs

# Make the setup script executable
chmod +x setup.sh

# Execute the setup script
./setup.sh

