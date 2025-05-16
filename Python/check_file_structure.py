import os
import sys

# Function to check the file size and structure
def check_file_structure(input_file):
    file_size = os.path.getsize(input_file)
    print(f"File size: {file_size} bytes")

    # Check if the file size is divisible by 3 (since each color is 3 bytes)
    if file_size % 3 != 0:
        print(f"Warning: The file size ({file_size} bytes) is not divisible by 3.")
        print("This suggests that the file might not contain 3 bytes per color, which is expected.")
    else:
        num_colors = file_size // 3
        print(f"The file contains {num_colors} colors.")

# Main function to handle user input
def main():
    if len(sys.argv) != 2:
        print("Usage: python check_file_structure.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    check_file_structure(input_file)

if __name__ == "__main__":
    main()
