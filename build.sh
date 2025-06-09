#!/bin/bash
set -e

echo "🚀 Building dee-blogger with simple, bulletproof processing..."

# Configuration
SITE_TITLE="dee-blogger"
CONTENT_DIR="content"
MAX_POSTS_MAIN=20

# Clean and create directories
echo "ℹ️ Setting up directories..."
rm -rf public
mkdir -p public/p public/archive

# Create simple CSS
echo "ℹ️ Creating CSS..."
cat > public/style.css << 'EOF'
body {
    max-width: 832px;
    margin: 2em auto;
    padding: 0 1em;
    font-family: system-ui, sans-serif;
    line-height: 1.5;
    color: #333;
}

a {
    color: #0066cc;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

h1 {
    font-size: 1.9em;
    margin: 0 0 0.5em;
    color: #1a1a1a;
    font-weight: 700;
}

h2 {
    font-size: 1.2em;
    margin: 0 0 0.3em;
    color: #333;
    font-weight: 600;
}

h3 {
    font-size: 1.1em;
    margin: 0 0 0.3em;
    color: #444;
    font-weight: 600;
}

p {
    margin: 0.4em 0;
}

small {
    color: #666;
    display: block;
    margin: 0 0 0.3em;
    font-size: 0.9em;
}

.post {
    margin: 0 0 0.6em;
    padding: 0.5em 0.7em;
    background: #fafafa;
    border-radius: 4px;
    border: 1px solid #e8e8e8;
    cursor: pointer;
    transition: all 0.2s ease;
}

.post:hover {
    background: #f0f0f0;
    border-color: #ddd;
    transform: translateY(-1px);
}

input {
    width: 100%;
    margin: 0 0 1em;
    padding: 0.6em;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 0.95em;
    background: #fff;
    box-sizing: border-box;
}

input:focus {
    outline: 0;
    border-color: #0066cc;
    box-shadow: 0 0 0 3px rgba(0, 102, 204, 0.1);
}

nav {
    margin: 1em 0;
    padding: 0.5em 0;
    border-bottom: 1px solid #eee;
}

.stats {
    background: #fff3cd;
    padding: 0.6em 1em;
    border-radius: 4px;
    margin: 1em 0;
    text-align: center;
    font-size: 0.95em;
    border: 1px solid #ffeaa7;
}

.excerpt {
    color: #666;
    margin: 0.3em 0 0;
    font-size: 0.9em;
    line-height: 1.4;
}

.search-results {
    background: #e8f4fd;
    padding: 0.8em;
    border-radius: 4px;
    margin: 1em 0;
    border-left: 4px solid #0066cc;
}

.no-results {
    text-align: center;
    color: #666;
    padding: 2em;
    font-style: italic;
}

.search-highlight {
    background: #ffeb3b;
    padding: 0 0.2em;
    border-radius: 2px;
}

.year-section {
    margin: 0 0 2.5em;
}

.month-section {
    margin: 0 0 1.5em;
}

.year-header {
    margin: 0 0 1em;
}

.month-header {
    margin: 0 0 0.8em;
    font-size: 0.95em;
    color: #666;
}

.post-meta {
    background: #f6f8fa;
    padding: 0.8em 1em;
    border-radius: 6px;
    margin: 1.2em 0;
    border-left: 3px solid #0969da;
}

.post-meta p {
    margin: 0.2em 0;
    font-size: 13px;
    color: #656d76;
    line-height: 1.4;
}

strong {
    font-weight: 600;
}

em {
    font-style: italic;
}

code {
    background: #f6f8fa;
    color: #cf222e;
    padding: 0.1em 0.25em;
    border-radius: 3px;
    font-family: monospace;
    font-size: 13px;
    border: 1px solid #d0d7de;
}

pre {
    background: #f6f8fa;
    padding: 0.75em;
    margin: 1.2em 0;
    border-radius: 6px;
    overflow-x: auto;
    border: 1px solid #d0d7de;
}

blockquote {
    background: #f6f8fa;
    border-left: 3px solid #0969da;
    margin: 1.2em 0;
    padding: 0.8em 1.2em;
    border-radius: 0 6px 6px 0;
    color: #656d76;
    font-style: italic;
}

ul, ol {
    margin: 1em 0;
    padding-left: 1.8em;
}

li {
    margin: 0.4em 0;
}
EOF

# Create simple JavaScript
echo "ℹ️ Creating JavaScript..."
cat > public/search.js << 'EOF'
let originalPosts = null;

function searchPosts() {
    const searchInput = document.getElementById('search');
    const postsContainer = document.getElementById('posts');
    const searchInfo = document.getElementById('search-info');
    const searchCount = document.getElementById('search-count');
    
    const query = searchInput.value.toLowerCase().trim();
    
    if (originalPosts === null) {
        originalPosts = postsContainer.innerHTML;
    }
    
    if (query === '' || query.length === 0) {
        postsContainer.innerHTML = originalPosts;
        if (searchInfo) searchInfo.style.display = 'none';
        return;
    }
    
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = originalPosts;
    const allPosts = Array.from(tempDiv.children);
    
    const filtered = allPosts.filter(post => {
        const searchable = post.dataset.searchable || '';
        return searchable.includes(query);
    });
    
    if (filtered.length > 0) {
        const highlightedResults = filtered.map(post => {
            let html = post.outerHTML;
            const escapedQuery = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            const regex = new RegExp('(' + escapedQuery + ')', 'gi');
            html = html.replace(regex, '<span class="search-highlight">$1</span>');
            return html;
        }).join('');
        
        postsContainer.innerHTML = highlightedResults;
    } else {
        postsContainer.innerHTML = '<div class="no-results">No posts found matching "' + query + '"</div>';
    }
    
    if (searchCount) searchCount.textContent = filtered.length;
    if (searchInfo) searchInfo.style.display = 'block';
}

document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('search');
    if (searchInput) {
        let searchTimeout;
        searchInput.addEventListener('input', function(e) {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(searchPosts, 300);
        });
        
        searchInput.addEventListener('keyup', function(e) {
            if (e.key === 'Escape') {
                searchInput.value = '';
                searchPosts();
            }
        });
    }
});
EOF

# Helper functions
extract_title_from_file() {
    local file="$1"
    local title=""
    local filename=""
    
    # Try to get title from first line
    if [ -f "$file" ]; then
        title=$(head -n1 "$file" | sed 's/^# *//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    fi
    
    # If no title or empty, use filename
    if [ -z "$title" ] || [ "$title" = "#" ]; then
        filename=$(basename "$file" .md)
        # Convert date-prefixed filename to title
        if echo "$filename" | grep -q "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-"; then
            title=$(echo "$filename" | sed 's/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-//' | sed 's/-/ /g')
        else
            title=$(echo "$filename" | sed 's/-/ /g')
        fi
        
        # Capitalize words
        title=$(echo "$title" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    fi
    
    echo "$title"
}

extract_date_from_filename() {
    local file="$1"
    local filename=$(basename "$file" .md)
    
    # Extract date from filename like 2025-05-25-title
    if echo "$filename" | grep -q "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-"; then
        local year=$(echo "$filename" | cut -d- -f1)
        local month=$(echo "$filename" | cut -d- -f2)
        local day=$(echo "$filename" | cut -d- -f3)
        echo "$year/$month/$day"
    else
        # Use current date
        date '+%Y/%m/%d'
    fi
}

extract_sort_date() {
    local file="$1"
    local filename=$(basename "$file" .md)
    
    if echo "$filename" | grep -q "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-"; then
        local year=$(echo "$filename" | cut -d- -f1)
        local month=$(echo "$filename" | cut -d- -f2)
        local day=$(echo "$filename" | cut -d- -f3)
        echo "$year$month$day"
    else
        date '+%Y%m%d'
    fi
}

extract_post_number() {
    local file="$1"
    local filename=$(basename "$file" .md)
    
    # Use checksum of filename for unique number
    echo "$filename" | cksum | cut -d' ' -f1
}

extract_excerpt() {
    local file="$1"
    local content=""
    
    if [ -f "$file" ]; then
        # Get first few lines of actual content
        content=$(tail -n +2 "$file" | grep -v '^#' | grep -v '^$' | head -3 | tr '\n' ' ')
    fi
    
    if [ -z "$content" ]; then
        echo "Read more..."
    else
        # Truncate and clean
        echo "$content" | sed 's/[*`#\[\]()]/ /g' | sed 's/  */ /g' | cut -c1-150 | sed 's/[[:space:]]*$/.../'
    fi
}

process_markdown_simple() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "<p>Content not available.</p>"
        return
    fi
    
    # Skip first line (title) and process rest
    tail -n +2 "$file" | while IFS= read -r line; do
        # Skip empty lines
        if [ -z "$line" ]; then
            echo
            continue
        fi
        
        # Headers
        if echo "$line" | grep -q "^####"; then
            echo "$line" | sed 's/^#### /<h4>/' | sed 's/$/<\/h4>/'
        elif echo "$line" | grep -q "^###"; then
            echo "$line" | sed 's/^### /<h3>/' | sed 's/$/<\/h3>/'
        elif echo "$line" | grep -q "^##"; then
            echo "$line" | sed 's/^## /<h2>/' | sed 's/$/<\/h2>/'
        elif echo "$line" | grep -q "^#"; then
            echo "$line" | sed 's/^# /<h1>/' | sed 's/$/<\/h1>/'
        # Blockquotes
        elif echo "$line" | grep -q "^> "; then
            echo "$line" | sed 's/^> /<blockquote><p>/' | sed 's/$/<\/p><\/blockquote>/'
        # Lists
        elif echo "$line" | grep -q "^[[:space:]]*[*-][[:space:]]"; then
            echo "$line" | sed 's/^[[:space:]]*[*-][[:space:]]/<li>/' | sed 's/$/<\/li>/'
        elif echo "$line" | grep -q "^[[:space:]]*[0-9]"; then
            echo "$line" | sed 's/^[[:space:]]*[0-9][0-9]*\.[[:space:]]/<li>/' | sed 's/$/<\/li>/'
        else
            # Regular paragraph with basic formatting
            formatted=$(echo "$line" | sed 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g')
            formatted=$(echo "$formatted" | sed 's/\*\([^*]*\)\*/<em>\1<\/em>/g')
            formatted=$(echo "$formatted" | sed 's/`\([^`]*\)`/<code>\1<\/code>/g')
            echo "<p>$formatted</p>"
        fi
    done
}

get_month_name() {
    case "$1" in
        01) echo "January" ;;
        02) echo "February" ;;
        03) echo "March" ;;
        04) echo "April" ;;
        05) echo "May" ;;
        06) echo "June" ;;
        07) echo "July" ;;
        08) echo "August" ;;
        09) echo "September" ;;
        10) echo "October" ;;
        11) echo "November" ;;
        12) echo "December" ;;
        *) echo "Month" ;;
    esac
}

# Main processing
echo "ℹ️ Finding markdown files..."

if [ ! -d "$CONTENT_DIR" ]; then
    echo "❌ Content directory not found: $CONTENT_DIR"
    exit 1
fi

files=$(find "$CONTENT_DIR" -name "*.md" -type f | sort)
total=$(echo "$files" | wc -l)

if [ $total -eq 0 ]; then
    echo "❌ No markdown files found"
    exit 1
fi

echo "✅ Found $total markdown files"

# Process files
echo "ℹ️ Processing files..."

# Create temporary files for data
post_list_file="/tmp/post_list.txt"
post_data_file="/tmp/post_data.txt"

> "$post_list_file"
> "$post_data_file"

count=0
for file in $files; do
    count=$((count + 1))
    printf "\r🔄 Processing: %d/%d (%s)" "$count" "$total" "$(basename "$file")"
    
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        continue
    fi
    
    title=$(extract_title_from_file "$file")
    post_num=$(extract_post_number "$file")
    date_str=$(extract_date_from_filename "$file")
    sort_date=$(extract_sort_date "$file")
    excerpt=$(extract_excerpt "$file")
    
    if [ -z "$title" ]; then
        continue
    fi
    
    # Count words for reading time
    word_count=$(tail -n +2 "$file" | wc -w)
    reading_time=$(echo "$word_count / 200 + 1" | bc 2>/dev/null || echo "1")
    
    # Store data
    echo "$post_num|$title|$date_str|$sort_date|$excerpt|$file|$word_count|$reading_time" >> "$post_data_file"
    echo "$sort_date $post_num" >> "$post_list_file"
    
    # Generate individual post page
    content=$(process_markdown_simple "$file")
    
    cat > "public/p/${post_num}.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${title} - ${SITE_TITLE}</title>
    <meta name="description" content="${excerpt}">
    <link rel="stylesheet" href="../style.css">
</head>
<body>
    <nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav>
    <article>
        <h1>${title}</h1>
        <small>${date_str}</small>
        <div class="post-meta">
            <p><strong>Published:</strong> ${date_str}</p>
            <p><strong>Reading time:</strong> ~${reading_time} min (${word_count} words)</p>
        </div>
        ${content}
    </article>
    <nav style="border-top:1px solid #e2e8f0;margin-top:3em;padding-top:1.5em">
        <a href="../">← Back to Blog</a> | <a href="../archive/">Archive</a>
    </nav>
</body>
</html>
EOF
done

echo

processed=$(wc -l < "$post_data_file")
echo "✅ Processed $processed files"

if [ $processed -eq 0 ]; then
    echo "❌ No posts were processed successfully"
    exit 1
fi

# Generate main page
echo "ℹ️ Generating main page..."

recent_posts=$(sort -rn "$post_list_file" | head -$MAX_POSTS_MAIN | cut -d' ' -f2)

cat > public/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${SITE_TITLE}</title>
    <meta name="description" content="A blog with ${processed} posts">
    <link rel="stylesheet" href="style.css">
    <script src="search.js"></script>
</head>
<body>
    <h1>${SITE_TITLE}</h1>
    <div class="stats">📊 ${processed} posts published</div>
    
    <input id="search" placeholder="Search posts..." autocomplete="off">
    <div id="search-info" class="search-results" style="display:none">
        <span id="search-count">0</span> posts found
    </div>
    
    <div id="posts">
EOF

for post_num in $recent_posts; do
    post_data=$(grep "^$post_num|" "$post_data_file")
    if [ -n "$post_data" ]; then
        title=$(echo "$post_data" | cut -d'|' -f2)
        date_str=$(echo "$post_data" | cut -d'|' -f3)
        excerpt=$(echo "$post_data" | cut -d'|' -f5)
        
        cat >> public/index.html << EOF
        <article class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}" onclick="window.location.href='p/${post_num}.html'">
            <small>${date_str}</small>
            <h2><a href="p/${post_num}.html">${title}</a></h2>
            <div class="excerpt">${excerpt}</div>
        </article>
EOF
    fi
done

cat >> public/index.html << EOF
    </div>
    
    <nav style="margin-top:2em">
        <p>📚 <a href="archive/">View all ${processed} posts in Archive →</a></p>
    </nav>
</body>
</html>
EOF

# Generate archive page
echo "ℹ️ Generating archive..."

all_posts=$(sort -rn "$post_list_file" | cut -d' ' -f2)

cat > public/archive/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Archive - ${SITE_TITLE}</title>
    <meta name="description" content="Archive of all ${processed} posts">
    <link rel="stylesheet" href="../style.css">
    <script src="../search.js"></script>
</head>
<body>
    <nav><a href="../">← Home</a></nav>
    <h1>Archive</h1>
    <div class="stats">📊 ${processed} posts chronologically ordered</div>
    
    <input id="search" placeholder="Search all posts..." autocomplete="off">
    <div id="search-info" class="search-results" style="display:none">
        <span id="search-count">0</span> of ${processed} posts found
    </div>
    
    <div id="posts">
EOF

current_year=""
current_month=""

for post_num in $all_posts; do
    post_data=$(grep "^$post_num|" "$post_data_file")
    if [ -n "$post_data" ]; then
        title=$(echo "$post_data" | cut -d'|' -f2)
        date_str=$(echo "$post_data" | cut -d'|' -f3)
        excerpt=$(echo "$post_data" | cut -d'|' -f5)
        
        year=$(echo "$date_str" | cut -d'/' -f1)
        month=$(echo "$date_str" | cut -d'/' -f2)
        month_name=$(get_month_name "$month")
        
        if [ "$year" != "$current_year" ]; then
            if [ -n "$current_year" ]; then
                echo "        </div>" >> public/archive/index.html
                echo "    </div>" >> public/archive/index.html
            fi
            echo "    <div class=\"year-section\">" >> public/archive/index.html
            echo "        <div class=\"year-header\"><h2>$year</h2></div>" >> public/archive/index.html
            current_year="$year"
            current_month=""
        fi
        
        if [ "$month" != "$current_month" ]; then
            if [ -n "$current_month" ]; then
                echo "        </div>" >> public/archive/index.html
            fi
            echo "        <div class=\"month-section\">" >> public/archive/index.html
            echo "            <div class=\"month-header\"><h3>$month_name</h3></div>" >> public/archive/index.html
            current_month="$month"
        fi
        
        cat >> public/archive/index.html << EOF
            <article class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}" onclick="window.location.href='../p/${post_num}.html'">
                <small>${date_str}</small>
                <h3><a href="../p/${post_num}.html">${title}</a></h3>
                <div class="excerpt">${excerpt}</div>
            </article>
EOF
    fi
done

if [ -n "$current_month" ]; then
    echo "        </div>" >> public/archive/index.html
fi
if [ -n "$current_year" ]; then
    echo "    </div>" >> public/archive/index.html
fi

cat >> public/archive/index.html << EOF
    </div>
</body>
</html>
EOF

# Cleanup
rm -f "$post_list_file" "$post_data_file"

echo "✅ Build completed successfully!"
echo
echo "📊 STATISTICS:"
echo "  ✅ Total files processed: $processed"
echo "  ✅ Main page generated with recent posts"
echo "  ✅ Archive generated with chronological organization"
echo "  ✅ Individual post pages created"
echo
echo "🌐 Your blog is ready!"
