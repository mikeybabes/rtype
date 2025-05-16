import sys

# Correct MAME-compatible 5-bit to 8-bit upscale
def convert_5bit_to_8bit(value):
    return (value << 3) | (value >> 2)

# Function to process the palette
def process_palette(input_file, output_file):
    try:
        with open(input_file, "rb") as infile, open(output_file, "wb") as outfile:
            data = infile.read()

            if len(data) % 3 != 0:
                print("Error: Input file must contain complete RGB triplets (length % 3 == 0).")
                return

            for i in range(0, len(data), 3):
                r_5, g_5, b_5 = data[i], data[i+1], data[i+2]

                r_8 = convert_5bit_to_8bit(r_5)
                g_8 = convert_5bit_to_8bit(g_5)
                b_8 = convert_5bit_to_8bit(b_5)

                outfile.write(bytes([r_8, g_8, b_8]))

        print(f"✅ Conversion complete: '{output_file}' written.")

    except FileNotFoundError:
        print(f"❌ File not found: {input_file}")
    except Exception as e:
        print(f"❌ An error occurred: {e}")

# Entry point
def main():
    if len(sys.argv) != 3:
        print("Usage: python convert_palette.py <input_file> <output_file>")
        sys.exit(1)

    process_palette(sys.argv[1], sys.argv[2])

if __name__ == "__main__":
    main()
