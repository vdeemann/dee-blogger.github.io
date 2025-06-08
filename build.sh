#!/bin/bash
set -e

# Configuration
POSTS_PER_MAIN_PAGE=20
BASE_URL="${BASE_URL:-}"
SITE_TITLE="${SITE_TITLE:-My Blog}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR:${NC} $1" >&2
    exit 1
}

# Clean and create directories
log "Setting up directories..."
rm -rf public
mkdir -p public/p public/archive

# Validate content directory exists
[ ! -d "content" ] && error "content/ directory not found"

# Check if we have any markdown files
content_files=(content/*.md)
[ ! -f "${content_files[0]}" ] && error "No markdown files found in content/"

log "Building minimal blog..."

# Function to escape HTML entities
escape_html() {
    echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
}

# Function to extract date parts and format
parse_date() {
    filename="$1"
    basename=$(basename "$filename")
    date_part=$(echo "$basename" | cut -d- -f1-3)
    
    # Validate date format
    if ! echo "$date_part" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' >/dev/null; then
        warn "Invalid date format in filename: $basename (expected YYYY-MM-DD-title.md)"
        echo "1/1/00"
        return
    fi
    
    year=$(echo "$date_part" | cut -d- -f1)
    month=$(echo "$date_part" | cut -d- -f2)  
    day=$(echo "$date_part" | cut -d- -f3)
    
    # Remove leading zeros and format
    month=${month#0}
    day=${day#0}
    echo "$month/$day/${year#20}"
}

# Function to safely extract title
get_title() {
    file="$1"
    if [ ! -f "$file" ]; then
        echo "Untitled Post"
        return
    fi
    
    title=$(head -1 "$file" 2>/dev/null | sed 's/^# *//')
    [ -z "$title" ] && title="Untitled Post"
    # Escape HTML entities in title
    escape_html "$title"
}

# Function to safely extract excerpt
get_excerpt() {
    file="$1"
    if [ ! -f "$file" ]; then
        echo "..."
        return
    fi
    
    excerpt=$(sed -n '3p' "$file" 2>/dev/null)
    [ -z "$excerpt" ] && excerpt="..."
    # Escape HTML entities in excerpt
    escape_html "$excerpt"
}

# Simple markdown processing that's safer
process_content() {
    file="$1"
    if [ ! -f "$file" ]; then
        echo "<p>Content not found</p>"
        return
    fi
    
    # Read content starting from line 3, process line by line to avoid heredoc issues
    content=""
    in_code_block=false
    
    tail -n +3 "$file" 2>/dev/null | while IFS= read -r line; do
        # Handle code blocks
        if echo "$line" | grep -q '^```'; then
            if [ "$in_code_block" = true ]; then
                echo "</code></pre>"
                in_code_block=false
            else
                echo "<pre><code>"
                in_code_block=true
            fi
            continue
        fi
        
        # If in code block, escape and output as-is
        if [ "$in_code_block" = true ]; then
            escape_html "$line"
            continue
        fi
        
        # Empty lines become paragraph breaks
        if [ -z "$line" ]; then
            echo "</p><p>"
            continue
        fi
        
        # Headers
        if echo "$line" | grep -q '^### '; then
            echo "<h3>$(escape_html "$(echo "$line" | sed 's/^### //')")</h3>"
            continue
        fi
        
        if echo "$line" | grep -q '^## '; then
            echo "<h2>$(escape_html "$(echo "$line" | sed 's/^## //')")</h2>"
            continue
        fi
        
        if echo "$line" | grep -q '^# '; then
            echo "<h1>$(escape_html "$(echo "$line" | sed 's/^# //')")</h1>"
            continue
        fi
        
        # Lists
        if echo "$line" | grep -q '^- '; then
            echo "<li>$(escape_html "$(echo "$line" | sed 's/^- //')")</li>"
            continue
        fi
        
        if echo "$line" | grep -q '^\* '; then
            echo "<li>$(escape_html "$(echo "$line" | sed 's/^\* //')")</li>"
            continue
        fi
        
        # Regular paragraphs
        echo "<p>$(escape_html "$line")</p>"
    done | sed '
        # Clean up multiple paragraph tags
        s/<\/p><p>/<\/p>\n<p>/g
        s/^<\/p>//
        s/<p>$//'
}

# Generate CSS
generate_css() {
    cat << 'EOF'
body{max-width:42em;margin:2em auto;padding:0 1em;font-family:system-ui,-apple-system,sans-serif;line-height:1.6;color:#333;background:#fff}
@media(max-width:768px){body{margin:1em auto;padding:0 0.5em}}
a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}
h1{font-size:1.8em;margin-bottom:.5em;color:#222}
h2{font-size:1.3em;margin:2em 0 1em;color:#333}
h3{font-size:1.1em;margin:1.5em 0 .5em;color:#444}
p{margin-bottom:1em}
small{color:#666;display:block;margin-bottom:1em;font-size:.9em}
pre{background:#f8f9fa;padding:1em;margin:1.5em 0;border-radius:6px;overflow-x:auto;border-left:4px solid #0066cc}
code{font-family:'SF Mono',Monaco,monospace;font-size:.9em;background:#f1f3f4;padding:.2em .4em;border-radius:3px}
pre code{background:none;padding:0}
strong{font-weight:600}
em{font-style:italic}
nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #eee}
ul,ol{margin:1em 0;padding-left:2em}
li{margin:.5em 0}
.post{margin-bottom:2em;padding:1.2em;background:#fafbfc;border-radius:8px;border:1px solid #e1e8ed}
.post:hover{background:#f5f8fa;border-color:#d1d9e0;transition:all 0.2s ease}
input{width:100%;max-width:100%;box-sizing:border-box;margin-bottom:1em;padding:.7em;border:1px solid #d1d9e0;border-radius:6px;font-size:1em}
input:focus{outline:none;border-color:#0066cc;box-shadow:0 0 0 3px rgba(0,102,204,0.1)}
.archive-link,.stats{background:#e8f5e8;padding:1.2em;border-radius:8px;margin:2em 0;text-align:center;border:1px solid #4caf50}
.stats{background:#fff8e1;border-color:#ff9800}
.meta{margin:1em 0;padding:.5em 0;border-top:1px solid #eee;text-align:center}
@media(prefers-color-scheme:dark){
body{background:#1a1a1a;color:#e0e0e0}
.post{background:#2d2d2d;border-color:#404040}
.post:hover{background:#333;border-color:#555}
pre{background:#2d2d2d;border-left-color:#0099ff}
code{background:#404040}
input{background:#2d2d2d;color:#e0e0e0;border-color:#555}
.archive-link{background:#1e3d1e;border-color:#2e7d2e}
.stats{background:#3d3d1e;border-color:#7d7d2e}
a{color:#4da6ff}
}
EOF
}

# Create simple sorted file list
log "Creating post lookup..."
sorted_files=()
while IFS= read -r -d '' file; do
    [ -f "$file" ] && sorted_files+=("$file")
done < <(find content -name "*.md" -type f -print0 | sort -z)

total_posts=${#sorted_files[@]}
log "Found $total_posts markdown files"

# Generate individual post pages with safer file writing
log "Generating individual posts..."
post_count=0
for ((i=0; i<${#sorted_files[@]}; i++)); do
    file="${sorted_files[$i]}"
    post_num=$((i+1))
    
    log "Processing file $post_num: $(basename "$file")"
    
    # Skip if file doesn't exist or isn't readable
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        warn "Skipping unreadable file: $file"
        continue
    fi
    
    # Extract metadata with error handling
    filename=$(basename "$file")
    short_date=$(parse_date "$file")
    title=$(get_title "$file")
    
    log "Title extracted: $title"
    
    # Process content with error handling - save to temp file first
    temp_content="/tmp/content_$$.tmp"
    if ! process_content "$file" > "$temp_content"; then
        warn "Failed to process content for: $file"
        echo "<p>Content processing failed</p>" > "$temp_content"
    fi
    
    log "Content processed, size: $(wc -c < "$temp_content") bytes"
    
    # Generate navigation
    nav_links=""
    if [ $post_num -gt 1 ]; then
        nav_links="<a href=\"$((post_num-1)).html\">← Previous</a> | "
    fi
    nav_links="${nav_links}<a href=\"../\">Home</a>"
    if [ $post_num -lt $total_posts ]; then
        nav_links="${nav_links} | <a href=\"$((post_num+1)).html\">Next →</a>"
    fi
    
    # Create post file by writing parts separately to avoid heredoc issues
    post_file="public/p/$post_num.html"
    
    # Write HTML header
    cat > "$post_file" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
EOF
    
    # Write title
    echo "<title>$title - $SITE_TITLE</title>" >> "$post_file"
    
    # Write CSS
    echo "<style>" >> "$post_file"
    generate_css >> "$post_file"
    echo "</style>" >> "$post_file"
    
    # Write body start
    cat >> "$post_file" << 'EOF'
</head>
<body>
<nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav>
EOF
    
    # Write title and date
    echo "<h1>$title</h1>" >> "$post_file"
    echo "<small>$short_date</small>" >> "$post_file"
    
    # Write content
    cat "$temp_content" >> "$post_file"
    
    # Write navigation and footer
    echo "<nav style=\"border-top:1px solid #eee;border-bottom:0;margin-top:2em\">$nav_links</nav>" >> "$post_file"
    echo "</body></html>" >> "$post_file"
    
    # Clean up temp file
    rm -f "$temp_content"
    
    log "Generated: $title (#$post_num)"
    ((post_count++))
done

# Generate main index page
log "Generating main index page..."
{
    cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>$SITE_TITLE</title>
<style>$(generate_css)</style>
</head>
<body>
<h1>$SITE_TITLE</h1>
<input id="s" placeholder="Search recent posts..." onkeyup="searchPosts()">
<div id="posts">
EOF
    
    # Add recent posts (newest first, reverse the array)
    count=0
    for ((i=${#sorted_files[@]}-1; i>=0 && count<$POSTS_PER_MAIN_PAGE; i--)); do
        file="${sorted_files[$i]}"
        post_num=$((i+1))
        
        [ ! -f "$file" ] && continue
        
        filename=$(basename "$file")
        short_date=$(parse_date "$file")
        title=$(get_title "$file")
        excerpt=$(get_excerpt "$file")
        
        echo "<div class=\"post\"><small>$short_date</small><h2><a href=\"p/$post_num.html\">$title</a></h2><p>$excerpt</p></div>"
        ((count++))
    done
    
    echo "</div>"
    
    # Add archive link if we have more posts
    if [ $total_posts -gt $POSTS_PER_MAIN_PAGE ]; then
        echo "<div class=\"archive-link\">📚 <a href=\"archive/\">View all $total_posts posts in archive</a> 📚</div>"
    fi
    
    cat << 'EOF'
<script>
let originalPosts, postsContainer = document.getElementById("posts");
function searchPosts() {
    const query = document.getElementById("s").value.toLowerCase();
    if (!originalPosts) originalPosts = postsContainer.innerHTML;
    
    if (!query) {
        postsContainer.innerHTML = originalPosts;
        return;
    }
    
    const posts = Array.from(postsContainer.children);
    const filtered = posts.filter(post => 
        post.textContent.toLowerCase().includes(query)
    );
    
    postsContainer.innerHTML = filtered.length ? 
        filtered.map(post => post.outerHTML).join("") :
        '<div class="post"><p>No posts found in recent posts. <a href="archive/">Search all posts</a></p></div>';
}
</script>
</body>
</html>
EOF
} > public/index.html

# Generate archive page
log "Generating archive page..."
{
    cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Archive - $SITE_TITLE</title>
<style>$(generate_css)</style>
</head>
<body>
<nav><a href="../">← Home</a></nav>
<h1>All Posts</h1>
<div class="stats">📊 Total: $total_posts posts | 🔍 All searchable below</div>
<input id="s" placeholder="Search all posts..." onkeyup="searchPosts()">
<div id="posts">
EOF
    
    # Add all posts to archive (newest first)
    for ((i=${#sorted_files[@]}-1; i>=0; i--)); do
        file="${sorted_files[$i]}"
        post_num=$((i+1))
        
        [ ! -f "$file" ] && continue
        
        filename=$(basename "$file")
        short_date=$(parse_date "$file")
        title=$(get_title "$file")
        excerpt=$(get_excerpt "$file")
        
        echo "<div class=\"post\"><small>$short_date</small><h2><a href=\"../p/$post_num.html\">$title</a></h2><p>$excerpt</p></div>"
    done
    
    cat << 'EOF'
</div>
<script>
let originalPosts, postsContainer = document.getElementById("posts");
function searchPosts() {
    const query = document.getElementById("s").value.toLowerCase();
    if (!originalPosts) originalPosts = postsContainer.innerHTML;
    
    if (!query) {
        postsContainer.innerHTML = originalPosts;
        return;
    }
    
    const posts = Array.from(postsContainer.children);
    const filtered = posts.filter(post => 
        post.textContent.toLowerCase().includes(query)
    );
    
    postsContainer.innerHTML = filtered.length ? 
        filtered.map(post => post.outerHTML).join("") :
        '<div class="post"><p>No posts found</p></div>';
}
</script>
</body>
</html>
EOF
} > public/archive/index.html

# Generate sitemap
log "Generating sitemap..."
{
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
    echo "  <url><loc>$BASE_URL</loc><priority>1.0</priority></url>"
    echo "  <url><loc>$BASE_URL/archive/</loc><priority>0.8</priority></url>"
    
    for ((i=0; i<${#sorted_files[@]}; i++)); do
        post_num=$((i+1))
        echo "  <url><loc>$BASE_URL/p/$post_num.html</loc><priority>0.6</priority></url>"
    done
    
    echo '</urlset>'
} > public/sitemap.xml

# Calculate sizes
main_size=$(wc -c < public/index.html)
archive_size=$(wc -c < public/archive/index.html)
sitemap_size=$(wc -c < public/sitemap.xml)

log "✅ Built $post_count posts successfully!"
log "📦 Main page: $main_size bytes (recent $POSTS_PER_MAIN_PAGE posts)"
log "📚 Archive: $archive_size bytes (all $total_posts posts)"
log "🗺️  Sitemap: $sitemap_size bytes"
log "🚀 Blog is ready!"

# Validate output
[ ! -f "public/index.html" ] && error "Failed to generate main page"
[ ! -f "public/archive/index.html" ] && error "Failed to generate archive"
[ $post_count -eq 0 ] && error "No posts were generated"

log "✅ All validation checks passed!"
