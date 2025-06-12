cmake_minimum_required(VERSION 3.14)
project(dee_blogger_builder)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)

# Fetch cmark-gfm
FetchContent_Declare(
    cmark_gfm
    GIT_REPOSITORY https://github.com/github/cmark-gfm.git
    GIT_TAG        0.29.0.gfm.13
)

# Make it available
FetchContent_MakeAvailable(cmark_gfm)

# Your executable
add_executable(blog_builder main.cpp)

# Link with cmark-gfm
target_link_libraries(blog_builder PRIVATE cmark-gfm)