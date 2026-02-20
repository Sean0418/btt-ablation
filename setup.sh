#!/bin/bash
set -e

echo "Starting native Longleaf Conda setup..."

# Step 1: Purge all modules to ensure a completely clean slate
module purge

# Step 2: Load the exact university Anaconda module
module load anaconda/2024.02

# Step 3: Source the Conda script using the explicit Longleaf path
source /nas/longleaf/rhel9/apps/anaconda/2024.02/etc/profile.d/conda.sh

# Step 4: Create the environment
echo "Creating Conda environment in ./env..."
conda create --prefix ./env python=3.10 -y

# Step 5: Activate the environment natively
echo "Activating environment..."
conda activate ./env

# Step 6: Install dependencies safely
echo "Upgrading pip..."
pip install --upgrade pip

echo "Installing PyTorch..."
pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

echo "Installing requirements..."
if [ -f "requirements.txt" ]; then
    pip install --no-cache-dir -r requirements.txt
else
    echo "Error: requirements.txt not found."
    exit 1
fi

echo "Setup Complete!"