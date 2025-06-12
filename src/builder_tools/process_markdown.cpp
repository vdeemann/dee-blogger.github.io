#include "common_utils.h"
#include <iostream>
#include <regex>

namespace fs = std::filesystem;

// Main function to process a single markdown file
int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <markdown_file_path>" << std::endl;
        return 1;
    }

    fs::path md_file_path(argv[1]);
    std::string markdown_content = read_file(md_file_path);
    if (markdown_content.empty()) return 1;

    PostMetadata post;
    post.id = md_file_path.stem().string(); // filename without extension
    post.permalink = "p/" + post.id + ".html"; // This is relative to public/

    // Simplified Title and Date extraction (adjust regexes as needed for your frontmatter)
    std::smatch match;
    std::regex title_regex("^# (.+)\n"); // Assumes title is first H1
    if (std::regex_search(markdown_content, match, title_regex)) {
        post.title = match[1].str();
    } else {
        post.title = "Untitled Post " + post.id;
    }

    std::regex date_regex("^Date: (\\d{4}-\\d{2}-\\d{2})\n"); // Assumes Date: YYYY-MM-DD
    if (std::regex_search(markdown_content, match, date_regex)) {
        post.date = match[1].str();
    } else {
        post.date = "2000-01-01"; // Default date if not found
    }

    // Markdown to HTML conversion using cmark
    std::string post_html_body = convert_markdown_to_html(markdown_content);

    // Output PostMetadata and HTML body as JSON to stdout
    // This JSON will be piped to generate_pages and generate_search
    std::cout << post_metadata_to_json(post, post_html_body) << std::endl;

    return 0;
}
