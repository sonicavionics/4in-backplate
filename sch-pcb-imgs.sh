#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Pull KiCad Docker image
echo "Pulling KiCad Docker image..."
docker pull kicad/kicad:8.0

# Run KiCad Docker container to export files
echo "Exporting schematic, PCB, and 3D model..."
sudo chmod -R 777 .
docker run --rm -v "$(pwd):/workspace" kicad/kicad:8.0 bash -c "
  cd /workspace

  # Export schematic
  mkdir -p images
  kicad-cli sch export svg -o 'images/sch' kicad/*.kicad_sch
  mv images/sch/*.svg images/sch.svg
  rm -r images/sch

  # Export PCB
  kicad-cli pcb export svg -o 'images/pcb.svg' --page-size-mode 2 --exclude-drawing-sheet --layers 'F.Cu,F.SilkS,F.Mask' kicad/*.kicad_pcb
"

# Notify the user about completion
echo "Schematic, PCB, and 3D model exported successfully into the 'images' directory."