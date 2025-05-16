from PIL import Image, ImageDraw, ImageFont
import os
import sys

def generate_palette_grids(input_file, output_file, show_number=False, show_block=False, show_grid=False):
    # Read palette data
    with open(input_file, "rb") as f:
        data = f.read()

    colors_per_palette = 16
    bytes_per_color = 3
    bytes_per_palette = colors_per_palette * bytes_per_color
    total_palettes = len(data) // bytes_per_palette

    if total_palettes != 256:
        print(f"Expected 256 palettes, found {total_palettes}.")
        sys.exit(1)

    # Extract palettes
    palettes = []
    for p in range(total_palettes):
        start = p * bytes_per_palette
        palette = []
        for i in range(colors_per_palette):
            offset = start + i * bytes_per_color
            r, g, b = data[offset], data[offset+1], data[offset+2]
            palette.append((r, g, b))
        palettes.append(palette)

    # Image size setup
    img_size = 3840
    block_count = 4
    block_size = img_size // block_count  # 960
    square_size = block_size // colors_per_palette  # 60

    # Font setup
    try:
        font_small = ImageFont.truetype("arial.ttf", 24)
        font_large = ImageFont.truetype("arial.ttf", 48)
    except IOError:
        font_small = ImageFont.load_default()
        font_large = ImageFont.load_default()

    # Create image
    img = Image.new("RGB", (img_size, img_size), "white")
    draw = ImageDraw.Draw(img)

    for block in range(16):  # 4x4 blocks
        block_row = block // 4
        block_col = block % 4
        x_off = block_col * block_size
        y_off = block_row * block_size
        palette_index = block * 16

        # Draw 16x16 color grid
        for row in range(colors_per_palette):
            for col in range(colors_per_palette):
                color = palettes[palette_index + row][col] if col < len(palettes[palette_index + row]) else (0, 0, 0)
                x = x_off + col * square_size
                y = y_off + row * square_size
                draw.rectangle([x, y, x + square_size, y + square_size], fill=color)

                # Display the palette index at the start of each row (index + row)
                if show_number:
                    label = f"{palette_index + row:}"  # Palette index in hex (palette_index + row)
                    text_x = x_off + 8  # Fixed position for text in each row
                    text_y = y_off + row * square_size + 16  # Fixed position inside the row
                    draw.text((text_x, text_y), label, fill="white", font=font_small)

        if show_block:
            block_label = f"Palette {(block+1)}"
            text_size = draw.textbbox((0, 0), block_label, font=font_large)
            text_x = x_off + block_size - text_size[2] - 10
            text_y = y_off + block_size - text_size[3] - 10
            draw.text((text_x, text_y), block_label, fill="white", font=font_large)

    # Draw block grid (4 vertical + 4 horizontal lines)
    if show_grid:
        for i in range(1, block_count):
            pos = i * block_size
            # Vertical line
            draw.line([(pos, 0), (pos, img_size)], fill="white", width=3)
            # Horizontal line
            draw.line([(0, pos), (img_size, pos)], fill="white", width=3)

    # Save image
    img.save(output_file)

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Generate a 3840x3840 palette image from 256 RGB palettes")
    parser.add_argument("input_file", help="Binary palette file (256 palettes * 16 colors * 3 bytes)")
    parser.add_argument("output_file", help="Output PNG filename")
    parser.add_argument("--number", action="store_true", help="Show palette index in top-left of each block")
    parser.add_argument("--block", action="store_true", help="Show block number in bottom-right of each block")
    parser.add_argument("--grid", action="store_true", help="Overlay white lines separating 4x4 block layout")
    args = parser.parse_args()

    generate_palette_grids(args.input_file, args.output_file, args.number, args.block, args.grid)
