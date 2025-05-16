import sys
import os

def find_palette_matches(stage_file, master_file):
    # Read binary data
    with open(stage_file, "rb") as f:
        stage_data = f.read()
    with open(master_file, "rb") as f:
        master_data = f.read()

    palette_size = 16 * 3  # 48 bytes per palette

    # Validate input sizes
    if len(stage_data) % palette_size != 0:
        print(f"Warning: {stage_file} size is not a multiple of {palette_size} bytes.")
    if len(master_data) % palette_size != 0:
        print(f"Warning: {master_file} size is not a multiple of {palette_size} bytes.")

    # Split into palette chunks
    stage_palettes = [stage_data[i:i + palette_size] for i in range(0, len(stage_data), palette_size)]
    master_palettes = [master_data[i:i + palette_size] for i in range(0, len(master_data), palette_size)]

    results = []

    for src_idx, stage_chunk in enumerate(stage_palettes):
        match_idx = None
        for m_idx, master_chunk in enumerate(master_palettes):
            if stage_chunk == master_chunk:
                match_idx = m_idx
                break
        if match_idx is not None:
            results.append(f"P{src_idx}={match_idx}")
        else:
            results.append(f"P{src_idx}=NM")

    print(" ".join(results))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python find_palette_matches.py <stagepalette.bin> <masterpalette.bin>")
        sys.exit(1)
    stage_file = sys.argv[1]
    master_file = sys.argv[2]
    if not os.path.exists(stage_file) or not os.path.exists(master_file):
        print("Error: One or both files do not exist.")
        sys.exit(1)
    find_palette_matches(stage_file, master_file)
