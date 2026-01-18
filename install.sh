#!/bin/bash
set -e

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install packages
echo "Installing packages..."
sudo apt-get install -y waybar hyprpaper wofi nemo kitty wl-clipboard git cmake g++ libdbus-1-dev libwayland-dev libxkbcommon-dev golang \
    ninja-build libgbm-dev libdrm-dev libgl1-mesa-dev libpam0g-dev libpango1.0-dev libinput-dev wayland-protocols libpugixml-dev \
    libjpeg-dev libwebp-dev libmagic-dev librsvg2-dev


# Install cliphist
echo "Installing cliphist..."
if ! command -v cliphist &> /dev/null; then
  BUILD_DIR=$(mktemp -d)
  echo "Building cliphist in $BUILD_DIR..."
  export GOPATH="$BUILD_DIR/go"
  env GOPATH="$BUILD_DIR/go" go install go.senan.xyz/cliphist@latest
  sudo cp "$BUILD_DIR/go/bin/cliphist" /usr/local/bin/
  chmod -R +w "$BUILD_DIR"
  rm -rf "$BUILD_DIR"
  echo "cliphist installed successfully."
else
  echo "cliphist already installed."
fi

# Copy configuration files
echo "Copying configuration files..."
mkdir -p ~/.config
cp -r .config/hypr ~/.config/
cp -r .config/waybar ~/.config/
cp -r .config/wofi ~/.config/
cp -r .config/kitty ~/.config/

# Fix wallpaper path in hyprpaper.conf for the current user
echo "Updating wallpaper path configuration..."
# We use regex to replace whatever file path comes after "preload = " and "wallpaper = ,"
sed -i "s|preload = .*|preload = $HOME/wallpaper/001.jpg|g" ~/.config/hypr/hyprpaper.conf
sed -i "s|wallpaper = ,.*|wallpaper = ,$HOME/wallpaper/001.jpg|g" ~/.config/hypr/hyprpaper.conf



# Install wallpaper
echo "Installing wallpaper..."
mkdir -p ~/wallpaper
cp -r wallpaper/001.jpg ~/wallpaper/

#add rule to disable waybar in plasmashell
systemctl --user mask waybar.service

# Install fonts
echo "Installing fonts..."
mkdir -p ~/.local/share/fonts
for font_archive in additional-assets/*.tar.gz; do
    if [ -f "$font_archive" ]; then
        echo "Extracting $font_archive..."
        tar -xzf "$font_archive" -C ~/.local/share/fonts
    fi
done

# Update font cache
echo "Updating font cache..."
fc-cache -fv

# Compile Hyprland dependencies and tools
echo "Compiling Hyprland ecosystem tools (hypridle, hyprlock)..."

# Helper function to build CMake projects
build_cmake_project() {
    local REPO_URL=$1
    local PROJECT_NAME=$(basename "$REPO_URL" .git)
    
    echo "Building $PROJECT_NAME..."
    git clone --recursive "$REPO_URL"
    cd "$PROJECT_NAME"
    cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
    cmake --build build -j$(nproc)
    sudo cmake --install build
    cd ..
}

HYPR_BUILD_DIR=$(mktemp -d)
cd "$HYPR_BUILD_DIR"


# Main tools
build_cmake_project "https://github.com/hyprwm/hyprgraphics.git"
build_cmake_project "https://github.com/hyprwm/hyprland-protocols.git"
build_cmake_project "https://github.com/hyprwm/hypridle.git"
build_cmake_project "https://github.com/hyprwm/hyprlock.git"

cd - > /dev/null
rm -rf "$HYPR_BUILD_DIR"
echo "Hyprland tools compilation complete."

echo "Installation complete!"
