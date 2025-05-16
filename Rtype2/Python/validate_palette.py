import os
import sys

# Function to validate each color component (5-bit RGB)
def validate_palette(input_file):
    try:
        with open(input_file, "rb") as infile:
            data = infile.read()
            
            # Each palette contains 16 colors, and each color contains 3 bytes (RGB)
            colors_per_palette = 16
            bytes_per_palette = 48  # 16 colors * 3 bytes each = 48 bytes per palette

            # Calculate the number of palettes in the file
            total_palettes = len(data) // bytes_per_palette

            if len(data) % bytes_per_palette != 0:
                print("Warning: The input file size is not a perfect multiple of the expected palette size. Some data may be missing or incomplete.")

            print(f"The file contains {total_palettes} palettes of 16 colors each.")

            valid_count = 0
            invalid_count = 0

            # Loop through each palette
            for palette_index in range(total_palettes):
                palette_start = palette_index * bytes_per_palette  # Start of the current palette
                for color_index in range(0, bytes_per_palette, 3):  # Each color is 3 bytes (RGB)
                    red = data[palette_start + color_index]
                    green = data[palette_start + color_index + 1]
                    blue = data[palette_start + color_index + 2]

                    # Validate each RGB component to ensure it's within the 5-bit range (0-31)
                    if (0 <= red <= 31) and (0 <= green <= 31) and (0 <= blue <= 31):
                        valid_count += 1
                    else:
                        invalid_count += 1
                        print(f"Invalid color in palette {palette_index + 1}, color {color_index // 3 + 1} (RGB: {red}, {green}, {blue}).")
            
            print(f"\nTotal valid colors: {valid_count}")
            print(f"Total invalid colors: {invalid_count}")

            # Ensure that there are exactly 256 palettes
            if total_palettes != 256:
                print("\nWarning: The input file does not contain exactly 256 palettes.")
            else:
                print("\nPalette validation passed. All colors are within the valid 5-bit range (0-31) for RGB.")

    except FileNotFoundError:
        print(f"Error: The file {input_file} was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

# Main function to handle user input/output
def main():
    if len(sys.argv) != 2:
        print("Usage: python validate_palette.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    validate_palette(input_file)

if __name__ == "__main__":
    main()
