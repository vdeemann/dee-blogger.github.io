#include "common_utils.h"
#include <iostream>
#include <vector>
#include <algorithm>
#include <regex>
#include <sstream> // For std::istringstream

namespace fs = std::filesystem;

// Constants (These are external configurations. In a larger project,
// they might be passed as command-line arguments or read from a config file.)
const std::string SITE_TITLE = "dee-blogger";
const std::string BASE_URL = "https://vdeemann.github.io/dee-blogger.github.io";


int main() {
    std::cout << "Building HTML pages..." << std::endl;

    // Read template contents once
    std::string index_template_content = read_file("src/blog_content/templates/index.html.template");
    std::string post_template_content = read_file("src/blog_content/templates/post.html.template");
    std::string archive_template_content = read_file("src/blog_content/templates/archive.html.template");

    if (index_template_content.empty() || post_template_content.empty() || archive_template_content.empty()) {
        std::cerr << "Error: Could not read HTML templates. Exiting." << std::endl;
        return 1;
    }

    std::vector<PostMetadata> all_posts_data;
    std::string line;
    // Read JSON post metadata (each line is one JSON object) from stdin
    while (std::getline(std::cin, line)) {
        if (line.empty()) continue;
        PostMetadata post = post_metadata_from_json(line);
        all_posts_data.push_back(post);
    }

    // Sort posts by date (newest first)
    std::sort(all_posts_data.begin(), all_posts_data.end(),
              [](const PostMetadata& a, const PostMetadata& b) {
                  return a.date > b.date; // Sort descending by date (YYYY-MM-DD string comparison works)
              });

    // Generate individual post HTML pages
    for (const auto& post : all_posts_data) {
        std::string final_post_html = post_template_content;
        final_post_html = std::regex_replace(final_post_html, std::regex("\\{\\{SITE_TITLE\\}\\}"), SITE_TITLE);
        final_post_html = std::regex_replace(final_post_html, std::regex("\\{\\{BASE_URL\\}\\}"), BASE_URL);
        final_post_html = std::regex_replace(final_post_html, std::regex("\\{\\{POST_TITLE\\}\\}"), post.title);
        final_post_html = std::regex_replace(final_post_html, std::regex("\\{\\{POST_DATE\\}\\}"), post.date);
        final_post_html = std::regex_replace(final_post_html, std::regex("\\{\\{POST_BODY_HTML\\}\\}"), post.html_body); // Use HTML body from parsed JSON
        final_post_html = std::regex_replace(final_post_html, std::regex("\\{\\{PERMALINK\\}\\}"), post.permalink);

        std::string minified_post_html = minify_html(final_post_html);
        fs::path output_html_path = fs::path("public/p") / (post.id + ".html");
        if (!write_file(output_html_path, minified_post_html)) return 1;
        if (!write_file(output_html_path.string() + ".br", compress_brotli(minified_post_html))) return 1;
    }
    std::cout << "✅ Individual post pages generated and compressed." << std::endl;

    // Generate index.html (main page with recent posts)
    std::string index_posts_html_list;
    int post_display_count = 0;
    for (const auto& post : all_posts_data) {
        if (post_display_count < 10) { // Limit to 10 most recent posts
            index_posts_html_list += "<li><h2><a href=\"" + post.permalink + "\">" + post.title + "</a></h2><p class=\"post-meta\">" + post.date + "</p></li>";
        }
        post_display_count++;
    }

    std::string final_index_html = index_template_content;
    final_index_html = std::regex_replace(final_index_html, std::regex("\\{\\{SITE_TITLE\\}\\}"), SITE_TITLE);
    final_index_html = std::regex_replace(final_index_html, std::regex("\\{\\{BASE_URL\\}\\}"), BASE_URL);
    final_index_html = std::regex_replace(final_index_html, std::regex("\\{\\{RECENT_POSTS_LIST\\}\\}"), index_posts_html_list);
    final_index_html = std::regex_replace(final_index_html, std::regex("\\{\\{TOTAL_POSTS_COUNT\\}\\}"), std::to_string(all_posts_data.size()));

    std::string minified_index_html = minify_html(final_index_html);
    if (!write_file("public/index.html", minified_index_html)) return 1;
    if (!write_file("public/index.html.br", compress_brotli(minified_index_html))) return 1;
    std::cout << "✅ index.html generated and compressed." << std::endl;


    // Generate archive/index.html (complete archive)
    std::string archive_posts_html_list;
    for (const auto& post : all_posts_data) {
        archive_posts_html_list += "<li><h2><a href=\"../" + post.permalink + "\">" + post.title + "</a></h2><p class=\"post-meta\">" + post.date + "</p></li>";
    }

    std::string final_archive_html = archive_template_content;
    final_archive_html = std::regex_replace(final_archive_html, std::regex("\\{\\{SITE_TITLE\\}\\}"), SITE_TITLE);
    final_archive_html = std::regex_replace(final_archive_html, std::regex("\\{\\{BASE_URL\\}\\}"), BASE_URL);
    final_archive_html = std::regex_replace(final_archive_html, std::regex("\\{\\{ALL_POSTS_LIST\\}\\}"), archive_posts_html_list);

    std::string minified_archive_html = minify_html(final_archive_html);
    if (!write_file("public/archive/index.html", minified_archive_html)) return 1;
    if (!write_file("public/archive/index.html.br", compress_brotli(minified_archive_html))) return 1;
    std::cout << "✅ archive/index.html generated and compressed." << std::endl;

    return 0;
}
