#include "common_utils.h"
#include <iostream>

namespace fs = std::filesystem;

int main() {
    std::cout << "🚀 Cleaning public directory..." << std::endl;
    std::error_code ec;
    // Remove all existing content in public/
    fs::remove_all("public", ec);
    if (ec) {
        std::cerr << "Error removing public directory: " << ec.message() << std::endl;
        return 1;
    }
    // Recreate necessary base directories
    fs::create_directories("public/p", ec);
    if (ec) {
        std::cerr << "Error creating public/p directory: " << ec.message() << std::endl;
        return 1;
    }
    fs::create_directories("public/archive", ec);
    if (ec) {
        std::cerr << "Error creating public/archive directory: " << ec.message() << std::endl;
        return 1;
    }
    fs::create_directories("public/images", ec); // Ensure images directory exists in output
    if (ec) {
        std::cerr << "Error creating public/images directory: " << ec.message() << std::endl;
        return 1;
    }
    std::cout << "✅ Public directory cleaned and base structure created." << std::endl;
    return 0;
}
