#ifndef COMMON_UTILS_H
#define COMMON_UTILS_H

#include <string>
#include <vector>
#include <filesystem>
#include <map>
#include <set>
#include <mutex>

// For cmark and brotli
#include <cmark-gfm.h>
#include <brotli/encode.h>

namespace fs = std::filesystem;

// --- Data Structures ---
struct PostMetadata {
    std::string id;
    std::string title;
    std::string date; // Format: YYYY-MM-DD for sorting
    std::string permalink;
    std::string html_body; // For internal use by process_markdown, passed via JSON
};

// --- Global Data (only for generate_search.cpp and common_utils.cpp internal use) ---
// In the Unix philosophy, data primarily flows via pipes. These globals are for
// accumulating data within a single tool (like generate_search) or for shared helpers.
extern std::map<std::string, std::set<std::string>> inverted_index;
extern std::map<std::string, PostMetadata> post_id_to_metadata;
extern std::mutex global_data_mutex; // Protects inverted_index and post_id_to_metadata

// --- Utility Functions ---
std::string read_file(const fs::path& path);
bool write_file(const fs::path& path, const std::string& content);
bool copy_file(const fs::path& source, const fs::path& destination);

std::string convert_markdown_to_html(const std::string& markdown_content);
std::string minify_html(const std::string& html);
std::string minify_css(const std::string& css);
std::string minify_js(const std::string& js);
std::string compress_brotli(const std::string& data);

std::vector<std::string> tokenize(const std::string& text);
// add_to_inverted_index will be called by generate_search.cpp internally
void add_to_inverted_index(const std::string& post_id, const std::string& content_to_index);

// JSON utility for PostMetadata (for inter-tool communication)
std::string post_metadata_to_json(const PostMetadata& post, const std::string& html_body_content);
PostMetadata post_metadata_from_json(const std::string& json_str);

#endif // COMMON_UTILS_H
