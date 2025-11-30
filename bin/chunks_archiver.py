#!/usr/bin/env python3
"""
Directory Archiver and Chunk Emitter

This module provides functionality to:
1. Archive a directory into base64-encoded gzipped tar chunks
2. Reconstruct the directory from captured chunks

Usage:
  python archive_chunks.py encode --directory /path/to/dir
  python archive_chunks.py decode --chunk-dir /path/to/chunks
  python archive_chunks.py decode --chunk-file chunks.txt
"""

import os
import gzip
import base64
import math
import tarfile
import io
import argparse
import sys
import re
import glob

def prepare_directory_state(directory_path, chunk_size=1_000_000):
    """
    Prepares the state for a directory to be archived and chunked.
    
    Args:
        directory_path (str): Directory to archive
        chunk_size (int): Size of each chunk in characters (~1MB default)
    
    Returns:
        dict: State dictionary ready for chunk emission
    """
    # Validate directory exists
    if not os.path.exists(directory_path):
        raise ValueError(f"Directory '{directory_path}' does not exist")
    
    if not os.path.isdir(directory_path):
        raise ValueError(f"'{directory_path}' is not a directory")
    
    # Create state
    state = {
        "directory_path": directory_path,
        "chunk_size": chunk_size,
        "b64_data": None,
        "offset": 0,
        "chunk_index": 1,
        "generator": None
    }
    
    # Create tar archive in memory
    tar_buffer = io.BytesIO()
    with tarfile.open(fileobj=tar_buffer, mode='w') as tar:
        tar.add(state["directory_path"], arcname=os.path.basename(state["directory_path"]))
    
    tar_data = tar_buffer.getvalue()
    
    # Gzip compress and base64 encode
    gz = gzip.compress(tar_data)
    state["b64_data"] = base64.b64encode(gz).decode("ascii")
    
    # Calculate statistics
    total_len = len(state["b64_data"])
    est_chunks = math.ceil(total_len / state["chunk_size"]) if total_len else 0
    
    print(f"Prepared base64(gzip(tar({directory_path}))): {total_len} chars, ~{est_chunks} chunks of ~{chunk_size} chars.", file=sys.stderr)
    
    return state

def create_chunk_generator(state):
    """
    Creates a generator that yields chunks from the state.
    
    Args:
        state (dict): State dictionary from prepare_directory_state
        
    Returns:
        generator: Yields (chunk_index, chunk_text) tuples
    """
    def chunk_generator():
        b64 = state["b64_data"]
        offset = state["offset"]
        size = state["chunk_size"]
        
        while offset < len(b64):
            end = min(offset + size, len(b64))
            chunk_text = b64[offset:end]
            
            # Yield chunk data
            yield (state["chunk_index"], chunk_text)
            
            # Update state
            state["offset"] = end
            state["chunk_index"] += 1
            offset = state["offset"]
        
        return None
    
    return chunk_generator()

def emit_all_chunks(state):
    """
    Emits all chunks at once using the state.
    
    Args:
        state (dict): State dictionary
    """
    if state["generator"] is None:
        state["generator"] = create_chunk_generator(state)
    
    for chunk_index, chunk_text in state["generator"]:
        print(f"chunk {chunk_index}")
        print(chunk_text)
    
    print("Done!")

def emit_next_chunk(state):
    """
    Wrapper that manually emits the next chunk when called.
    
    Args:
        state (dict): State dictionary with generator
        
    Each call prints:
      - 'chunk N' on the first line  
      - the base64 chunk on the second line
    When all chunks are done, prints 'Done!'
    """
    # Initialize generator if not already done
    if state["generator"] is None:
        state["generator"] = create_chunk_generator(state)
    
    try:
        chunk_index, chunk_text = next(state["generator"])
        print(f"chunk {chunk_index}")
        print(chunk_text)
    except StopIteration:
        print("Done!")

def reset_state(state):
    """
    Resets the state to allow re-emitting chunks from the beginning.
    
    Args:
        state (dict): State dictionary to reset
    """
    state["offset"] = 0
    state["chunk_index"] = 1
    state["generator"] = None
    print("State reset - ready to emit chunks from beginning", file=sys.stderr)

def reconstruct_from_chunks(chunk_dir, output_base_dir="./", chunk_pattern="chunk*"):
    """
    Reconstructs the original directory from captured chunks.
    
    Args:
        chunk_dir (str): Directory containing the chunk files (default: current directory)
        output_base_dir (str): Base directory where the extracted content will be placed (default: ./)
        chunk_pattern (str): Pattern to match chunk files (default: "chunk*")
    
    Returns:
        bool: True if successful, False otherwise
    """
    # If chunk_dir is not provided, use current directory
    if not chunk_dir or chunk_dir == "./":
        chunk_dir = "."
    
    # Find all chunk files matching the pattern
    search_pattern = os.path.join(chunk_dir, chunk_pattern)
    chunk_files = glob.glob(search_pattern)
    
    # Also look for files with numbers in them if default pattern finds nothing
    if not chunk_files:
        all_files = os.listdir(chunk_dir)
        chunk_files = [f for f in all_files if re.search(r'\d', f) and os.path.isfile(os.path.join(chunk_dir, f))]
        if chunk_files:
            print(f"No files matched pattern '{chunk_pattern}', but found {len(chunk_files)} files with numbers", file=sys.stderr)
    
    if not chunk_files:
        print(f"No chunk files found in '{chunk_dir}' with pattern '{chunk_pattern}'", file=sys.stderr)
        return False
    
    # Sort chunks by their index
    def extract_chunk_index(filename):
        # Try multiple patterns to extract numbers
        basename = os.path.basename(filename)
        numbers = re.findall(r'\d+', basename)
        return int(numbers[0]) if numbers else 0
    
    chunk_files.sort(key=extract_chunk_index)
    
    print(f"Found {len(chunk_files)} chunk files", file=sys.stderr)
    
    # Read all chunks
    chunks = []
    for chunk_file in chunk_files:
        try:
            with open(chunk_file, 'r', encoding='utf-8') as f:
                content = f.read()
                # Extract base64 data (skip "chunk X" lines and "Done!")
                lines = content.split('\n')
                for line in lines:
                    line = line.strip()
                    if line and not line.startswith('chunk') and not line == 'Done!':
                        # Check if it looks like base64
                        if (len(line) % 4 == 0 and 
                            re.match(r'^[A-Za-z0-9+/]*={0,2}$', line)):
                            chunks.append(line)
                            break
        except Exception as e:
            print(f"Error reading chunk file {chunk_file}: {e}", file=sys.stderr)
            return False
    
    if not chunks:
        print("No valid base64 data found in chunk files", file=sys.stderr)
        return False
    
    # Combine all base64 chunks
    combined_b64 = ''.join(chunks)
    
    try:
        # Decode base64
        gz_data = base64.b64decode(combined_b64)
        
        # Decompress gzip
        tar_data = gzip.decompress(gz_data)
        
        # Extract tar archive
        tar_stream = io.BytesIO(tar_data)
        with tarfile.open(fileobj=tar_stream, mode='r') as tar:
            # Create output directory if it doesn't exist
            os.makedirs(output_base_dir, exist_ok=True)
            
            # Extract all files
            tar.extractall(path=output_base_dir)
            
        print(f"Successfully extracted content to: {output_base_dir}", file=sys.stderr)
        return True
        
    except Exception as e:
        print(f"Error during reconstruction: {e}", file=sys.stderr)
        return False

def reconstruct_from_chunk_file(chunk_file_path, output_base_dir="./"):
    """
    Reconstructs from a single file containing all chunks in the original emission format.
    
    Args:
        chunk_file_path (str): Path to file containing all chunk emissions
        output_base_dir (str): Base directory where the extracted content will be placed (default: ./)
    
    Returns:
        bool: True if successful, False otherwise
    """
    chunks = []
    
    try:
        with open(chunk_file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        # Extract base64 data, skipping "chunk X" and "Done!" lines
        for line in lines:
            line = line.strip()
            if line and not line.startswith('chunk') and not line == 'Done!':
                # Verify it looks like base64
                if (len(line) % 4 == 0 and 
                    re.match(r'^[A-Za-z0-9+/]*={0,2}$', line)):
                    chunks.append(line)
                
        if not chunks:
            print("No valid base64 data found in chunk file", file=sys.stderr)
            return False
            
        # Combine all base64 chunks
        combined_b64 = ''.join(chunks)
        
        # Decode base64
        gz_data = base64.b64decode(combined_b64)
        
        # Decompress gzip
        tar_data = gzip.decompress(gz_data)
        
        # Extract tar archive
        tar_stream = io.BytesIO(tar_data)
        with tarfile.open(fileobj=tar_stream, mode='r') as tar:
            # Create output directory if it doesn't exist
            os.makedirs(output_base_dir, exist_ok=True)
            
            # Extract all files
            tar.extractall(path=output_base_dir)
            
        print(f"Successfully extracted content to: {output_base_dir}", file=sys.stderr)
        return True
        
    except Exception as e:
        print(f"Error during reconstruction: {e}", file=sys.stderr)
        return False

def main():
    """Main function to handle command line arguments"""
    parser = argparse.ArgumentParser(
        description="Archive directories into chunks and reconstruct from chunks",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Encode current directory and output to stdout
  %(prog)s encode -d .
  
  # Encode a directory and save to file
  %(prog)s encode -d /path/to/dir -o chunks.txt
  
  # Decode from chunk files in current directory
  %(prog)s decode --chunk-dir .
  
  # Decode from specific chunk file pattern
  %(prog)s decode --chunk-dir . --pattern "part*"
  
  # Decode from single file
  %(prog)s decode --chunk-file chunks.txt
        """
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')
    
    # Encode command
    encode_parser = subparsers.add_parser('encode', help='Encode a directory into chunks')
    encode_parser.add_argument('--directory', '-d', default='.', 
                              help='Directory to encode (default: current directory)')
    encode_parser.add_argument('--chunk-size', '-s', type=int, default=1000000, 
                              help='Chunk size in characters (default: 1000000)')
    encode_parser.add_argument('--output-file', '-o', 
                              help='Output file for all chunks (if not provided, output to stdout)')
    
    # Decode command
    decode_parser = subparsers.add_parser('decode', help='Decode chunks into a directory')
    decode_group = decode_parser.add_mutually_exclusive_group(required=True)
    decode_group.add_argument('--chunk-dir', help='Directory containing chunk files (default: current directory)')
    decode_group.add_argument('--chunk-file', help='Single file containing all chunks')
    decode_parser.add_argument('--output', '-o', default='./', 
                              help='Output directory for reconstruction (default: current directory)')
    decode_parser.add_argument('--pattern', '-p', default='chunk*', 
                              help='Pattern to match chunk files (default: "chunk*")')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    if args.command == 'encode':
        try:
            # Use current directory if not specified
            directory = args.directory if args.directory != '.' else os.getcwd()
            
            # Prepare state and emit chunks
            state = prepare_directory_state(directory, args.chunk_size)
            
            if args.output_file:
                # Redirect output to file
                original_stdout = sys.stdout
                with open(args.output_file, 'w', encoding='utf-8') as f:
                    sys.stdout = f
                    emit_all_chunks(state)
                    sys.stdout = original_stdout
                print(f"All chunks written to: {args.output_file}", file=sys.stderr)
            else:
                # Output to stdout
                emit_all_chunks(state)
                
        except Exception as e:
            print(f"Error during encoding: {e}", file=sys.stderr)
            sys.exit(1)
            
    elif args.command == 'decode':
        success = False
        if args.chunk_dir:
            # Use current directory if not specified
            chunk_dir = args.chunk_dir if args.chunk_dir != '.' else os.getcwd()
            success = reconstruct_from_chunks(chunk_dir, args.output, args.pattern)
        elif args.chunk_file:
            success = reconstruct_from_chunk_file(args.chunk_file, args.output)
            
        if not success:
            sys.exit(1)
    else:
        parser.print_help()
        sys.exit(1)

if __name__ == "__main__":
    main()
