import sys
import struct

def analyze_map_offsets(filename):
    with open(filename, "rb") as f:
        data = f.read()

    total_entries = len(data) // 2
    flip_x_count = 0
    flip_y_count = 0
    offsets = []
    error_offsets = []

    for i in range(0, len(data), 2):
        word = struct.unpack_from("<H", data, i)[0]
        entry_index = i // 2

        flip_x = word & 0x0001
        flip_y = word & 0x0002
        if flip_x:
            flip_x_count += 1
        if flip_y:
            flip_y_count += 1

        raw_segment = word & 0xFFFC
        adjusted_offset = (raw_segment - 0x3000) << 4
        offsets.append(adjusted_offset)

        # Mark as error if negative or above valid segment range ($6A00 << 4)
        if adjusted_offset < 0 or adjusted_offset > (0x6A00 << 4):
            error_offsets.append((entry_index, word, adjusted_offset))

    valid_offsets = [o for o in offsets if o >= 0]
    min_offset = min(valid_offsets) if valid_offsets else 0
    max_offset = max(valid_offsets) if valid_offsets else 0

    print(f"Analyzed: {filename}")
    print(f"Total entries        : {total_entries}")
    print(f"Flip X used          : {flip_x_count}")
    print(f"Flip Y used          : {flip_y_count}")
    print(f"Valid tile offset range: ${min_offset:05X} to ${max_offset:05X}")
    print(f"Erroneous entries    : {len(error_offsets)}")

    if error_offsets:
        print("First 10 errors:")
        for idx, word_val, off in error_offsets[:10]:
            byte_offset = idx * 2
            print(f"  Entry {idx:4} @ file ${byte_offset:05X}: word=${word_val:04X} → offset=${off:05X}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python map_analysis.py tile_map.bin")
        sys.exit(1)

    analyze_map_offsets(sys.argv[1])
