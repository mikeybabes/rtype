import sys

def merge_binary_files(file1_path, file2_path, file3_path, file4_path, output_file_path):
    # Open the four input files and the output file
    with open(file1_path, 'rb') as file1, \
         open(file2_path, 'rb') as file2, \
         open(file3_path, 'rb') as file3, \
         open(file4_path, 'rb') as file4, \
         open(output_file_path, 'wb') as output_file:

        # Read all bytes from the input files
        file1_bytes = file1.read()
        file2_bytes = file2.read()
        file3_bytes = file3.read()
        file4_bytes = file4.read()

        # Check if all files have the same size
        if not (len(file1_bytes) == len(file2_bytes) == len(file3_bytes) == len(file4_bytes)):
            raise ValueError("All input files must have the same size")

        # Process each byte from the input files
        for b1, b2, b3, b4 in zip(file1_bytes, file2_bytes, file3_bytes, file4_bytes):
            for i in range(7, -1, -2):  # Process bits in pairs
                high_nybble1 = ((b1 >> i) & 1) << 3 | ((b2 >> i) & 1) << 2 | ((b3 >> i) & 1) << 1 | ((b4 >> i) & 1)
                high_nybble2 = ((b1 >> (i-1)) & 1) << 3 | ((b2 >> (i-1)) & 1) << 2 | ((b3 >> (i-1)) & 1) << 1 | ((b4 >> (i-1)) & 1)
                output_byte1 = high_nybble1 << 4 | high_nybble2
                output_file.write(bytes([output_byte1]))

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python plane4.py <file1> <file2> <file3> <file4> <output_file>")
        sys.exit(1)
    
    file1_path = sys.argv[1]
    file2_path = sys.argv[2]
    file3_path = sys.argv[3]
    file4_path = sys.argv[4]
    output_file_path = sys.argv[5]
    
    merge_binary_files(file1_path, file2_path, file3_path, file4_path, output_file_path)
