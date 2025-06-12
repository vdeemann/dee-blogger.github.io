# Minimum required CMake version (3.14 or higher for FetchContent)
cmake_minimum_required(VERSION 3.14)

# Project name (for this set of tools)
project(BlogBuilderTools CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17) # Or 20 if your compiler supports it
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- Fetch and include cmark (CommonMark C reference implementation) ---
include(FetchContent)
FetchContent_Declare(
  cmark
  GIT_REPOSITORY https://github.com/commonmark/cmark.git
  GIT_TAG        0.30.2 # Use a specific stable version
  GIT_SHALLOW    TRUE # Speeds up cloning in CI
)
FetchContent_MakeAvailable(cmark)
# cmark's CMake setup should define a target like 'cmark_static'

# --- Fetch and include Brotli ---
FetchContent_Declare(
  brotli_src
  GIT_REPOSITORY https://github.com/google/brotli.git
  GIT_TAG        v1.1.0 # Use a specific stable version for reproducibility
  GIT_SHALLOW    TRUE # Speeds up cloning in CI
)
FetchContent_MakeAvailable(brotli_src)
# Brotli's CMake creates targets like 'brotlidec', 'brotlienc', 'brotlicommon'

# Define common sources (utilities)
set(COMMON_SRCS common_utils.cpp)
set(COMMON_HDRS common_utils.h)

# Add each executable target
add_executable(clean_public clean_public.cpp ${COMMON_SRCS})
add_executable(copy_static copy_static.cpp ${COMMON_SRCS})
add_executable(process_markdown process_markdown.cpp ${COMMON_SRCS})
add_executable(generate_pages generate_pages.cpp ${COMMON_SRCS})
add_executable(generate_search generate_search.cpp ${COMMON_SRCS})

# --- FIX: Add cmark's include directories ---
# This ensures the compiler can find <cmark-gfm.h>
# The path is relative to the cmark source directory fetched by FetchContent.
target_include_directories(clean_public PRIVATE ${cmark_SOURCE_DIR}/src)
target_include_directories(copy_static PRIVATE ${cmark_SOURCE_DIR}/src)
target_include_directories(process_markdown PRIVATE ${cmark_SOURCE_DIR}/src)
target_include_directories(generate_pages PRIVATE ${cmark_SOURCE_DIR}/src)
target_include_directories(generate_search PRIVATE ${cmark_SOURCE_DIR}/src)


# Link libraries to each executable based on their needs
target_link_libraries(clean_public PRIVATE pthread)
target_link_libraries(copy_static PRIVATE brotlicommon brotlienc brotlidec pthread)
target_link_libraries(process_markdown PRIVATE cmark_static pthread)
target_link_libraries(generate_pages PRIVATE brotlicommon brotlienc brotlidec pthread)
target_link_libraries(generate_search PRIVATE brotlicommon brotlienc brotlidec pthread)

# Set output directory for all executables to the parent directory (repo root)
set_target_properties(clean_public copy_static process_markdown generate_pages generate_search PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../.."
)
