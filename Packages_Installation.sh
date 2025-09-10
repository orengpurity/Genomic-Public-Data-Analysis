#!/bin/bash

# Installing tools and packaging for bioinformatics pipeline

# Install Homebrew (package manager for macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to the path
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install SRA Toolkit (for downloading from NCBI)
brew install sratoolkit

# Install FastQC, MultiQC, and fastp
conda install fastqc multiqc fastp

#Done