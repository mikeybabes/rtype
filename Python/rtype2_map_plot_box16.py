import sys
import struct
from PIL import Image

CHAR_WIDTH = 8
CHAR_HEIGHT = 8
CHAR_SIZE = 32
BLOCK_DIM = 4  # 4x4 characters
BLOCK_SIZE = BLOCK_DIM * BLOCK_DIM * 4  # 64 bytes per tile block
BLOCK_PIXEL = BLOCK_DIM * CHAR_WIDTH  # 32 pixels per block

def decode_4bpp_char(char_bytes, flip_x=False, flip_y=False):
    pixels = []
    for y in range(8):
        row = []
        for x in range(8):
            byte_index = y * 4 + (x // 2)
            val = char_bytes[byte_index]
            color = (val >> 4) if x % 2 == 0 else (val & 0x0F)
            row.append(color)
        pixels.append(row)
    if flip_y:
        pixels = pixels[::-1]
    if flip_x:
        pixels = [row[::-1] for row in pixels]
    return pixels

def load_palette(palette_data):
    """
    Load only the first 16 colors from the palette (ignoring others).
    """
    return [tuple(palette_data[i*3:i*3 + 3]) for i in range(16)]  # Load the first 16 colors (3 bytes each)

def draw_tile_color_box(img, x, y, tile_block, char_data, palette_data, palette_usage, flip_x=False, flip_y=False):
    layout = list(range(16))
    if flip_y:
        layout = [
            12, 13, 14, 15,
             8,  9, 10, 11,
             4,  5,  6,  7,
             0,  1,  2,  3
        ]
    if flip_x:
        layout = [r ^ 0x03 for r in layout]  # flip character columns (0↔3, 1↔2)

    for out_i, tile_i in enumerate(layout):
        entry_offset = tile_i * 4
        tile_num = struct.unpack_from("<H", tile_block, entry_offset)[0]
        palette_word = struct.unpack_from("<H", tile_block, entry_offset + 2)[0]
        palette_index = palette_word & 0x0F
        palette = palette_data  # Use the palette passed as parameter (which is the first 16 colors only)

        # Increment the usage count for this palette index
        palette_usage[palette_index] += 1

        # Get the color for the current tile (palette index)
        # We will use the palette index here for "indexed" color mode
        color = palette_index  # The color is represented by its index

        # Draw a color box (square) where the tile would be
        cx = out_i % 4
        cy = out_i // 4
        px = x + cx * CHAR_WIDTH
        py = y + cy * CHAR_HEIGHT

        # Fill the square with the corresponding palette index
        for dy in range(CHAR_HEIGHT):
            for dx in range(CHAR_WIDTH):
                img.putpixel((px + dx, py + dy), color)  # Set the pixel to the palette index

def plot_map(map_data, tiles_data, char_data, palette_data, output_file, max_columns=None, row_height=8, debug_file=None):
    total_words = len(map_data) // 2
    if total_words % row_height != 0:
        print(f"⚠️ Warning: map data not a multiple of {row_height} entries!")

    columns = total_words // row_height
    if max_columns:
        columns = min(columns, max_columns)

    img_width = columns * BLOCK_PIXEL
    img_height = row_height * BLOCK_PIXEL
    img = Image.new("P", (img_width, img_height), 0)  # "P" mode for indexed color image

    # Initialize a dictionary to count palette usage
    palette_usage = {i: 0 for i in range(16)}

    # Create the palette (16 colors)
    palette = []
    for i in range(16):
        r, g, b = palette_data[i]  # Get RGB values for the palette
        palette.extend([r, g, b])  # Add the RGB values to the palette list

    img.putpalette(palette)  # Set the palette for the image

    debug_lines = []

    for col in range(columns):
        for row in range(row_height):
            idx = col * row_height + row
            if idx * 2 >= len(map_data):
                continue

            word = struct.unpack_from("<H", map_data, idx * 2)[0]
            flip_x = bool(word & 0x0001)
            flip_y = bool(word & 0x0002)
            raw_segment = word & 0xFFFC
            tile_offset = ((raw_segment - 0x3000) << 4)

            if debug_file:
                debug_lines.append(
                    f"Col {col:02} Row {row:02} Word=${word:04X} FlipX={flip_x} FlipY={flip_y} → Offset=${tile_offset:05X}"
                )

            if tile_offset < 0 or tile_offset + BLOCK_SIZE > len(tiles_data):
                continue  # skip invalid

            tile_block = tiles_data[tile_offset:tile_offset + BLOCK_SIZE]
            draw_tile_color_box(
                img,
                col * BLOCK_PIXEL,
                row * BLOCK_PIXEL,
                tile_block,
                char_data,
                palette_data,  # Use the first 16 colors only
                palette_usage,  # Track usage of each palette index
                flip_x=flip_x,
                flip_y=flip_y
            )

    img.save(output_file)
    print(f"✅ Map saved to {output_file}")
    print(f"🧱 Columns plotted: {columns}")

    # Output the palette usage summary
    print("\nPalette Usage Summary:")
    for palette_index, count in palette_usage.items():
        if count > 0:
            print(f"Palette {palette_index:X}: {count} times")

    if debug_file:
        with open(debug_file, "w") as f:
            for line in debug_lines:
                f.write(line + "\n")
        print(f"🛠  Debug written to {debug_file}")

if __name__ == "__main__":
    if len(sys.argv) < 6:
        print("Usage: python rtype2_map_plot.py tile_map.bin tiles.bin characters.bin palette.bin output.png [--columns N] [--height N] [--debug debug.txt]")
        sys.exit(1)

    map_file = sys.argv[1]
    tiles_file = sys.argv[2]
    char_file = sys.argv[3]
    pal_file = sys.argv[4]
    output_file = sys.argv[5]

    columns = None
    debug_path = None
    row_height = 8  # default height

    i = 6
    while i < len(sys.argv):
        if sys.argv[i] == "--columns" and i + 1 < len(sys.argv):
            columns = int(sys.argv[i + 1])
            i += 2
        elif sys.argv[i] == "--height" and i + 1 < len(sys.argv):
            row_height = int(sys.argv[i + 1])
            i += 2
        elif sys.argv[i] == "--debug" and i + 1 < len(sys.argv):
            debug_path = sys.argv[i + 1]
            i += 2
        else:
            i += 1

    with open(map_file, "rb") as f: map_data = f.read()
    with open(tiles_file, "rb") as f: tiles_data = f.read()
    with open(char_file, "rb") as f: char_data = f.read()
    with open(pal_file, "rb") as f: palette_data = f.read()

    # Load only the first 16 colors from the palette
    palette_data = load_palette(palette_data)

    plot_map(map_data, tiles_data, char_data, palette_data, output_file, max_columns=columns, row_height=row_height, debug_file=debug_path)
