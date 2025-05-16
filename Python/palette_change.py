import sys
import struct

def update_palette(source_file, destination_file, palette_pairs):
    with open(source_file, "rb") as sf, open(destination_file, "r+b") as df:
        src = sf.read()
        dst = df.read()

        if len(src) != 256*48:
            raise ValueError("Source must be 256 palettes (256×48 bytes).")
        if len(dst) != 16*48:
            raise ValueError("Destination must be 16 palettes (16×48 bytes).")

        for source_idx, dest_idx in palette_pairs:
            if not (0 <= source_idx < 256):
                raise ValueError(f"Source index {source_idx} out of range (0–255).")
            if not (0 <= dest_idx < 16):
                raise ValueError(f"Dest index {dest_idx} out of range (0–15).")

            so = source_idx * 48
            di = dest_idx   * 48
            chunk = src[so : so + 48]
            dst = dst[:di] + chunk + dst[di + 48:]

        df.seek(0)
        df.write(dst)

    print(f"Updated {destination_file} successfully.")

def parse_args(a):
    if len(a) < 4 or (len(a)-2)%2!=0:
        raise ValueError("Usage: python palette_change.py source.bin dest.bin <srcIdx> <dstIdx> [<src2> <dst2> ...]")
    src, dst = a[0], a[1]
    pairs = []
    for i in range(2, len(a), 2):
        pairs.append((int(a[i]), int(a[i+1])))
    return src, dst, pairs

if __name__=="__main__":
    try:
        src, dst, pairs = parse_args(sys.argv[1:])
        update_palette(src, dst, pairs)
    except Exception as e:
        print("Error:", e)
        sys.exit(1)
