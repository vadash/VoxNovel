#!/bin/bash

# Install Homebrew
echo "Installing/updating homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Check if Miniconda is installed by checking if conda command is recognized
if ! command -v conda &> /dev/null
then
    echo "Miniconda not found."
    read -p "Would you like to install Miniconda? (y/n): " choice
    
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        echo "Installing Miniconda..."
        
        # Create directory for Miniconda installation
        mkdir -p ~/miniconda3
        
        # Download Miniconda installer
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/miniconda3/miniconda.sh
        
        # Install Miniconda
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        
        # Remove the installer
        rm ~/miniconda3/miniconda.sh
        
        # Initialize conda for bash and zsh
        ~/miniconda3/bin/conda init bash
        ~/miniconda3/bin/conda init zsh
        
        # Source the shell to make conda available in this session
        source ~/.bash_profile
        source ~/.zshrc
        
        echo "Miniconda installation completed."
    else
        echo "Miniconda installation skipped. VoxNovel requires Miniconda to run. Exiting install script..."
        exit 1
    fi
else
    echo "Miniconda is already installed."
fi


# Install necessary packages with Homebrew
echo "Installing Calibre and ffmpeg"
brew install calibre
brew install ffmpeg
brew install git

# Create and activate the VoxNovel conda environment
conda create --name VoxNovel python=3.10 -y
conda activate VoxNovel

# Clone the VoxNovel repository and navigate to the directory
cd ~
git clone https://github.com/DrewThomasson/VoxNovel.git
cd VoxNovel

# Install Python packages
pip install tensorflow-macos
pip install tensorflow-metal  # Optional for GPU acceleration
pip install styletts2
pip install tts==0.21.3
pip install --no-dependencies booknlp==1.0.7.1
pip install transformers==4.30.0
pip install tensorflow
pip install -r MAC-requirements.txt
pip install ebooklib bs4 epub2txt pygame moviepy spacy

# Download Spacy model
python -m spacy download en_core_web_sm



echo "Grabbing nltk data from backup online in case the nltk servers didnt't work right..."

# Set the target directory
TARGET_DIR="/Users/$(whoami)/nltk_data"

# Create the directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Download the zip file to a temporary location
TEMP_ZIP="/tmp/mac_nltk_data.zip"
curl -L -o "$TEMP_ZIP" "https://huggingface.co/drewThomasson/VoxNovel_WSL_ENV/resolve/main/mac_nltk_data.zip?download=true"

# Unzip the downloaded file to a temporary directory
TEMP_DIR="/tmp/mac_nltk_data"
unzip -o "$TEMP_ZIP" -d "$TEMP_DIR"

# Copy the contents to the target directory, replacing any existing files
cp -R "$TEMP_DIR/nltk_data/"* "$TARGET_DIR/"

# Clean up temporary files
rm -rf "$TEMP_ZIP" "$TEMP_DIR"

echo "nltk_data has been updated in $TARGET_DIR"





# This part of the script will pre-download the tos_agreed.txt file so then you don't have to type yes in the terminal when downloading the coqio xtts_v2 model.
# Get the current user's home directory
USER_HOME=$(eval echo ~${SUDO_USER:-$USER})

# Set the destination directory and file URL
#This dir is also where the xtts model files are stored, so if you ever want to remove them to save any space
DEST_DIR="$USER_HOME/Library/Application Support/tts/tts_models--multilingual--multi-dataset--xtts_v2"
FILE_URL="https://github.com/DrewThomasson/VoxNovel/raw/main/readme_files/tos_agreed.txt"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Download the file to the destination directory
curl -o "$DEST_DIR/tos_agreed.txt" "$FILE_URL"

echo "File has been saved to $DEST_DIR/tos_agreed.txt"
echo "The tos_agreed.txt file is so that you don't have to tell coqio tts yes when downloading the xtts_v2 model."




#This part right here will download the Desktop shortcut to your Desktop and put the shortcut in your Applications folder for easy access!
#!/bin/bash

# Define the URL of the ZIP file
ZIP_URL="https://github.com/DrewThomasson/VoxNovel/raw/main/readme_files/VoxNovel.app.zip"

# Define the destination directories
DESKTOP_DIR="$HOME/Desktop"
APPLICATIONS_DIR="/Applications"

# Define the temporary download location
TEMP_ZIP="$DESKTOP_DIR/VoxNovel.app.zip"

# Download the ZIP file
curl -L -o "$TEMP_ZIP" "$ZIP_URL"

# Unzip the contents to the desktop
unzip -o "$TEMP_ZIP" -d "$DESKTOP_DIR"

# Copy the .app to the Applications folder
cp -R "$DESKTOP_DIR/VoxNovel.app" "$APPLICATIONS_DIR"

# Remove the temporary ZIP file
rm "$TEMP_ZIP"

# Print completion message
echo "VoxNovel.app has been successfully placed on your desktop and in the Applications folder."
echo "You can manually delete the dektop shortcut if you want."







echo "VoxNovel Install FINISHED! (You can close out of this window now)"


