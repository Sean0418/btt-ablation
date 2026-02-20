#!/bin/bash
set -e

echo "Starting Ultimate Conda Setup..."

if [ -d "./env" ]; then
    echo "Existing environment detected. Removing to ensure a clean build..."
    rm -rf ./env
fi

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "Windows environment detected."
    
    VAL=$(powershell -Command "(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem').LongPathsEnabled" 2>/dev/null)
    if [ "$VAL" != "1" ]; then
        echo "Enabling Windows Long Paths. Admin required."
        powershell -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-Command Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 1 -Force'"
        echo "Reboot required. Please restart your computer."
        exit 1
    fi
    
    CONDA_EXE="conda"
else
    echo "Linux environment detected. Initializing Longleaf Conda..."
    module purge
    module load anaconda
    
    CONDA_BASE=$(conda info --base 2>/dev/null || echo "/nas/longleaf/rhel9/apps/anaconda/2024.02")
    source "$CONDA_BASE/etc/profile.d/conda.sh"
    CONDA_EXE="conda"
fi

echo "Clearing global caches to prevent segmentation faults..."
"$CONDA_EXE" clean --all --yes
rm -rf ~/.cache/pip

echo "Creating Conda environment in ./env..."
"$CONDA_EXE" create --prefix ./env python=3.10 -y

if [ -f "./env/python.exe" ]; then
    PYTHON_EXEC="$(pwd)/env/python.exe"
else
    PYTHON_EXEC="$(pwd)/env/bin/python"
fi

export PYTHONNOUSERSITE=1

echo "Upgrading pip..."
"$PYTHON_EXEC" -m pip install --upgrade pip

echo "Installing PyTorch..."
"$PYTHON_EXEC" -m pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

echo "Installing requirements..."
if [ -f "requirements.txt" ]; then
    "$PYTHON_EXEC" -m pip install --no-cache-dir -r requirements.txt
else
    echo "Error: requirements.txt not found."
    exit 1
fi

echo "Setup Complete!"