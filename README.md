R-Type & R-Type II Graphics Format Documentation

🎮 Introduction
This document contains technical research and tooling for decoding and visualising the graphics systems used in the arcade games R-Type (1987) and R-Type II (1989), developed by Irem.

These games feature tile-based rendering engines, layered maps, dynamic palettes, and unique memory structures. This project aims to document and preserve the graphics formats used in both games for historical and educational purposes.

🎯 Purpose
- Preserve the technical design of R-Type and R-Type II
- Help researchers understand early arcade graphics pipelines
- Support arcade preservation and emulation efforts
- Offer tools and insights into tilemaps, palettes, and map hierarchies

This work does not include or distribute copyrighted ROM data. Users must supply their own legally obtained ROM dumps to use the tools provided.

🔍 Scope

🕹️ R-Type (1987)
- Background tilemaps decoded from screen RAM
- Character-level and block-level tile structure
- Dynamic palette RAM using 5-bit RGB values
- Reverse-engineered using MAME debugger and memory tools
  
🕹️ R-Type II (1989)
- Enhanced tile system:
  - 8×8 character tiles
  - 2×2 meta tiles (16×16 pixels) stored as 5-byte entries
  - 8×6 blocks (128×96 pixels) built from 2×2 tiles
  - Master maps referencing block indices with flip and palette info
- Palette data stored as aligned 48-byte blocks (16 colours × RGB)
- Python tools reconstruct tilemaps to PNG with optional debugging overlays
  
📦 What's Included
- Python scripts for decoding tile and map data
- Palette validation and matching tools
- Format documentation and layout diagrams
- Example outputs (no original ROM data)

📛 Legal and Licensing
All original trademarks and assets are the property of Irem and its respective rights holders.

This repository does not contain original game ROMs, graphics, sound, or executable code. All findings and tools are only shared for archival, educational, and reverse engineering research.

HOW TO USE?

Inside each of the "R-Type1" and "R-TypeII" folders is a batch file. If you extract the original MAME ROMS relative to this title into this folder, you can execute the batch command.
Note: I only work on Windows, so you should write your command lines or bash scripts for Linux or other systems. The batch file has some REM (comments) about what's passed in the command lines.
The system will generate a large number of PNGS by extracting the relative images/tiles/maps from each game.

The folders PNG and PSD for each have already been produced, which gives example results for those who like to examine them.
PSD is, of course, a Photoshop file. 

