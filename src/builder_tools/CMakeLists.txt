# Minimum required CMake version (3.14 or higher for FetchContent)
cmake_minimum_required(VERSION 3.14)

# Project name (for this set of tools)
project(BlogBuilderTools CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17) # Or 20 if your compiler supports it
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- Fetch and include cmark-gfm (GitHub Flavored Markdown implementation) ---
include(FetchContent)
FetchContent_Declare(
  cmark_gfm
  GIT_REPOSITORY https://github.com/github/cmark-gfm.git # THIS MUST BE GITHUB'S FORK
  GIT_TAG        0.29.0.gfm.26 # This is a verified tag that works well with GFM features.
  GIT_SHALLOW    TRUE # Speeds up cloning in CI
)
FetchContent_MakeAvailable(cmark_gfm)

# --- Add cmark-gfm's include directory globally ---
# This ensures the compiler can find <cmark-gfm.h> for all source files.
# The path is relative to the cmark-gfm source directory fetched by FetchContent.
include_directories(${cmark_gfm_SOURCE_DIR}/src)


# --- Fetch and include Brotli ---
FetchContent_Declare(
  brotli_src
  GIT_REPOSITORY https://github.com/google/brotli.git
  GIT_TAG        v1.1.0 # Use a specific stable version for reproducibility
  GIT_SHALLOW    TRUE
)
FetchContent_MakeAvailable(brotli_src)
# Brotli's CMake creates targets like 'brotlidec', 'brotlienc', 'brotlicommon'

# Define common sources (utilities)
set(COMMON_SRCS common_utils.cpp)

# Add each executable target
add_executable(clean_public clean_public.cpp ${COMMON_SRCS})
add_executable(copy_static copy_static.cpp ${COMMON_SRCS})
add_executable(process_markdown process_markdown.cpp ${COMMON_SRCS})
add_executable(generate_pages generate_pages.cpp ${COMMON_SRCS})
add_executable(generate_search generate_search.cpp ${COMMON_SRCS})


# Link libraries to each executable based on their needs
# Note: For cmark-gfm, the static library is typically named 'cmark-gfm_static'
target_link_libraries(clean_public PRIVATE pthread)
target_link_libraries(copy_static PRIVATE brotlicommon brotlienc brotlidec pthread)
target_link_libraries(process_markdown PRIVATE cmark-gfm_static pthread) # Link against cmark-gfm_static
target_link_libraries(generate_pages PRIVATE brotlicommon brotlienc brotlidec pthread)
target_link_libraries(generate_search PRIVATE brotlicommon brotlienc brotlidec pthread)

# Set output directory for all executables to the parent directory (repo root)
set_target_properties(clean_public copy_static process_markdown generate_pages generate_search PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/../.."
)
