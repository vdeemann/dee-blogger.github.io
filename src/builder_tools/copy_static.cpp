#include "common_utils.h"
#include <iostream>

namespace fs = std::filesystem;

int main() {
    std::cout << "📦 Copying and compressing static assets..." << std::endl;
    const fs::path source_dir = "src/blog_content/static";
    const fs::path dest_dir = "public";

    if (!fs::exists(source_dir)) {
        std::cerr << "Warning: Static assets source directory not found: " << source_dir << std::endl;
        return 0; // Not an error if dir doesn't exist, just nothing to copy
    }

    std::error_code ec;
    for (const auto& entry : fs::recursive_directory_iterator(source_dir, ec)) {
        if (ec) {
            std::cerr << "Error iterating static directory: " << ec.message() << std::endl;
            return 1;
        }
        if (entry.is_regular_file()) {
            fs::path relative_path = fs::relative(entry.path(), source_dir, ec);
            if (ec) {
                std::cerr << "Error getting relative path for " << entry.path() << ": " << ec.message() << std::endl;
                return 1;
            }
            fs::path destination_path = dest_dir / relative_path;
            fs::create_directories(destination_path.parent_path(), ec);
            if (ec) {
                std::cerr << "Error creating directory for " << destination_path << ": " << ec.message() << std::endl;
                return 1;
            }

            // Read content, apply minification if CSS/JS, then write original and compressed
            std::string file_content = read_file(entry.path());
            std::string processed_content = file_content;

            // Apply minification based on file type
            if (entry.path().extension() == ".css" || entry.path().extension() == ".css.source") {
                processed_content = minify_css(file_content);
            } else if (entry.path().extension() == ".js" || entry.path().extension() == ".js.source") {
                processed_content = minify_js(file_content);
            }

            // Determine the final uncompressed filename
            std::string uncompressed_filename = destination_path.string();
            // If the source ends with .source, remove it for the output filename
            if (uncompressed_filename.length() >= 7 && uncompressed_filename.substr(uncompressed_filename.length() - 7) == ".source") {
                uncompressed_filename = uncompressed_filename.substr(0, uncompressed_filename.length() - 7);
            }

            // Write the (potentially minified) uncompressed file
            if (!write_file(uncompressed_filename, processed_content)) return 1;

            // Brotli compress the processed content
            std::string compressed_content = compress_brotli(processed_content);
            if (!compressed_content.empty() && compressed_content.length() < processed_content.length()) { // Only write if compression is effective
                if (!write_file(uncompressed_filename + ".br", compressed_content)) return 1;
            }
        }
    }
    std::cout << "✅ Static assets copied, minified, and compressed." << std::endl;
    return 0;
}
