#!/bin/bash

# Estimate total storage required
total_storage_required="~7.89 GB"

# Inform the user about the installation details and estimated storage usage
echo "This script will install the following components for VoxNovel and will take up approximately $total_storage_required of storage:"
echo "- Nix (if not already installed)"
echo "- Miniconda (if not already installed)"
echo "- Calibre (around 835 MB)"
echo "- Ffmpeg (around 51.8 MB)"
echo "- Git (around 51.5 MB)"
echo "- Espeak-ng (around 12.5 MB)"
echo "- Conda environment 'VoxNovel' (around 4 GB)"
echo "- NLTK data (around 44.9 MB)"
echo "- BookNLP models (around 1.2 GB)"
echo "- Xtts TTS model (around 1.7 GB)"
echo "- VoxNovel.app shortcut (desktop and Applications folder)"

# Prompt user for confirmation
read -p "Do you want to proceed with the installation? (y/n): " confirm

if [[ "$confirm" != "y" ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo "Starting the installation..."







# Install nix
echo "Installing nix..."
bash <(curl -s https://raw.githubusercontent.com/DrewThomasson/WSL-scripts/main/Arch/arch-nix-installer.sh)

# nix activateion manual command is
source ~/.nix-profile/etc/profile.d/nix.sh

echo "Added Nix to Bash profile!"

# Check if Miniconda is installed by checking if conda command is recognized
if ! command -v conda &> /dev/null
then
    echo "Miniconda not found."
    read -p "Would you like to install Miniconda? (y/n): " choice
    
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        echo "Installing Miniconda using the Arch Miniconda installer script..."
        
        # Use the one-liner to download and run the Miniconda installer script from GitHub
        bash <(curl -s https://raw.githubusercontent.com/DrewThomasson/WSL-scripts/main/Arch/arch-miniconda-installer.sh)

        # Initialize conda for bash and zsh (if required)
        if [ -f ~/miniconda3/bin/conda ]; then
            echo "Initializing Conda for bash and zsh..."
            ~/miniconda3/bin/conda init bash
            ~/miniconda3/bin/conda init zsh
        else
            echo "Error: Miniconda installation failed or path incorrect."
            exit 1
        fi
        
        # Source the shell to make conda available in this session
        echo "Reloading shell configuration..."
        source ~/.bash_profile || source ~/.bashrc
        source ~/.zshrc
        
        echo "Miniconda installation completed."
    else
        echo "Miniconda installation skipped. VoxNovel requires Miniconda to run. Exiting install script..."
        exit 1
    fi
else
    echo "Miniconda is already installed."
fi

# Step 5: Initialize Conda for bash and zsh
echo "Initializing Conda..."
~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh

# Step 6: Reload shell configuration
echo "Reloading shell configuration..."
source ~/.bashrc
source ~/.zshrc

echo "listing current existing conda envs"
conda env list


# Create and activate the VoxNovel conda environment
conda create --name VoxNovel python=3.10 -y






#This part will attempt to actiate conda by finding the conda.sh file, so it won't depend on if miniconda is called miniconda3 or miniconda or something else,

# Define potential base directories
BASE_DIRS=("$HOME" "/opt" "/usr/local")

# Initialize a flag to track if Conda was found
CONDA_FOUND=false

# Loop through each base directory and look for conda.sh
for BASE_DIR in "${BASE_DIRS[@]}"; do
    if [ -f "$BASE_DIR/miniconda3/etc/profile.d/conda.sh" ]; then
        source "$BASE_DIR/miniconda3/etc/profile.d/conda.sh"
        CONDA_FOUND=true
        break
    elif [ -f "$BASE_DIR/miniconda/etc/profile.d/conda.sh" ]; then
        source "$BASE_DIR/miniconda/etc/profile.d/conda.sh"
        CONDA_FOUND=true
        break
    elif [ -f "$BASE_DIR/anaconda3/etc/profile.d/conda.sh" ]; then
        source "$BASE_DIR/anaconda3/etc/profile.d/conda.sh"
        CONDA_FOUND=true
        break
    elif [ -f "$BASE_DIR/anaconda/etc/profile.d/conda.sh" ]; then
        source "$BASE_DIR/anaconda/etc/profile.d/conda.sh"
        CONDA_FOUND=true
        break
    fi
done

# Check if Conda was found and sourced
if [ "$CONDA_FOUND" = false ]; then
    echo "Conda initialization script not found. Please ensure Conda is installed."
    exit 1
fi

# Activate the VoxNovel environment
conda activate VoxNovel

# Verify the environment
which python  # This should show the path to the Python executable in the VoxNovel env
python --version  # This should show the Python version in the VoxNovel env








# Clone the VoxNovel repository and navigate to the directory
cd ~
git clone https://github.com/DrewThomasson/VoxNovel.git
cd VoxNovel

# Install necessary Python packages
pip install styletts2 
pip install tts==0.21.3
pip install booknlp==1.0.7.1
pip install bs4
pip install -r Ubuntu_requirements.txt
pip install ebooklib==0.18
pip install epub2txt==0.1.6
pip install pygame==2.6.0
pip install moviepy==1.0.3

# Download Spacy model
pip install spacy
python -m spacy download en_core_web_sm





# This will use the backup of the nltk files instead
echo "Replacing the nltk folder with the nltk folder backup I Pulled from a docker image, just in case the nltk servers ever mess up..."

# Variables
ZIP_URL="https://github.com/DrewThomasson/VoxNovel/blob/main/readme_files/nltk.zip?raw=true"
TARGET_DIR="$HOME/miniconda3/envs/VoxNovel/lib/python3.10/site-packages"
TEMP_DIR=$(mktemp -d)

# Download the zip file
echo "Downloading zip file..."
wget -q -O "$TEMP_DIR/nltk.zip" "$ZIP_URL"

# Extract the zip file
echo "Extracting zip file..."
unzip -q "$TEMP_DIR/nltk.zip" -d "$TEMP_DIR"

# Replace contents
if [ -d "$TEMP_DIR/nltk" ]; then
  echo "Replacing contents..."
  rm -rf "$TARGET_DIR/nltk"
  mv "$TEMP_DIR/nltk" "$TARGET_DIR/"
else
  echo "Error: Downloaded nltk folder not found."
fi

# Clean up
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "NLTK Files Replacement complete."






# This part of the script will pre-download the tos_agreed.txt file so then you don't have to type yes in the terminal when downloading the coqio xtts_v2 model. 
# Get the current user's home directory
USER_HOME=$(eval echo ~${SUDO_USER:-$USER})

# Set the destination directory and file URL
DEST_DIR="$USER_HOME/.local/share/tts/tts_models--multilingual--multi-dataset--xtts_v2"
FILE_URL="https://github.com/DrewThomasson/VoxNovel/raw/main/readme_files/tos_agreed.txt"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Download the file to the destination directory
curl -o "$DEST_DIR/tos_agreed.txt" "$FILE_URL"

echo "File has been saved to $DEST_DIR/tos_agreed.txt"
echo "The tos_agreed.txt file is so that you don't have to tell coqio tts yes when downloading the xtts_v2 model."

echo "VoxNovel Install FINISHED! (You can close out of this window now)"





# Create a Desktop Entry for the VoxNovel app on the Steam Deck
echo "[Desktop Entry]
Version=1.0
Type=Application
Name=VoxNovel
Exec=$HOME/VoxNovel/shell_install_scripts/run/Steam-Deck-Run-VoxNovel.sh
Icon=$HOME/VoxNovel/readme_files/logo.jpeg
Terminal=true
" > $HOME/Desktop/VoxNovel.desktop

# Copy the Desktop Entry to the applications directory
cp $HOME/Desktop/VoxNovel.desktop ~/.local/share/applications

# Make both Desktop Entries executable
chmod +x $HOME/Desktop/VoxNovel.desktop
chmod +x ~/.local/share/applications/VoxNovel.desktop

# Make the Steam Deck run script executable
chmod +x $HOME/VoxNovel/shell_install_scripts/run/Steam-Deck-Run-VoxNovel.sh

# Update the application database (not necessary on Steam Deck but included for consistency)
sudo update-desktop-database



# Print completion message
echo "VoxNovel.app has been successfully placed on your desktop and in the Applications folder."
echo "You can manually delete the dektop shortcut if you want."






#echo "Activating Miniconda in current session..."

# Step 5: Initialize Conda for bash and zsh
#echo "Initializing Conda..."
#~/miniconda3/bin/conda init bash
#~/miniconda3/bin/conda init zsh

# Step 6: Reload shell configuration
#echo "Reloading shell configuration..."
#source ~/.bashrc
#source ~/.zshrc
#conda --version

#echo "Miniconda Activated!"



echo "Displaying installed package versions..."

#calibre --version
#gcc --version
#ffmpeg --version
#git --version
#espeak --version
#unzip -v
#wget --version
#conda --version

#no you have to activate a nix package like this before you can use it
echo '#!/bin/bash

check_package() {
    local package_name=$1
    local version_command=$2

    if command -v $package_name >/dev/null 2>&1; then
        echo "$package_name is installed."
        eval "$version_command"
    else
        echo "$package_name is NOT installed or not in PATH."
        return 1
    fi
}

success=true

check_package "calibre" "calibre --version" || success=false
check_package "ldd" "ldd --version | head -n 1" || success=false
check_package "gcc" "gcc --version | head -n 1" || success=false
check_package "ffmpeg" "ffmpeg -version | head -n 1" || success=false
check_package "git" "git --version" || success=false
check_package "espeak" "espeak --version" || success=false
check_package "unzip" "unzip -v | head -n 1" || success=false
check_package "wget" "wget --version | head -n 1" || success=false

if [ "$success" = true ]; then
    echo "All required packages are installed. Success."
    exit 0
else
    echo "Some required packages are missing. Please install them."
    exit 1
fi
' > /tmp/temp_check.sh && chmod +x /tmp/temp_check.sh && nix-shell -p calibre glibc gcc ffmpeg git espeak unzip wget --run "/tmp/temp_check.sh" && rm /tmp/temp_check.sh







echo "VoxNovel Install FINISHED! (You can close out of this window now)"
