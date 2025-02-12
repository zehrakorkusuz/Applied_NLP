#!/bin/bash

# Define variables
CONDA_DIR="/workspace/miniconda"
ENV_NAME="modern-bert"
REQUIREMENTS_FILE="requirements.txt"

# Step 1: Download and install Miniconda
if [ ! -d "$CONDA_DIR" ]; then
    echo "Downloading Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p $CONDA_DIR
    rm miniconda.sh
else
    echo "Miniconda is already installed."
fi

# Step 2: Initialize Conda
export PATH="$CONDA_DIR/bin:$PATH"
eval "$(conda shell.bash hook)"
conda init bash

# Step 3: Create a new Conda environment
if ! conda info --envs | grep -q "$ENV_NAME"; then
    echo "Creating new Conda environment: $ENV_NAME"
    conda create -y -n $ENV_NAME python=3.11
else
    echo "Conda environment $ENV_NAME already exists."
fi

# Step 4: Activate the environment
conda activate $ENV_NAME

# Step 5: Install requirements if the file exists
if [ -f "$REQUIREMENTS_FILE" ]; then
    echo "Installing dependencies from $REQUIREMENTS_FILE..."
    pip install -r $REQUIREMENTS_FILE
else
    echo "Requirements file not found. Skipping dependency installation."
fi

# Step 6: Install IPython kernel for Jupyter support
echo "Installing ipykernel..."
conda install -y ipykernel
python -m ipykernel install --user --name=$ENV_NAME --display-name "Python ($ENV_NAME)"

# Step 7: Finish up
echo "Setup complete. Use 'conda activate $ENV_NAME' to activate the environment."
echo "You can now launch Jupyter Notebook with 'jupyter notebook'."