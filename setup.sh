#!/bin/bash

# Windows: Enable Long Paths if disabled
if [[ "$OSTYPE" == "msys" ]]; then
    VAL=$(powershell -Command "(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem').LongPathsEnabled" 2>/dev/null)
    if [ "$VAL" != "1" ]; then
        echo ">> Enabling Windows Long Paths (Admin required)..."
        powershell -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-Command Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 1 -Force'"
        echo ">> REBOOT REQUIRED. Please restart your computer."
        exit 1
    fi
fi

# Detect Conda Executable (Bypassing broken scripts)
if command -v module &> /dev/null; then
    # Longleaf Cluster
    module purge
    module load anaconda 2>/dev/null || module load python/3.10
    CONDA_EXE="conda"
elif [ -f "/c/A3Program/Scripts/conda.exe" ]; then
    # Your Laptop (Direct Path)
    CONDA_EXE="/c/A3Program/Scripts/conda.exe"
else
    # Standard Fallback
    CONDA_EXE="conda"
fi

set -e

echo "--- Creating Conda environment in ./env ---"
"$CONDA_EXE" create --prefix ./env python=3.10 -y

export PYTHONNOUSERSITE=1

# Auto-detect Python path (Windows vs Linux)
if [ -f "./env/python.exe" ]; then
    PYTHON_EXEC="$(pwd)/env/python.exe"
else
    PYTHON_EXEC="$(pwd)/env/bin/python"
fi

echo "--- Upgrading pip ---"
"$PYTHON_EXEC" -m pip install --upgrade pip

echo "--- Installing PyTorch ---"
if command -v nvidia-smi &> /dev/null; then
    "$PYTHON_EXEC" -m pip install --force-reinstall --no-cache-dir \
        torch==2.9.0 torchvision==0.24.0 torchaudio==2.9.0 \
        --index-url https://download.pytorch.org/whl/cu126
else
    "$PYTHON_EXEC" -m pip install --force-reinstall --no-cache-dir \
        torch==2.9.0 torchvision==0.24.0 torchaudio==2.9.0 \
        --index-url https://download.pytorch.org/whl/cpu
fi

echo "--- Installing requirements ---"
"$PYTHON_EXEC" -m pip install --force-reinstall --no-cache-dir -r requirements.txt

echo "--- Setup Complete! To activate: conda activate ./env ---"