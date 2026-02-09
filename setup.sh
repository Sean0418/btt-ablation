#!/bin/bash

# Windows Long Paths Fix
if [[ "$OSTYPE" == "msys" ]]; then
    VAL=$(powershell -Command "(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem').LongPathsEnabled" 2>/dev/null)
    if [ "$VAL" != "1" ]; then
        echo ">> Enabling Windows Long Paths (Admin required)..."
        powershell -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-Command Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 1 -Force'"
        echo ">> REBOOT REQUIRED. Please restart your computer."
        exit 1
    fi
fi

# Detect Conda
if command -v module &> /dev/null; then
    module purge
    module load anaconda 2>/dev/null || module load python/3.10
    CONDA_EXE="conda"
elif [ -f "/c/A3Program/Scripts/conda.exe" ]; then
    CONDA_EXE="/c/A3Program/Scripts/conda.exe"
else
    CONDA_EXE="conda"
fi

set -e

# 1. Create Environment
echo "--- Creating Conda environment in ./env ---"
"$CONDA_EXE" create --prefix ./env python=3.10 -y

export PYTHONNOUSERSITE=1

# 2. Find the new Python executable
if [ -f "./env/python.exe" ]; then
    PYTHON_EXEC="$(pwd)/env/python.exe"
else
    PYTHON_EXEC="$(pwd)/env/bin/python"
fi

echo "--- Upgrading pip ---"
"$PYTHON_EXEC" -m pip install --upgrade pip

# 3. Install PyTorch (Forcing CUDA 12.6)
echo "--- Installing PyTorch with CUDA support ---"
"$PYTHON_EXEC" -m pip install \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu126

# 4. Install from requirements.txt
if [ -f "requirements.txt" ]; then
    echo "--- Installing dependencies from requirements.txt ---"
    "$PYTHON_EXEC" -m pip install -r requirements.txt
else
    echo "ERROR: requirements.txt not found!"
    exit 1
fi

echo
echo "--- Setup Complete! ---"
echo "To activate: conda activate ./env"