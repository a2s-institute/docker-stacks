#!/bin/bash

# File you want to prepend lines to
TARGET_FILE="./opt/conda/lib/python3.11/site-packages/chromadb/__init__.py"

# Temporary file to store the existing content
TEMP_FILE=$(mktemp)

# Check if the file exists
if [ -f "$TARGET_FILE" ]; then
  # Write the new lines to the temporary file
  echo "__import__('pysqlite3')" > "$TEMP_FILE"
  echo "import sys" >> "$TEMP_FILE"
  echo "sys.modules['sqlite3'] = sys.modules.pop('pysqlite3')" >> "$TEMP_FILE"
  
  # Append the original content to the temporary file
  cat "$TARGET_FILE" >> "$TEMP_FILE"
  
  # Move the temporary file to the original file
  mv "$TEMP_FILE" "$TARGET_FILE"
  
  echo "Lines have been prepended to $TARGET_FILE"
else
  echo "File not found!"
  rm "$TEMP_FILE"
fi