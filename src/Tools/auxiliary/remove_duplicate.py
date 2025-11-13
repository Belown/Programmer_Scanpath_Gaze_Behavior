import pandas as pd
import os
import hashlib
from typing import Tuple, Dict

def filter_duplicates(df: pd.DataFrame):
    '''
    Filter dataframe that has symmetric exp_a and exp_b entries to only keep one of them.
    :param df: DataFrame from .csv file.

    :return: filtered DataFrame.
    '''
    df = df.copy()
    df['pair_id'] = df.apply(lambda x: tuple(sorted([x['exp_a'], x['exp_b']])), axis=1)
    df = df.drop_duplicates(subset='pair_id', keep='first')
    df = df.drop(columns='pair_id')
    return df

def validate_filter_duplicates():
    """
    Unit test for filter_duplicates function.
    """
    print("=== Testing filter_duplicates function ===")
    
    # Test case 1: Basic symmetric pairs
    test_df1 = pd.DataFrame({
        'exp_a': ['A', 'B', 'A', 'C'],
        'exp_b': ['B', 'A', 'C', 'A'],
        'value': [1, 2, 3, 4]
    })
    
    result1 = filter_duplicates(test_df1)
    expected_pairs = {('A', 'B'), ('A', 'C')}
    actual_pairs = set(result1.apply(lambda x: tuple(sorted([x['exp_a'], x['exp_b']])), axis=1))
    
    print(f"Test 1 - Basic symmetric pairs:")
    print(f"  Input rows: {len(test_df1)}")
    print(f"  Output rows: {len(result1)}")
    print(f"  Expected unique pairs: {expected_pairs}")
    print(f"  Actual unique pairs: {actual_pairs}")
    print(f"  Test 1 PASSED: {expected_pairs == actual_pairs}")
    
    # Test case 2: No duplicates
    test_df2 = pd.DataFrame({
        'exp_a': ['A', 'B', 'C'],
        'exp_b': ['D', 'E', 'F'],
        'value': [1, 2, 3]
    })
    
    result2 = filter_duplicates(test_df2)
    print(f"\nTest 2 - No duplicates:")
    print(f"  Input rows: {len(test_df2)}")
    print(f"  Output rows: {len(result2)}")
    print(f"  Test 2 PASSED: {len(test_df2) == len(result2)}")
    
    # Test case 3: All same pairs
    test_df3 = pd.DataFrame({
        'exp_a': ['A', 'B', 'A', 'B'],
        'exp_b': ['B', 'A', 'B', 'A'],
        'value': [1, 2, 3, 4]
    })
    
    result3 = filter_duplicates(test_df3)
    print(f"\nTest 3 - All same pairs:")
    print(f"  Input rows: {len(test_df3)}")
    print(f"  Output rows: {len(result3)}")
    print(f"  Test 3 PASSED: {len(result3) == 1}")
    
    return True

def verify_file_integrity(original_file: str, processed_file: str) -> Dict:
    """
    Verify the integrity of processed files.
    
    :param original_file: Path to original file
    :param processed_file: Path to processed file
    :return: Dictionary with verification results
    """
    try:
        df_original = pd.read_csv(original_file)
        df_processed = pd.read_csv(processed_file)
        
        # Check if required columns exist
        required_cols = ['exp_a', 'exp_b']
        cols_exist = all(col in df_original.columns for col in required_cols)
        
        if not cols_exist:
            return {
                'status': 'error',
                'message': f'Required columns {required_cols} not found in {original_file}'
            }
        
        # Apply filter_duplicates to original for comparison
        df_expected = filter_duplicates(df_original)
        
        # Verify row counts
        rows_match = len(df_processed) == len(df_expected)
        
        # Verify column structure (excluding any temporary columns)
        cols_match = list(df_processed.columns) == list(df_expected.columns)
        
        # Verify unique pairs
        original_pairs = set(df_processed.apply(lambda x: tuple(sorted([x['exp_a'], x['exp_b']])), axis=1))
        expected_pairs = set(df_expected.apply(lambda x: tuple(sorted([x['exp_a'], x['exp_b']])), axis=1))
        pairs_match = original_pairs == expected_pairs
        
        return {
            'status': 'success' if (rows_match and cols_match and pairs_match) else 'warning',
            'original_rows': len(df_original),
            'processed_rows': len(df_processed),
            'expected_rows': len(df_expected),
            'rows_match': rows_match,
            'columns_match': cols_match,
            'unique_pairs_match': pairs_match,
            'removed_duplicates': len(df_original) - len(df_processed)
        }
        
    except Exception as e:
        return {
            'status': 'error',
            'message': str(e)
        }

def process_files_with_structure_verified(source_path: str, output_path: str, output_suffix: str = "_filtered"):
    """
    Process CSV files while maintaining folder structure with verification.
    
    :param source_path: Source directory path
    :param output_path: Output directory path  
    :param output_suffix: Suffix to add to output files
    """
    # Run unit tests first
    print("Running unit tests...")
    validate_filter_duplicates()
    print("\n" + "="*60 + "\n")
    
    verification_log = []
    total_files = 0
    successful_files = 0
    
    for root, dirs, files in os.walk(source_path):
        for file in files:
            if file.endswith('.csv'):
                total_files += 1
                
                # Get relative path from source
                relative_path = os.path.relpath(root, source_path)
                
                # Create corresponding output directory
                if relative_path == '.':
                    output_dir = output_path
                else:
                    output_dir = os.path.join(output_path, relative_path)
                
                os.makedirs(output_dir, exist_ok=True)
                
                # Process file
                input_file = os.path.join(root, file)
                try:
                    # Load and process data
                    df = pd.read_csv(input_file)
                    print(f"Processing {input_file}: {len(df)} rows")
                    
                    # Check if required columns exist
                    if 'exp_a' not in df.columns or 'exp_b' not in df.columns:
                        print(f"  WARNING: Required columns not found, skipping...")
                        continue
                    
                    # Apply filter_duplicates
                    df_filtered = filter_duplicates(df)
                    removed_count = len(df) - len(df_filtered)
                    print(f"  After filtering: {len(df_filtered)} rows ({removed_count} removed)")
                    
                    # Generate output filename
                    base_name = os.path.splitext(file)[0]
                    output_file = os.path.join(output_dir, f"{base_name}{output_suffix}.csv")
                    
                    # Save filtered data
                    df_filtered.to_csv(output_file, index=False)
                    print(f"  Saved to: {output_file}")
                    
                    # Verify file integrity
                    verification = verify_file_integrity(input_file, output_file)
                    verification['file'] = relative_path + '/' + file if relative_path != '.' else file
                    verification_log.append(verification)
                    
                    if verification['status'] == 'success':
                        successful_files += 1
                        print(f"  ✅ Verification PASSED")
                    else:
                        print(f"  ❌ Verification FAILED: {verification.get('message', 'Unknown error')}")
                    
                except Exception as e:
                    print(f"  ❌ Error processing {input_file}: {str(e)}")
                    verification_log.append({
                        'file': relative_path + '/' + file if relative_path != '.' else file,
                        'status': 'error',
                        'message': str(e)
                    })
    
    # Generate verification report
    report_file = os.path.join(output_path, 'verification_report.txt')
    with open(report_file, 'w') as f:
        f.write("File Processing Verification Report\n")
        f.write("=" * 50 + "\n\n")
        f.write(f"Total files processed: {total_files}\n")
        f.write(f"Successfully verified: {successful_files}\n")
        f.write(f"Success rate: {successful_files/total_files*100:.1f}%\n\n")
        
        f.write("Detailed Results:\n")
        f.write("-" * 30 + "\n")
        
        for result in verification_log:
            f.write(f"\nFile: {result['file']}\n")
            f.write(f"Status: {result['status']}\n")
            
            if result['status'] == 'success':
                f.write(f"  Original rows: {result['original_rows']}\n")
                f.write(f"  Processed rows: {result['processed_rows']}\n")
                f.write(f"  Removed duplicates: {result['removed_duplicates']}\n")
            elif result['status'] == 'error':
                f.write(f"  Error: {result['message']}\n")
    
    print(f"\n📊 Processing Summary:")
    print(f"  Total files: {total_files}")
    print(f"  Successfully processed: {successful_files}")
    print(f"  Success rate: {successful_files/total_files*100:.1f}%")
    print(f"  Verification report saved to: {report_file}")