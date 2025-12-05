import os, glob, pandas as pd

def merge_csv_files(folder_path, output_filename="combined_data.csv"):
    """
    Read all CSV files in the specified folder, merge them, and save to the same folder
    
    :param folder_path: Path to the folder containing CSV files
    :param output_filename: Name of the output combined CSV file
    """
    # Check if folder exists
    if not os.path.exists(folder_path):
        print(f"Folder does not exist: {folder_path}")
        return

    # Find all CSV files in the folder
    csv_files = glob.glob(os.path.join(folder_path, "*.csv"))
    
    # Remove output file from the list if it exists
    output_file = os.path.join(folder_path, output_filename)
    csv_files = [f for f in csv_files if f != output_file]
    
    if not csv_files:
        print(f"No CSV files found in: {folder_path}")
        return

    print(f"Found {len(csv_files)} CSV files in {folder_path}")

    # Read and concatenate all CSV files
    dataframes = []
    for file in csv_files:
        try:
            df = pd.read_csv(file)
            # Optional: Add the filename as a column
            df['source_file'] = os.path.basename(file)
            dataframes.append(df)
            print(f"  Read: {os.path.basename(file)} ({len(df)} rows)")
        except Exception as e:
            print(f"  Error reading {file}: {e}")

    if dataframes:
        # Combine all dataframes
        combined_df = pd.concat(dataframes, ignore_index=True)
        
        # Save the combined dataframe
        combined_df.to_csv(output_file, index=False)

        print(f"✓ Combined {len(combined_df)} rows")
        print(f"✓ Saved to: {output_file}\n")
    else:
        print("No CSV files were successfully read.\n")
