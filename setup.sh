#!/bin/bash
set -e

echo "Starting unified Conda setup..."

# 1. Operating System Detection
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "Windows environment detected."
    
    # Windows Long Paths Fix
    VAL=$(powershell -Command "(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem').LongPathsEnabled" 2>/dev/null)
    if [ "$VAL" != "1" ]; then
        echo "Enabling Windows Long Paths. Admin required."
        powershell -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-Command Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 1 -Force'"
        echo "Reboot required. Please restart your computer."
        exit 1
    fi
    
    # Locate Windows Conda
    if [ -f "/c/A3Program/Scripts/conda.exe" ]; then
        CONDA_EXE="/c/A3Program/Scripts/conda.exe"
    else
        CONDA_EXE="conda"
    fi
else
    echo "Linux environment detected."
    # Longleaf Module Loading
    if command -v module > /dev/null 2>&1; then
        echo "Loading Longleaf Anaconda module..."
        module purge
        module load anaconda
    fi
    CONDA_EXE="conda"
fi

# 2. Prevent Segmentation Faults
echo "Clearing Conda cache to remove corrupted files..."
"$CONDA_EXE" clean --all --yes

# 3. Create Environment
echo "Creating Conda environment in ./env..."
"$CONDA_EXE" create --prefix ./env python=3.10 -y

# 4. Locate Isolated Python Executable
if [ -f "./env/python.exe" ]; then
    PYTHON_EXEC="$(pwd)/env/python.exe"
else
    PYTHON_EXEC="$(pwd)/env/bin/python"
fi

# 5. Install Dependencies
echo "Upgrading pip..."
"$PYTHON_EXEC" -m pip install --upgrade pip

echo "Installing PyTorch..."
"$PYTHON_EXEC" -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

echo "Installing requirements..."
if [ -f "requirements.txt" ]; then
    "$PYTHON_EXEC" -m pip install -r requirements.txt
else
    echo "Error: requirements.txt not found."
    exit 1
fi

echo "Setup Complete!"