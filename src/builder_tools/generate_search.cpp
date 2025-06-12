#include "common_utils.h"
#include <iostream>
#include <sstream>
#include <set> // For unique post IDs

int main() {
    std::cout << "Generating search-index.js..." << std::endl;

    std::string line;
    // Read JSON post metadata (each line is one JSON object) from stdin
    while (std::getline(std::cin, line)) {
        if (line.empty()) continue;
        PostMetadata post = post_metadata_from_json(line);

        // Add content (title + full HTML body) to the global inverted index
        // This tool is responsible for building the *entire* index in memory.
        add_to_inverted_index(post.id, post.title + " " + post.html_body);

        // Store post metadata for client-side use (excluding html_body to save JS file size)
        {
            std::lock_guard<std::mutex> lock(global_data_mutex);
            // Create a PostMetadata copy without the potentially huge html_body for client-side use
            PostMetadata client_post_meta;
            client_post_meta.id = post.id;
            client_post_meta.title = post.title;
            client_post_meta.date = post.date;
            client_post_meta.permalink = post.permalink;
            // client_post_meta.html_body is intentionally left empty
            post_id_to_metadata[post.id] = client_post_meta;
        }
    }

    // Now, build the JavaScript content for searchIndex and postMetadata
    std::string search_index_data_js_content = "const searchIndex = {";
    bool first_word = true;
    {
        std::lock_guard<std::mutex> lock(global_data_mutex); // Lock before accessing inverted_index
        for (const auto& pair : inverted_index) {
            if (!first_word) search_index_data_js_content += ",";
            search_index_data_js_content += "\"" + pair.first + "\":[";
            bool first_post_id = true;
            for (const std::string& post_id : pair.second) {
                if (!first_post_id) search_index_data_js_content += ",";
                search_index_data_js_content += "\"" + post_id + "\"";
                first_post_id = false;
            }
            search_index_data_js_content += "]";
            first_word = false;
        }
    } // Lock released here
    search_index_data_js_content += "};";

    search_index_data_js_content += "const postMetadata = {";
    bool first_meta = true;
    {
        std::lock_guard<std::mutex> lock(global_data_mutex); // Lock before accessing post_id_to_metadata
        for (const auto& pair : post_id_to_metadata) {
            if (!first_meta) search_index_data_js_content += ",";
            // Escape title quotes for JSON output
            std::string escaped_title = std::regex_replace(pair.second.title, std::regex("\""), "\\\"");
            search_index_data_js_content += "\"" + pair.first + "\":{\"title\":\"" + escaped_title + "\",\"date\":\"" + pair.second.date + "\",\"permalink\":\"" + pair.second.permalink + "\"}";
            first_meta = false;
        }
    } // Lock released here
    search_index_data_js_content += "};";

    std::string minified_search_index_data_js = minify_js(search_index_data_js_content);
    if (!write_file("public/search-index.js", minified_search_index_data_js)) return 1;
    if (!write_file("public/search-index.js.br", compress_brotli(minified_search_index_data_js))) return 1;

    std::cout << "✅ search-index.js generated and compressed." << std::endl;
    return 0;
}
