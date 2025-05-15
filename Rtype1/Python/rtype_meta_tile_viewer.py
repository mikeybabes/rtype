import sys
from PIL import Image, ImageDraw, ImageFont

# Constants
CHAR_WIDTH = 8
CHAR_HEIGHT = 8
CHAR_SIZE = 32  # 4bpp
TILE_BLOCK_WIDTH = 8
TILE_BLOCK_HEIGHT = 6
ENTRIES_PER_BLOCK = TILE_BLOCK_WIDTH * TILE_BLOCK_HEIGHT  # 48
TILE_BLOCK_SIZE = ENTRIES_PER_BLOCK * 3  # 3 bytes per entry

def load_palette(filename):
    with open(filename, "rb") as f:
        data = f.read()
    palettes = []
    for p in range(16):
        pal = []
        for c in range(16):
            r, g, b = data[(p * 48 + c * 3):(p * 48 + c * 3 + 3)]
            pal.append((r, g, b))
        palettes.append(pal)
    return palettes

def decode_character(char_data):
    pixels = []
    for y in range(8):
        row = []
        for x in range(8):
            byte_index = y * 4 + (x // 2)
            val = char_data[byte_index]
            color_index = (val >> 4) if x % 2 == 0 else (val & 0x0F)
            row.append(color_index)
        pixels.append(row)
    return pixels

def draw_block(img, x, y, block_data, char_data, palettes):
    for i in range(ENTRIES_PER_BLOCK):
        entry = block_data[i*3:i*3+3]
        tile_num = (entry[0] | (entry[1] << 8)) & 0x0FFF
        palette_idx = entry[2] & 0x0F

        char_offset = tile_num * CHAR_SIZE
        if char_offset + CHAR_SIZE > len(char_data):
            continue  # skip invalid entries

        char_bytes = char_data[char_offset:char_offset+CHAR_SIZE]
        decoded = decode_character(char_bytes)
        palette = palettes[palette_idx]

        cx = i % TILE_BLOCK_WIDTH
        cy = i // TILE_BLOCK_WIDTH

        px = x + cx * CHAR_WIDTH
        py = y + cy * CHAR_HEIGHT

        for dy in range(CHAR_HEIGHT):
            for dx in range(CHAR_WIDTH):
                color = palette[decoded[dy][dx]]
                img.putpixel((px + dx, py + dy), color)

def render_all_blocks(tile_data, char_data, palettes, output_png, draw_grid=False, tiles_per_row=16):
    total_blocks = len(tile_data) // TILE_BLOCK_SIZE
    rows = (total_blocks + tiles_per_row - 1) // tiles_per_row
    img_width = tiles_per_row * TILE_BLOCK_WIDTH * CHAR_WIDTH
    img_height = rows * TILE_BLOCK_HEIGHT * CHAR_HEIGHT

    img = Image.new("RGB", (img_width, img_height))
    draw = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("arial.ttf", 10)
    except:
        font = ImageFont.load_default()

    for i in range(total_blocks):
        block_x = (i % tiles_per_row) * TILE_BLOCK_WIDTH * CHAR_WIDTH
        block_y = (i // tiles_per_row) * TILE_BLOCK_HEIGHT * CHAR_HEIGHT
        block = tile_data[i*TILE_BLOCK_SIZE : (i+1)*TILE_BLOCK_SIZE]
        draw_block(img, block_x, block_y, block, char_data, palettes)

        if draw_grid:
            draw.rectangle(
                [block_x, block_y, block_x + TILE_BLOCK_WIDTH * CHAR_WIDTH - 1,
                 block_y + TILE_BLOCK_HEIGHT * CHAR_HEIGHT - 1],
                outline=(200, 200, 200)
            )
            draw.text((block_x + 2, block_y + 2), f"{i}", fill=(255, 255, 255), font=font)

    img.save(output_png)
    print(f"Saved {output_png} with {total_blocks} tile blocks.")

def render_single_block(tile_data, char_data, palettes, output_png, block_index, draw_grid=False):
    offset = block_index * TILE_BLOCK_SIZE
    if offset + TILE_BLOCK_SIZE > len(tile_data):
        print(f"❌ Error: block index {block_index} is out of range.")
        return

    block = tile_data[offset:offset + TILE_BLOCK_SIZE]
    width = TILE_BLOCK_WIDTH * CHAR_WIDTH
    height = TILE_BLOCK_HEIGHT * CHAR_HEIGHT

    img = Image.new("RGB", (width, height))
    draw_block(img, 0, 0, block, char_data, palettes)

    if draw_grid:
        draw = ImageDraw.Draw(img)
        try:
            font = ImageFont.truetype("arial.ttf", 10)
        except:
            font = ImageFont.load_default()
        draw.rectangle([0, 0, width - 1, height - 1], outline=(200, 200, 200))
        draw.text((2, 2), f"{block_index}", fill=(255, 255, 255), font=font)

    img.save(output_png)
    print(f"Saved tile block #{block_index} to {output_png}")

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python rtype_meta_tile_viewer.py tiles.bin characters.bin palette.bin [output.png] [--grid] [--tile N]")
        sys.exit(1)

    tile_file = sys.argv[1]
    char_file = sys.argv[2]
    palette_file = sys.argv[3]
    output_file = "rtype_blocks.png"
    draw_grid = False
    tile_index = None

    # Parse remaining arguments
    args = sys.argv[4:]
    i = 0
    while i < len(args):
        arg = args[i]
        if arg == "--grid":
            draw_grid = True
        elif arg == "--tile":
            i += 1
            if i < len(args):
                try:
                    tile_index = int(args[i])
                except ValueError:
                    print("❌ Error: --tile requires a number 0–255.")
                    sys.exit(1)
        elif arg.endswith(".png"):
            output_file = arg
        i += 1

    # Load files
    with open(tile_file, "rb") as f:
        tile_data = f.read()
    with open(char_file, "rb") as f:
        char_data = f.read()
    palettes = load_palette(palette_file)

    if tile_index is not None:
        render_single_block(tile_data, char_data, palettes, output_file, tile_index, draw_grid=draw_grid)
    else:
        render_all_blocks(tile_data, char_data, palettes, output_file, draw_grid=draw_grid)
