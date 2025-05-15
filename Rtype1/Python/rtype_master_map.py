import sys
from PIL import Image

# Constants
CHAR_WIDTH = 8
CHAR_HEIGHT = 8
CHAR_SIZE = 32  # 4bpp
TILE_BLOCK_WIDTH = 8
TILE_BLOCK_HEIGHT = 6
ENTRIES_PER_BLOCK = TILE_BLOCK_WIDTH * TILE_BLOCK_HEIGHT  # 48
TILE_BLOCK_SIZE = ENTRIES_PER_BLOCK * 3  # 3 bytes per entry
BLOCKS_PER_COLUMN = 5  # fixed map height (top to bottom)

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

def flip_tile(pixels, flip_x=False, flip_y=False):
    if flip_y:
        pixels = pixels[::-1]
    if flip_x:
        pixels = [row[::-1] for row in pixels]
    return pixels

def draw_block(img, x, y, block_data, char_data, palettes, flip_x=False, flip_y=False):
    for i in range(ENTRIES_PER_BLOCK):
        entry = block_data[i*3:i*3+3]
        tile_num = (entry[0] | (entry[1] << 8)) & 0x0FFF
        palette_idx = entry[2] & 0x0F

        char_offset = tile_num * CHAR_SIZE
        if char_offset + CHAR_SIZE > len(char_data):
            continue

        char_bytes = char_data[char_offset:char_offset+CHAR_SIZE]
        decoded = decode_character(char_bytes)
        decoded = flip_tile(decoded, flip_x=flip_x, flip_y=flip_y)

        cx = i % TILE_BLOCK_WIDTH
        cy = i // TILE_BLOCK_WIDTH
        if flip_x:
            cx = TILE_BLOCK_WIDTH - 1 - cx
        if flip_y:
            cy = TILE_BLOCK_HEIGHT - 1 - cy

        px = x + cx * CHAR_WIDTH
        py = y + cy * CHAR_HEIGHT

        palette = palettes[palette_idx]
        for dy in range(CHAR_HEIGHT):
            for dx in range(CHAR_WIDTH):
                color_index = decoded[dy][dx]
                if color_index == 0:
                    rgba = (0, 0, 0, 0)
                else:
                    r, g, b = palette[color_index]
                    rgba = (r, g, b, 255)
                img.putpixel((px + dx, py + dy), rgba)

def load_map_data(filename):
    with open(filename, "rb") as f:
        data = f.read()
    indices = [data[i] for i in range(0, len(data), 2)]
    flags = [data[i+1] for i in range(0, len(data), 2)]
    return indices, flags

def render_map(tile_data, char_data, palettes, map_file, output_file):
    block_indices, block_flags = load_map_data(map_file)
    num_columns = len(block_indices) // BLOCKS_PER_COLUMN

    block_w_px = TILE_BLOCK_WIDTH * CHAR_WIDTH
    block_h_px = TILE_BLOCK_HEIGHT * CHAR_HEIGHT

    img_width = num_columns * block_w_px
    img_height = BLOCKS_PER_COLUMN * block_h_px
    img = Image.new("RGBA", (img_width, img_height), (0, 0, 0, 0))  # transparent by default

    for col in range(num_columns):
        for row in range(BLOCKS_PER_COLUMN):
            idx = col * BLOCKS_PER_COLUMN + row
            if idx >= len(block_indices):
                continue
            block_index = block_indices[idx]
            flag = block_flags[idx]

            offset = block_index * TILE_BLOCK_SIZE
            if offset + TILE_BLOCK_SIZE > len(tile_data):
                continue
            block_data = tile_data[offset:offset + TILE_BLOCK_SIZE]

            px = col * block_w_px
            py = row * block_h_px
            draw_block(
                img, px, py,
                block_data, char_data, palettes,
                flip_x=(flag & 0x40) != 0,
                flip_y=(flag & 0x80) != 0
            )

    img.save(output_file)
    print(f"✅ Saved master map with transparency: {output_file}")

def main():
    if len(sys.argv) != 6:
        print("Usage: python rtype_master_map.py tiles-3bytes-8x6.bin gfx2.bin all-palettes2.pal stage1-map.bin output.png")
        return

    tile_file = sys.argv[1]
    char_file = sys.argv[2]
    pal_file = sys.argv[3]
    map_file = sys.argv[4]
    output_png = sys.argv[5]

    with open(tile_file, "rb") as f:
        tile_data = f.read()
    with open(char_file, "rb") as f:
        char_data = f.read()
    palettes = load_palette(pal_file)

    render_map(tile_data, char_data, palettes, map_file, output_png)

if __name__ == "__main__":
    main()
