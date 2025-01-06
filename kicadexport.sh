#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Pull KiCad Docker image
echo "Pulling KiCad Docker image..."
docker pull kicad/kicad:8.0

# Run KiCad Docker container to export files
echo "Exporting schematic, PCB, and 3D model..."
docker run --rm -v "$(pwd):/workspace" kicad/kicad:8.0 bash -c "
  cd /workspace

  # Export schematic
  mkdir -p images
  kicad-cli sch export svg -o 'images/sch.svg' kicad/*.kicad_sch

  # Export PCB
  kicad-cli pcb export svg -o 'images/pcb.svg' --page-size-mode 2 --exclude-drawing-sheet --layers 'F.Cu,F.SilkS,F.Mask' kicad/*.kicad_pcb

  # Export 3D model
  kicad-cli pcb export step --output 'images/board.step' kicad/*.kicad_pcb
  cd ..
"

# Notify the user about completion
echo "Schematic, PCB, and 3D model exported successfully into the 'images' directory."