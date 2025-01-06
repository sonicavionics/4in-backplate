#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e


# Pull KiCad Docker image
echo "Pulling KiCad Docker image..."
docker pull kicad/kicad:8.0

# Set permissions to 777 (use with caution)
echo "Setting directory permissions to 777..."
sudo chmod -R 777 .

# Run KiCad Docker container to export files
echo "Exporting schematic, PCB, and 3D model..."
docker run --rm -v "$(pwd):/workspace" kicad/kicad:8.0 bash -c '
  set -e
  cd /workspace
  mkdir -p images

  # Step 1: Export VRML file from KiCAD
  kicad-cli pcb export vrml --output "images/board.wrl" kicad/*.kicad_pcb

  # Step 2: Install Rayhunter
  echo "Installing Rayhunter..."
  mkdir -p ~/Downloads
  cd ~/Downloads
  sudo apt-get update
  sudo apt-get install -y wget libpng-dev

  wget https://master.dl.sourceforge.net/project/castle-engine/rayhunter/rayhunter-1.3.4-linux-x86_64.tar.gz
  tar xzvf rayhunter-1.3.4-linux-x86_64.tar.gz
  sudo install -m 0755 ~/Downloads/rayhunter/rayhunter /usr/local/bin/rayhunter

  # Step 3: Add lighting effects to VRML file
  cd /workspace/images
  head -1 "board.wrl" > "board.front.wrl"
  cat <<EOF >> "board.front.wrl"
Transform {
    children [
        DirectionalLight {
            on TRUE
            intensity 0.63
            ambientIntensity 0.21
            color 1.0 1.0 1.0
            direction 0.1 -0.1 -1
        }
EOF
  cat "board.wrl" >> "board.front.wrl"
  echo "] }" >> "board.front.wrl"

  # Step 4: Convert to PNG using Rayhunter
  echo "Converting /workspace/images/board.front.wrl to board.png..."
  rayhunter classic 7 \
      4320 4320 \
      "/workspace/images/board.front.wrl" \
      "/workspace/images/board.png" \
      --camera-pos 0 0 6 \
      --camera-dir 0 0 -1 \
      --scene-bg-color 1 1 1

  # Step 5: Clean up
  rm /workspace/images/board.front.wrl
  rm /workspace/images/board.wrl

  echo "Script execution completed."
'
