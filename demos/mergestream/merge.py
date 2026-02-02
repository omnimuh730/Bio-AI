import os

def merge_dart_files_to_total_txt(root_dir="."):
    """
    Recursively finds all .dart files in the root_dir (and subdirectories),
    reads their content, and merges them into a single 'total.txt' file.
    Each file's content is preceded by its relative path from the root_dir.
    """
    output_filename = "total.txt"
    
    print(f"Starting merge process from directory: {os.path.abspath(root_dir)}")

    try:
        with open(output_filename, 'w', encoding='utf-8') as outfile:
            # os.walk generates the file names in a directory tree by walking the tree
            # either top-down or bottom-up.
            for dirpath, dirnames, filenames in os.walk(root_dir):
                # We skip the output file itself if it already exists in the structure
                if output_filename in filenames and os.path.abspath(dirpath) == os.path.abspath(os.path.dirname(output_filename)):
                    continue
                    
                for filename in filenames:
                    if filename.endswith(".dart"):
                        # Construct the full file path
                        file_path = os.path.join(dirpath, filename)
                        
                        # Get the path relative to the starting root_dir
                        relative_path = os.path.relpath(file_path, root_dir)
                        
                        # Standardize path separators for consistent output (especially important if running on Windows)
                        # The request implies a Unix-like path structure for highlighting (root/path/file.dart)
                        formatted_path = relative_path.replace(os.sep, '/')
                        
                        # Prepend the 'root/' prefix as requested for highlighting
                        display_path = f"root/{formatted_path}"
                        
                        print(f"Processing: {display_path}")
                        
                        # Write the path header
                        outfile.write(f"// --- START OF FILE: {display_path} ---\n\n")
                        
                        try:
                            # Read the content of the .dart file
                            with open(file_path, 'r', encoding='utf-8') as infile:
                                content = infile.read()
                                outfile.write(content)
                                # Add a newline after the content for clean separation
                                outfile.write("\n\n")
                        except IOError as e:
                            print(f"Error reading file {file_path}: {e}")
                            outfile.write(f"// --- ERROR READING FILE: {display_path} ---\n\n")
                        
                        # Write the footer
                        outfile.write(f"// --- END OF FILE: {display_path} ---\n\n\n")

        print(f"\nSuccessfully merged all .dart files into '{output_filename}'.")

    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# --- Execution ---
# Assuming you run this script from the directory *above* the one shown in the image 
# (i.e., the directory containing 'lib').
# If you run it *inside* the 'settings' directory shown, use root_dir="."
# If you run it from the 'bio_ai' directory, you might need to adjust the path 
# or run it inside the 'lib/ui/pages/settings' directory.

# Based on the image path: D:/Studio (D:)/Utils/Bio AI/bio_ai/lib/ui/pages/settings
# If you save this script in the 'settings' folder:
merge_dart_files_to_total_txt(root_dir=".") 

# If you save this script in the 'bio_ai' folder and want to include everything under 'lib':
# merge_dart_files_to_total_txt(root_dir="lib")