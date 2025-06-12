#include "common_utils.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <regex>
#include <cctype> // For std::isspace, std::isalnum, std::tolower

// Initialize global variables (defined as extern in header)
std::map<std::string, std::set<std::string>> inverted_index;
std::map<std::string, PostMetadata> post_id_to_metadata;
std::mutex global_data_mutex;

// --- Utility Functions ---

std::string read_file(const fs::path& path) {
    std::ifstream file(path);
    if (!file.is_open()) {
        std::cerr << "Error: Could not open file " << path << std::endl;
        return "";
    }
    std::string content((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
    return content;
}

bool write_file(const fs::path& path, const std::string& content) {
    // std::ios::binary is important for Brotli compressed output
    // For uncompressed text files, it generally makes no difference on Unix-like systems.
    std::ofstream file(path, std::ios::binary);
    if (!file.is_open()) {
        std::cerr << "Error: Could not create file " << path << std::endl;
        return false;
    }
    file << content;
    return true;
}

bool copy_file(const fs::path& source, const fs::path& destination) {
    std::error_code ec;
    fs::copy(source, destination, fs::copy_options::overwrite_existing, ec);
    if (ec) {
        std::cerr << "Error copying file from " << source << " to " << destination << ": " << ec.message() << std::endl;
        return false;
    }
    return true;
}

// --- Markdown to HTML Conversion (using cmark) ---
std::string convert_markdown_to_html(const std::string& markdown_content) {
    cmark_node* document = cmark_parse_document(markdown_content.c_str(), markdown_content.length(), CMARK_OPT_DEFAULT);
    if (!document) {
        std::cerr << "Error: Failed to parse markdown document." << std::endl;
        return "";
    }

    std::string html_output = cmark_render_html(document, CMARK_OPT_DEFAULT, nullptr);
    cmark_node_free(document);
    return html_output;
}

// --- Minification Functions ---
// (These are basic minifiers. For production, consider more robust libraries or external tools.)

std::string minify_html(const std::string& html) {
    std::string minified_html;
    minified_html.reserve(html.length());

    bool in_tag = false;
    bool in_script = false;
    bool in_style = false;
    bool in_comment = false;
    // prev_char helps detect comment start/end sequences more accurately
    char prev_char = 0;

    for (size_t i = 0; i < html.length(); ++i) {
        char c = html[i];

        // Detect comments <!-- -->
        if (i + 3 < html.length() && html[i] == '<' && html[i+1] == '!' && html[i+2] == '-' && html[i+3] == '-') {
            in_comment = true;
            i += 3; // Skip to last char of "<!--"
            continue;
        }
        if (in_comment) {
            if (i + 2 < html.length() && html[i] == '-' && html[i+1] == '-' && html[i+2] == '>') {
                in_comment = false;
                i += 2; // Skip "-->"
            }
            continue;
        }

        // Detect script and style tags to avoid minifying their content aggressively
        // This is a simplification; a full HTML parser would be more robust.
        if (i + 6 < html.length() && html.substr(i, 7) == "<script") in_script = true;
        if (i + 7 < html.length() && html.substr(i, 8) == "</script") in_script = false;
        if (i + 5 < html.length() && html.substr(i, 6) == "<style") in_style = true;
        if (i + 6 < html.length() && html.substr(i, 7) == "</style") in_style = false;


        if (c == '<') {
            in_tag = true;
            minified_html += c;
        } else if (c == '>') {
            in_tag = false;
            minified_html += c;
        } else if (std::isspace(c)) {
            // Only add a single space if not inside a tag, script, or style
            // and previous char wasn't a space (avoid multiple spaces)
            if (!in_tag && !in_script && !in_style) {
                if (minified_html.empty() || !std::isspace(minified_html.back())) {
                    minified_html += ' ';
                }
            } else {
                 // Preserve single space within tags, collapse multiple spaces
                 if (minified_html.empty() || (!std::isspace(minified_html.back()) || !std::isspace(c)) ) {
                     minified_html += c;
                 }
            }
        } else {
            minified_html += c;
        }
        prev_char = c; // Update previous character for comment detection
    }
    // Final trim of leading/trailing spaces
    if (!minified_html.empty() && std::isspace(minified_html.front())) {
        minified_html.erase(0, minified_html.find_first_not_of(" \t\n\r\f\v"));
    }
    if (!minified_html.empty() && std::isspace(minified_html.back())) {
        minified_html.pop_back();
    }
    return minified_html;
}

std::string minify_css(const std::string& css) {
    std::string minified_css;
    minified_css.reserve(css.length());

    bool in_multi_comment = false;
    for (size_t i = 0; i < css.length(); ++i) {
        if (i + 1 < css.length() && css[i] == '/' && css[i+1] == '*') {
            in_multi_comment = true;
            i++; // Skip '*'
            continue;
        }
        if (in_multi_comment) {
            if (i + 1 < css.length() && css[i] == '*' && css[i+1] == '/') {
                in_multi_comment = false;
                i++; // Skip '/'
            }
            continue;
        }
        if (!in_multi_comment) {
            char c = css[i];
            if (std::isspace(c)) {
                // Collapse multiple spaces, newlines, tabs to single space,
                // and remove spaces around certain punctuation
                if (!minified_css.empty() && (minified_css.back() == '{' || minified_css.back() == '}' || minified_css.back() == ':' || minified_css.back() == ';')) {
                    // Do nothing
                } else if (i + 1 < css.length() && (css[i+1] == '{' || css[i+1] == '}' || css[i+1] == ':' || css[i+1] == ';')) {
                    // Do nothing
                } else if (!minified_css.empty() && !std::isspace(minified_css.back())) {
                    minified_css += ' ';
                }
            } else if (c == ';' && i + 1 < css.length() && css[i+1] == '}') {
                // Remove semicolon if it's the last char before closing brace
            } else if (c == '{' || c == '}' || c == ':' || c == ';') {
                // Remove space before these characters
                if (!minified_css.empty() && minified_css.back() == ' ') {
                    minified_css.pop_back();
                }
                minified_css += c;
            } else {
                minified_css += c;
            }
        }
    }
    size_t first = minified_css.find_first_not_of(" \t\n\r\f\v");
    size_t last = minified_css.find_last_not_of(" \t\n\r\f\v");
    if (std::string::npos == first) return "";
    return minified_css.substr(first, (last - first + 1));
}

std::string minify_js(const std::string& js) {
    std::string minified_js;
    minified_js.reserve(js.length());

    bool in_single_comment = false;
    bool in_multi_comment = false;
    bool in_string_single = false;
    bool in_string_double = false;

    for (size_t i = 0; i < js.length(); ++i) {
        char c = js[i];

        // Handle string literals first to avoid minifying content inside
        if (c == '\'' && !in_string_double && !in_multi_comment && !in_single_comment) {
            in_string_single = !in_string_single;
        } else if (c == '\"' && !in_string_single && !in_multi_comment && !in_single_comment) {
            in_string_double = !in_string_double;
        }

        if (in_string_single || in_string_double) {
            minified_js += c;
            continue;
        }

        // Handle comments
        if (i + 1 < js.length() && c == '/' && js[i+1] == '/') {
            in_single_comment = true;
            continue;
        }
        if (i + 1 < js.length() && c == '/' && js[i+1] == '*') {
            in_multi_comment = true;
            i++; // Skip '*'
            continue;
        }
        if (in_single_comment) {
            if (c == '\n') {
                in_single_comment = false;
                minified_js += c; // Keep newline after single-line comments for JS
            }
            continue;
        }
        if (in_multi_comment) {
            if (i + 1 < js.length() && c == '*' && js[i+1] == '/') {
                in_multi_comment = false;
                i++; // Skip '/'
            }
            continue;
        }

        // Remove excess whitespace
        if (std::isspace(c)) {
            // Only add space if not already a space and not next to certain punctuation
            if (!minified_js.empty() && !std::isspace(minified_js.back()) &&
                !(minified_js.back() == '(' || minified_js.back() == '[' || minified_js.back() == '{' ||
                  c == ')' || c == ']' || c == '}') &&
                !(i + 1 < js.length() && (js[i+1] == ')' || js[i+1] == ']' || js[i+1] == '}'))) {
                minified_js += ' ';
            }
        } else {
            // Remove space if it's before certain punctuation
            if (!minified_js.empty() && minified_js.back() == ' ' &&
                (c == ';' || c == ',' || c == '{' || c == '}' || c == '(' || c == ')' ||
                 c == '[' || c == ']' || c == ':')) {
                minified_js.pop_back();
            }
            minified_js += c;
        }
    }
    // Final trim of leading/trailing spaces
    if (!minified_js.empty() && std::isspace(minified_js.front())) {
        minified_js.erase(0, minified_js.find_first_not_of(" \t\n\r\f\v"));
    }
    if (!minified_js.empty() && std::isspace(minified_js.back())) {
        minified_js.pop_back();
    }
    return minified_js;
}

// --- Brotli Compression Function ---
std::string compress_brotli(const std::string& data) {
    if (data.empty()) return "";
    // Avoid compressing very small data or non-text data if it's likely to increase size
    // The BrotliEncoderMaxCompressedSize call also handles cases where input_size is too small.
    // Generally, Brotli handles non-compressible data efficiently by outputting it uncompressed.
    // Setting quality 0-11, where 11 is slowest but best compression.
    // For static site assets, high quality is good as it's a one-time cost.
    const int quality = BROTLI_DEFAULT_QUALITY; // Or BROTLI_MAX_QUALITY (11) for best ratio

    size_t input_size = data.length();
    size_t compressed_size = BrotliEncoderMaxCompressedSize(input_size);
    std::vector<uint8_t> compressed_buffer(compressed_size);

    int result = BrotliEncoderCompress(
        quality,
        BROTLI_DEFAULT_WINDOW,
        BROTLI_MODE_TEXT, // Most of our content is text (HTML, CSS, JS)
        input_size,
        reinterpret_cast<const uint8_t*>(data.data()),
        &compressed_size,
        compressed_buffer.data()
    );

    if (result != BROTLI_TRUE) {
        // std::cerr << "Brotli compression failed! Result: " << result << std::endl;
        return ""; // Return empty string on failure
    }
    return std::string(reinterpret_cast<char*>(compressed_buffer.data()), compressed_size);
}

// --- Search Index Functions ---

std::vector<std::string> tokenize(const std::string& text) {
    std::vector<std::string> tokens;
    std::string current_token;
    for (char c : text) {
        if (std::isalnum(c)) {
            current_token += static_cast<char>(std::tolower(c));
        } else {
            if (!current_token.empty()) {
                tokens.push_back(current_token);
                current_token.clear();
            }
        }
    }
    if (!current_token.empty()) {
        tokens.push_back(current_token);
    }
    return tokens;
}

void add_to_inverted_index(const std::string& post_id, const std::string& content_to_index) {
    std::vector<std::string> tokens = tokenize(content_to_index);
    std::lock_guard<std::mutex> lock(global_data_mutex); // Protect global index
    for (const std::string& token : tokens) {
        if (token.length() > 2) { // Minimum token length to avoid common small words like "the", "a", "is"
            inverted_index[token].insert(post_id);
        }
    }
}

// --- JSON Utilities for inter-tool communication ---
// These are simple manual JSON creations. For more robust JSON, use a library like nlohmann/json.

std::string post_metadata_to_json(const PostMetadata& post, const std::string& html_body_content) {
    std::ostringstream oss;
    oss << "{";
    oss << "\"id\":\"" << post.id << "\",";
    // Escape quotes in title
    std::string escaped_title = std::regex_replace(post.title, std::regex("\""), "\\\"");
    oss << "\"title\":\"" << escaped_title << "\",";
    oss << "\"date\":\"" << post.date << "\",";
    oss << "\"permalink\":\"" << post.permalink << "\"";
    if (!html_body_content.empty()) {
        // Escape quotes and backslashes in HTML body
        std::string escaped_html_body = std::regex_replace(html_body_content, std::regex("\\\\"), "\\\\");
        escaped_html_body = std::regex_replace(escaped_html_body, std::regex("\""), "\\\"");
        escaped_html_body = std::regex_replace(escaped_html_body, std::regex("\n"), "\\n"); // Escape newlines too
        oss << ",\"html_body\":\"" << escaped_html_body << "\"";
    }
    oss << "}";
    return oss.str();
}

PostMetadata post_metadata_from_json(const std::string& json_str) {
    PostMetadata post;
    // This is a highly simplified JSON parsing.
    // In a real project with complex JSON, use a JSON parsing library (e.g., nlohmann/json)
    std::regex id_regex("\"id\":\"([^\"]+)\"");
    std::regex title_regex("\"title\":\"([^\"]+)\"");
    std::regex date_regex("\"date\":\"([^\"]+)\"");
    std::regex permalink_regex("\"permalink\":\"([^\"]+)\"");
    std::regex html_body_regex("\"html_body\":\"((?:[^\"\\\\]|\\\\[\"\\\\n])*)\""); // Handles escaped quotes/newlines

    std::smatch match;
    if (std::regex_search(json_str, match, id_regex)) post.id = match[1].str();
    if (std::regex_search(json_str, match, title_regex)) {
        std::string title_raw = match[1].str();
        post.title = std::regex_replace(title_raw, std::regex("\\\\\""), "\""); // Unescape quotes
    }
    if (std::regex_search(json_str, match, date_regex)) post.date = match[1].str();
    if (std::regex_search(json_str, match, permalink_regex)) post.permalink = match[1].str();
    if (std::regex_search(json_str, match, html_body_regex)) {
        std::string body_raw = match[1].str();
        body_raw = std::regex_replace(body_raw, std::regex("\\\\\""), "\""); // Unescape quotes
        body_raw = std::regex_replace(body_raw, std::regex("\\\\n"), "\n"); // Unescape newlines
        body_raw = std::regex_replace(body_raw, std::regex("\\\\\\\\"), "\\"); // Unescape backslashes
        post.html_body = body_raw;
    }

    return post;
}
