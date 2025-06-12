cmake_minimum_required(VERSION 3.14)
project(dee_blogger_builder)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)

# Disable building cmark-gfm tests and executable
set(CMARK_TESTS OFF CACHE BOOL "Build cmark tests")
set(CMARK_SHARED OFF CACHE BOOL "Build shared library")
set(CMARK_STATIC ON CACHE BOOL "Build static library")

# Fetch cmark-gfm
FetchContent_Declare(
    cmark_gfm
    GIT_REPOSITORY https://github.com/github/cmark-gfm.git
    GIT_TAG        0.29.0.gfm.13
)

FetchContent_MakeAvailable(cmark_gfm)

# Your executable
add_executable(blog_builder main.cpp)

# Link with the correct library targets
target_link_libraries(blog_builder PRIVATE 
    libcmark-gfm-static        # The static library
    libcmark-gfm-extensions-static  # Extensions if needed
)

# Include directories
target_include_directories(blog_builder PRIVATE 
    ${cmark_gfm_SOURCE_DIR}/src
    ${cmark_gfm_BINARY_DIR}/src
)