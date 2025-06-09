#!/bin/bash
set -e

echo "🚀 Building improved blog with consistent UI and better search..."

SITE_TITLE="${SITE_TITLE:-dee-blogger}"
BASE_URL="${BASE_URL:-https://vdeemann.github.io/dee-blogger.github.io}"

# Clean and create directories
rm -rf public
mkdir -p public/p public/archive

# Consistent CSS for both main and archive pages
read -r -d '' SHARED_CSS << 'EOF' || true
body{max-width:45em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.5;color:#333;background:#fff}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.9em;margin:0 0 .5em;color:#1a1a1a;font-weight:700}h2{font-size:1.2em;margin:0 0 .3em;color:#333;font-weight:600}h3{font-size:1.1em;margin:1.5em 0 .5em;color:#444;font-weight:600}p{margin:.4em 0}small{color:#666;display:block;margin:0 0 .5em;font-size:.9em}.post{margin:0 0 .8em;padding:.6em .8em;background:#fafafa;border-radius:4px;border:1px solid #e8e8e8;transition:all .2s ease}.post:hover{background:#f5f5f5;border-color:#ddd;transform:translateY(-1px);box-shadow:0 2px 4px rgba(0,0,0,.1)}input{width:100%;margin:0 0 1em;padding:.6em;border:1px solid #ddd;border-radius:4px;font-size:.95em;background:#fff;box-sizing:border-box}nav{margin:1em 0;padding:.5em 0;border-bottom:1px solid #eee}.stats{background:#fff3cd;padding:.6em 1em;border-radius:4px;margin:1em 0;text-align:center;font-size:.95em;border:1px solid #ffeaa7}.search-highlight{background:#ffeb3b;padding:0 .2em;border-radius:2px}.excerpt{color:#666;margin:.3em 0 0;font-size:.9em;line-height:1.4}.search-results{background:#e8f4fd;padding:.8em;border-radius:4px;margin:1em 0;border-left:4px solid #0066cc}.no-results{text-align:center;color:#666;padding:2em;font-style:italic}.search-count{font-weight:600;color:#0066cc}
EOF

# Post page CSS
read -r -d '' POST_CSS << 'EOF' || true
body{max-width:45em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.6;color:#333}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.9em;margin:0 0 .4em;color:#1a1a1a;font-weight:700}h2{font-size:1.4em;margin:2em 0 1em;color:#333;font-weight:600}h3{font-size:1.2em;margin:1.5em 0 .6em;color:#444;font-weight:600}p{margin:1em 0}small{color:#666;display:block;margin:0 0 1.5em;font-size:.95em}strong{font-weight:600}code{background:#f6f8fa;color:#24292e;padding:.15em .4em;border-radius:3px;font-family:Monaco,Consolas,monospace;font-size:.9em}pre{background:#f6f8fa;padding:.5em .7em;margin:1em 0;border-radius:5px;overflow-x:auto;border:1px solid #e1e4e8}pre code{background:0;padding:0;font-size:.85em;color:#24292e;display:block}ul,ol{margin:1em 0;padding-left:1.8em}li{margin:.4em 0}nav{margin:1.6em 0;padding:.6em 0;border-bottom:1px solid #eee}blockquote{background:#f6f8fa;border-left:4px solid #0066cc;margin:1.6em 0;padding:1em 1.6em;border-radius:0 6px 6px 0;color:#586069;font-style:italic}
EOF

# Enhanced markdown processor
process_markdown() {
    local file="$1"
    
    # Skip frontmatter (lines starting with # for title)
    tail -n +2 "$file" | awk '
    BEGIN { in_code = 0; in_list = 0 }
    
    # Code blocks
    /^```/ {
        if (in_code) {
            print "</code></pre>"
            in_code = 0
        } else {
            print "<pre><code>"
            in_code = 1
        }
        next
    }
    
    # Skip processing inside code blocks
    in_code { print; next }
    
    # Headers
    /^### / { gsub(/^### /, ""); print "<h3>" $0 "</h3>"; next }
    /^## / { gsub(/^## /, ""); print "<h2>" $0 "</h2>"; next }
    /^# / { gsub(/^# /, ""); print "<h1>" $0 "</h1>"; next }
    
    # Lists
    /^[•*-] / {
        if (!in_list) {
            print "<ul>"
            in_list = 1
        }
        gsub(/^[•*-] /, "")
        print "<li>" $0 "</li>"
        next
    }
    
    # End list if we hit non-list content
    in_list && !/^[•*-] / && !/^$/ {
        print "</ul>"
        in_list = 0
    }
    
    # Empty lines
    /^$/ { 
        if (in_list) {
            print "</ul>"
            in_list = 0
        }
        next 
    }
    
    # Regular paragraphs
    /./ {
        if (in_list) {
            print "</ul>"
            in_list = 0
        }
        
        # Inline formatting
        gsub(/\*\*([^*]+)\*\*/, "<strong>\\1</strong>")
        gsub(/`([^`]+)`/, "<code>\\1</code>")
        gsub(/\[([^\]]+)\]\(([^)]+)\)/, "<a href=\"\\2\">\\1</a>")
        
        print "<p>" $0 "</p>"
    }
    
    # Clean up at end
    END {
        if (in_code) print "</code></pre>"
        if (in_list) print "</ul>"
    }'
}

# Extract clean excerpt from content
extract_excerpt() {
    local file="$1"
    local excerpt=$(tail -n +2 "$file" | head -20 | grep -v '^#' | grep -v '^$' | head -3 | tr '\n' ' ' | sed 's/[*`#\[\]()]/./g' | cut -c1-200)
    echo "$excerpt" | sed 's/\.\.\.*/.../'
}

# Get all markdown files and process them
echo "📁 Processing markdown files..."
files=($(find content -name "*.md" | sort))
total=${#files[@]}

if [ $total -eq 0 ]; then
    echo "❌ No markdown files found in content/ directory"
    exit 1
fi

echo "📊 Found $total markdown files"

# Process each post
declare -A post_data
for i in "${!files[@]}"; do
    file="${files[$i]}"
    
    # Extract metadata
    title=$(head -n1 "$file" | sed 's/^# *//')
    slug=$(basename "$file" .md)
    num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "$((i + 1))")
    date=$(echo "$slug" | grep -o '^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' | tr - / || echo "$(date +%Y/%m/%d)")
    excerpt=$(extract_excerpt "$file")
    
    # Store data for later use
    post_data["$num,title"]="$title"
    post_data["$num,date"]="$date"
    post_data["$num,excerpt"]="$excerpt"
    post_data["$num,file"]="$file"
    
    # Generate individual post page
    content=$(process_markdown "$file")
    
    cat > "public/p/${num}.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${title} - ${SITE_TITLE}</title>
    <meta name="description" content="${excerpt:0:160}">
    <style>${POST_CSS}</style>
</head>
<body>
    <nav><a href="../">← Home</a> | <a href="../archive/">Archive</a></nav>
    <h1>${title}</h1>
    <small>${date}</small>
    ${content}
    <nav style="border-top:1px solid #eee;margin-top:2em;padding-top:1em">
        <a href="../">← Back to Home</a> | <a href="../archive/">Archive</a>
    </nav>
</body>
</html>
EOF

    echo "✅ Processed: $num - $title"
done

# Generate main page (recent 20 posts)
echo "🏠 Generating main page..."
{
    cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${SITE_TITLE}</title>
    <meta name="description" content="A blog with ${total} posts">
    <style>${SHARED_CSS}</style>
</head>
<body>
    <h1>${SITE_TITLE}</h1>
    <div class="stats">📊 ${total} posts published</div>
    <input id="search" placeholder="🔍 Search posts..." onkeyup="searchPosts()" autocomplete="off">
    <div id="search-info" class="search-results" style="display:none">
        <span id="search-count">0</span> posts found
    </div>
    <div id="posts">
EOF

    # Get recent posts (last 20, sorted by filename which includes date)
    recent_posts=($(printf '%s\n' "${files[@]}" | sort -r | head -20))
    
    for file in "${recent_posts[@]}"; do
        slug=$(basename "$file" .md)
        num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "1")
        title="${post_data["$num,title"]}"
        date="${post_data["$num,date"]}"
        excerpt="${post_data["$num,excerpt"]}"
        
        cat << EOF
        <div class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}">
            <small>${date}</small>
            <h2><a href="p/${num}.html">${title}</a></h2>
            <div class="excerpt">${excerpt}...</div>
        </div>
EOF
    done

    cat << 'EOF'
    </div>
    <nav style="margin-top:2em">
        <p>📚 <a href="archive/">View all posts in Archive →</a></p>
    </nav>

    <script>
        let originalPosts = '';
        const searchInput = document.getElementById('search');
        const postsContainer = document.getElementById('posts');
        const searchInfo = document.getElementById('search-info');
        const searchCount = document.getElementById('search-count');
        
        function searchPosts() {
            const query = searchInput.value.toLowerCase().trim();
            
            if (!originalPosts) originalPosts = postsContainer.innerHTML;
            
            if (!query) {
                postsContainer.innerHTML = originalPosts;
                searchInfo.style.display = 'none';
                return;
            }
            
            const posts = Array.from(postsContainer.children);
            const filtered = posts.filter(post => {
                const searchable = post.dataset.searchable || '';
                return searchable.includes(query);
            });
            
            if (filtered.length > 0) {
                postsContainer.innerHTML = filtered.map(post => {
                    let html = post.outerHTML;
                    // Simple highlight
                    const regex = new RegExp(`(${query})`, 'gi');
                    html = html.replace(regex, '<span class="search-highlight">$1</span>');
                    return html;
                }).join('');
            } else {
                postsContainer.innerHTML = '<div class="no-results">No posts found matching your search.</div>';
            }
            
            searchCount.textContent = filtered.length;
            searchInfo.style.display = 'block';
        }
        
        // Real-time search
        searchInput.addEventListener('input', searchPosts);
    </script>
</body>
</html>
EOF
} > public/index.html

# Generate archive page (ALL posts, no pagination)
echo "📚 Generating archive page with all posts..."
{
    cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Archive - ${SITE_TITLE}</title>
    <meta name="description" content="Archive of all ${total} posts">
    <style>${SHARED_CSS}</style>
</head>
<body>
    <nav><a href="../">← Home</a></nav>
    <h1>Archive</h1>
    <div class="stats">📊 ${total} posts total</div>
    <input id="search" placeholder="🔍 Search all posts..." onkeyup="searchArchive()" autocomplete="off">
    <div id="search-info" class="search-results" style="display:none">
        <span id="search-count">0</span> of ${total} posts found
    </div>
    <div id="archive">
EOF

    # Group posts by year
    declare -A years
    for file in "${files[@]}"; do
        slug=$(basename "$file" .md)
        year=$(echo "$slug" | cut -d- -f1)
        years["$year"]+="$file "
    done

    # Display all posts grouped by year
    for year in $(printf '%s\n' "${!years[@]}" | sort -nr); do
        echo "        <div class=\"year-section\">"
        echo "            <h2>$year</h2>"
        
        # Get files for this year and sort them by date (newest first)
        year_files=($(printf '%s\n' ${years[$year]} | sort -r))
        
        for file in "${year_files[@]}"; do
            slug=$(basename "$file" .md)
            num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "1")
            title="${post_data["$num,title"]}"
            date="${post_data["$num,date"]}"
            excerpt="${post_data["$num,excerpt"]}"
            
            cat << EOF
            <div class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}">
                <small>${date}</small>
                <h3><a href="../p/${num}.html">${title}</a></h3>
                <div class="excerpt">${excerpt}...</div>
            </div>
EOF
        done
        echo "        </div>"
    done

    cat << 'EOF'
    </div>

    <script>
        let originalArchive = '';
        const searchInput = document.getElementById('search');
        const archiveContainer = document.getElementById('archive');
        const searchInfo = document.getElementById('search-info');
        const searchCount = document.getElementById('search-count');
        
        function searchArchive() {
            const query = searchInput.value.toLowerCase().trim();
            
            if (!originalArchive) originalArchive = archiveContainer.innerHTML;
            
            if (!query) {
                archiveContainer.innerHTML = originalArchive;
                searchInfo.style.display = 'none';
                return;
            }
            
            const posts = Array.from(archiveContainer.querySelectorAll('.post'));
            const filtered = posts.filter(post => {
                const searchable = post.dataset.searchable || '';
                return searchable.includes(query);
            });
            
            if (filtered.length > 0) {
                let html = '<div class="year-section"><h2>Search Results</h2>';
                html += filtered.map(post => {
                    let postHtml = post.outerHTML;
                    // Simple highlight
                    const regex = new RegExp(`(${query})`, 'gi');
                    postHtml = postHtml.replace(regex, '<span class="search-highlight">$1</span>');
                    return postHtml;
                }).join('');
                html += '</div>';
                archiveContainer.innerHTML = html;
            } else {
                archiveContainer.innerHTML = '<div class="no-results">No posts found matching your search.</div>';
            }
            
            searchCount.textContent = filtered.length;
            searchInfo.style.display = 'block';
        }
        
        // Real-time search
        searchInput.addEventListener('input', searchArchive);
    </script>
</body>
</html>
EOF
} > public/archive/index.html

echo "✅ Blog build completed successfully!"
echo "📊 Generated:"
echo "  - Main page with ${#recent_posts[@]} recent posts"
echo "  - Archive page with all $total posts"
echo "  - $total individual post pages"
echo "  - Enhanced search functionality"
echo "  - Consistent UI styling"
