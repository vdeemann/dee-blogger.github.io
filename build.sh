#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
# Exit if any command in a pipeline fails.
set -eo pipefail

echo "Starting Unix-Philosophied C++ Blog Build Pipeline..."
START_TIME=$(date +%s) # Record start time for overall build duration

# Define the directory where the compiled C++ executables are located
BUILD_TOOLS_DIR="./src/builder_tools/build"

# --- Build Steps Orchestration ---

# Step 1: Clean public directory
# Executes the C++ tool responsible for cleaning and setting up the output directory.
echo "Step 1: Cleaning public directory..."
"${BUILD_TOOLS_DIR}/clean_public" || { echo "Error: clean_public failed." >&2; exit 1; }

# Step 2: Copy and compress static assets (CSS, JS, Images, Fonts)
# Executes the C++ tool to copy and process static files.
echo "Step 2: Copying and compressing static assets..."
"${BUILD_TOOLS_DIR}/copy_static" || { echo "Error: copy_static failed." >&2; exit 1; }

# Step 3: Process Markdown files in parallel and collect JSON metadata
echo "Step 3: Processing markdown files in parallel and collecting metadata..."

# Create a temporary directory for the named pipe (FIFO)
# This is crucial for efficient streaming of data from 'process_markdown' to two consumers.
TEMP_PIPE_DIR=$(mktemp -d)
JSON_PIPE="${TEMP_PIPE_DIR}/markdown_metadata.pipe"
mkfifo "${JSON_PIPE}" # Create the named pipe

# Find all markdown files in the posts directory.
# Pipe their paths (null-terminated) to xargs.
# xargs then runs 'process_markdown' for each file in parallel (-P "$(nproc)" uses all CPU cores).
# The output of 'process_markdown' (JSON lines) is piped to 'tee'.
# 'tee' duplicates the stream: one copy goes into the named pipe (JSON_PIPE),
# and the other copy goes to stdout (which is then discarded or could be redirected to a log).
# The '&' puts this entire pipeline in the background.
find src/blog_content/posts -name "*.md" -print0 | \
xargs -0 -P "$(nproc)" -I {} "${BUILD_TOOLS_DIR}/process_markdown" "{}" \
> >(tee /dev/null) > "${JSON_PIPE}" || { echo "Error: markdown processing failed." >&2; exit 1; } &
# Note: The `> >(tee /dev/null)` is a common trick to get process substitution to work while still
# teeing to a named pipe. The `tee` sends one copy to /dev/null (effectively discarding it from shell output)
# and the other to the named pipe.

# Get the PID of the background xargs process to wait for it later
XARGS_PID=$!

# Step 4: Generate HTML pages (posts, index, archive)
# This tool reads the JSON metadata from the named pipe.
echo "Step 4: Generating HTML pages..."
"${BUILD_TOOLS_DIR}/generate_pages" < "${JSON_PIPE}" &
GENERATE_PAGES_PID=$!

# Step 5: Generate search index (search-index.js)
# This tool also reads the JSON metadata from the same named pipe.
echo "Step 5: Generating search index..."
"${BUILD_TOOLS_DIR}/generate_search" < "${JSON_PIPE}" &
GENERATE_SEARCH_PID=$!

# Wait for all background processes (xargs, generate_pages, generate_search) to complete
echo "Waiting for parallel processing and generation tools to complete..."
wait "$XARGS_PID" "$GENERATE_PAGES_PID" "$GENERATE_SEARCH_PID"
if [ $? -ne 0 ]; then
    echo "Error: One or more background processes failed during parallel stage." >&2; exit 1;
fi

# Clean up the temporary pipe directory
rm -rf "${TEMP_PIPE_DIR}"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "✅ All HTML pages and search index generated and compressed."
echo "✅ Build pipeline completed successfully in ${DURATION} seconds."
