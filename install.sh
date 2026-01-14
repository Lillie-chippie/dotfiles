#!/bin/bash
set -e

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install packages
echo "Installing packages..."
sudo apt-get install -y hyprland waybar hyprpaper wofi nemo wl-clipboard git cmake g++ libdbus-1-dev libwayland-dev libxkbcommon-dev golang

# Install cliphist
echo "Installing cliphist..."
if ! command -v cliphist &> /dev/null; then
  go install go.senan.xyz/cliphist@latest
  # Ensure go bin is in path for the current session or copy it
  sudo cp ~/go/bin/cliphist /usr/local/bin/
else
  echo "cliphist already installed."
fi

# Copy configuration files
echo "Copying configuration files..."
mkdir -p ~/.config
cp -r .config/hypr ~/.config/
cp -r .config/waybar ~/.config/
cp -r .config/wofi ~/.config/

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

echo "Installation complete!"
