#!/bin/bash
set -e

echo "🚀 Building dee-blogger with bulletproof processing..."

# Configuration
SITE_TITLE="${SITE_TITLE:-dee-blogger}"
BASE_URL="${BASE_URL:-https://vdeemann.github.io/dee-blogger.github.io}"
CONTENT_DIR="${CONTENT_DIR:-content}"
MAX_POSTS_MAIN="${MAX_POSTS_MAIN:-20}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Clean and create directories
log_info "Setting up directory structure..."
rm -rf public
mkdir -p public/p public/archive

# Create CSS files
log_info "Creating optimized CSS..."
cat > /tmp/shared.css << 'EOF'
body{max-width:832px;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.5;color:#333;background:#fff}a{color:#0066cc;text-decoration:none;transition:color .2s ease}a:hover{color:#0052a3;text-decoration:underline}h1{font-size:1.9em;margin:0 0 .5em;color:#1a1a1a;font-weight:700}h2{font-size:1.2em;margin:0 0 .3em;color:#333;font-weight:600}h3{font-size:1.1em;margin:0 0 .3em;color:#444;font-weight:600}p{margin:.4em 0}small{color:#666;display:block;margin:0 0 .3em;font-size:.9em}.post{margin:0 0 .6em;padding:.5em .7em;background:#fafafa;border-radius:4px;border:1px solid #e8e8e8;cursor:pointer;transition:all .2s ease}.post:hover{background:#f0f0f0;border-color:#ddd;transform:translateY(-1px)}input{width:100%;margin:0 0 1em;padding:.6em;border:1px solid #ddd;border-radius:4px;font-size:.95em;background:#fff;box-sizing:border-box;transition:border-color .2s ease,box-shadow .2s ease}input:focus{outline:0;border-color:#0066cc;box-shadow:0 0 0 3px rgba(0,102,204,.1)}nav{margin:1em 0;padding:.5em 0;border-bottom:1px solid #eee}.stats{background:#fff3cd;padding:.6em 1em;border-radius:4px;margin:1em 0;text-align:center;font-size:.95em;border:1px solid #ffeaa7}.search-highlight{background:#ffeb3b;padding:0 .2em;border-radius:2px}.excerpt{color:#666;margin:.3em 0 0;font-size:.9em;line-height:1.4}.search-results{background:#e8f4fd;padding:.8em;border-radius:4px;margin:1em 0;border-left:4px solid #0066cc}.no-results{text-align:center;color:#666;padding:2em;font-style:italic}.search-count{font-weight:600;color:#0066cc}.sticky-header{position:sticky;top:0;background:#fff;border-bottom:2px solid #0066cc;padding:.8em 0;margin:0 0 1em;z-index:100;box-shadow:0 2px 4px rgba(0,0,0,.1);display:none}.sticky-header h2{margin:0 0 .5em;font-size:1.1em;color:#0066cc;font-weight:700}.sticky-header input{margin:0;padding:.5em;font-size:.9em}.archive-content{margin:2em 0}.year-section{margin:0 0 2.5em}.month-section{margin:0 0 1.5em}.year-header{margin:0 0 1em}.month-header{margin:0 0 .8em;font-size:.95em;color:#666}
EOF

cat > /tmp/post.css << 'EOF'
body{max-width:832px;margin:2em auto;padding:0 1em;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;line-height:1.45;color:#1a1a1a;background:#fff;font-size:15px}a{color:#0969da;text-decoration:none;transition:color .15s ease}a:hover{color:#0550ae;text-decoration:underline}h1{font-size:1.85em;margin:0 0 .4em;color:#0d1117;font-weight:600;line-height:1.15}h2{font-size:1.35em;margin:1.8em 0 .6em;color:#0d1117;font-weight:600;line-height:1.2}h3{font-size:1.15em;margin:1.4em 0 .5em;color:#24292f;font-weight:600;line-height:1.25}p{margin:.8em 0;font-size:15px;line-height:1.45}small{color:#656d76;display:block;margin:0 0 1.5em;font-size:14px;font-weight:400}strong{font-weight:600;color:#0d1117}em{font-style:italic}code{background:#f6f8fa;color:#cf222e;padding:.1em .25em;border-radius:3px;font-family:ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,monospace;font-size:13px;border:1px solid #d0d7de}pre{background:#f6f8fa;padding:.75em;margin:1.2em 0;border-radius:6px;overflow-x:auto;border:1px solid #d0d7de;line-height:1.35}pre code{background:0;padding:0;font-size:13px;color:#24292f;display:block;border:0}ul,ol{margin:1em 0;padding-left:1.8em;line-height:1.45}li{margin:.4em 0;line-height:1.45}nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #d0d7de}blockquote{background:#f6f8fa;border-left:3px solid #0969da;margin:1.2em 0;padding:.8em 1.2em;border-radius:0 6px 6px 0;color:#656d76;font-style:italic;line-height:1.4}blockquote p{margin:.6em 0}hr{border:0;height:1px;background:#d0d7de;margin:2em 0}.post-meta{background:#f6f8fa;padding:.8em 1em;border-radius:6px;margin:1.2em 0;border-left:3px solid #0969da}.post-meta p{margin:.2em 0;font-size:13px;color:#656d76;line-height:1.4}
EOF

# Create JavaScript files
log_info "Creating JavaScript..."
cat > /tmp/search.js << 'EOF'
let originalPosts = null;
const searchInput = document.getElementById('search');
const postsContainer = document.getElementById('posts');
const searchInfo = document.getElementById('search-info');
const searchCount = document.getElementById('search-count');

function searchPosts() {
    const query = searchInput.value.toLowerCase().trim();
    
    if (originalPosts === null) {
        originalPosts = postsContainer.innerHTML;
    }
    
    if (query === '' || query.length === 0) {
        postsContainer.innerHTML = originalPosts;
        searchInfo.style.display = 'none';
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
    
    searchCount.textContent = filtered.length;
    searchInfo.style.display = 'block';
}

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
EOF

cat > /tmp/archive.js << 'EOF'
let originalArchive = null;
const searchMainInput = document.getElementById('search-main');
const searchStickyInput = document.getElementById('search-sticky');
const archiveContainer = document.getElementById('archive');
const searchInfo = document.getElementById('search-info');
const searchCount = document.getElementById('search-count');
const stickyHeader = document.getElementById('sticky-header');
const stickyTitle = document.getElementById('sticky-title');

function updateStickyHeader() {
    const scrollTop = window.pageYOffset;
    const searchMainRect = searchMainInput.getBoundingClientRect();
    
    if (searchMainRect.bottom < 0) {
        stickyHeader.style.display = 'block';
        if (searchStickyInput.value !== searchMainInput.value) {
            searchStickyInput.value = searchMainInput.value;
        }
    } else {
        stickyHeader.style.display = 'none';
    }
}

function searchArchive() {
    const mainQuery = searchMainInput.value.toLowerCase().trim();
    const stickyQuery = searchStickyInput.value.toLowerCase().trim();
    const query = mainQuery || stickyQuery;
    
    if (mainQuery !== stickyQuery) {
        if (searchMainInput === document.activeElement) {
            searchStickyInput.value = searchMainInput.value;
        } else if (searchStickyInput === document.activeElement) {
            searchMainInput.value = searchStickyInput.value;
        }
    }
    
    if (originalArchive === null) {
        originalArchive = archiveContainer.innerHTML;
    }
    
    if (query === '' || query.length === 0) {
        archiveContainer.innerHTML = originalArchive;
        searchInfo.style.display = 'none';
        updateStickyHeader();
        return;
    }
    
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = originalArchive;
    const allPosts = Array.from(tempDiv.querySelectorAll('.post'));
    
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
        
        const searchResultsHTML = '<div class="year-section"><div class="year-header"><h2>Search Results</h2></div><div class="month-section">' + highlightedResults + '</div></div>';
        archiveContainer.innerHTML = searchResultsHTML;
    } else {
        archiveContainer.innerHTML = '<div class="no-results">No posts found matching "' + query + '"</div>';
    }
    
    searchCount.textContent = filtered.length;
    searchInfo.style.display = 'block';
}

let searchTimeout;
[searchMainInput, searchStickyInput].forEach(input => {
    input.addEventListener('input', function(e) {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(searchArchive, 300);
    });
    
    input.addEventListener('keyup', function(e) {
        if (e.key === 'Escape') {
            searchMainInput.value = '';
            searchStickyInput.value = '';
            searchArchive();
        }
    });
});

window.addEventListener('scroll', updateStickyHeader);
window.addEventListener('resize', updateStickyHeader);
EOF

# Simple markdown processor using basic shell commands
process_markdown() {
    local file="$1"
    
    # Skip the first line (title) and process content
    tail -n +2 "$file" | while IFS= read -r line; do
        # Skip empty lines
        if [ -z "$line" ]; then
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
        # Code blocks (simple detection)
        elif echo "$line" | grep -q "^```"; then
            echo '<pre><code>'
        # Lists (simple)
        elif echo "$line" | grep -q "^[[:space:]]*[*-]"; then
            echo "$line" | sed 's/^[[:space:]]*[*-][[:space:]]/<li>/' | sed 's/$/<\/li>/'
        elif echo "$line" | grep -q "^[[:space:]]*[0-9]"; then
            echo "$line" | sed 's/^[[:space:]]*[0-9][0-9]*\.[[:space:]]/<li>/' | sed 's/$/<\/li>/'
        # Regular paragraphs
        else
            # Apply inline formatting
            formatted_line="$line"
            # Bold
            formatted_line=$(echo "$formatted_line" | sed 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g')
            # Italic
            formatted_line=$(echo "$formatted_line" | sed 's/\*\([^*]*\)\*/<em>\1<\/em>/g')
            # Code
            formatted_line=$(echo "$formatted_line" | sed 's/`\([^`]*\)`/<code>\1<\/code>/g')
            # Links
            formatted_line=$(echo "$formatted_line" | sed 's/\[\([^]]*\)\](\([^)]*\))/<a href="\2">\1<\/a>/g')
            
            echo "<p>$formatted_line</p>"
        fi
    done
}

# Extract excerpt from content
extract_excerpt() {
    local file="$1"
    
    # Get first few meaningful lines
    local content=$(tail -n +2 "$file" | grep -v '^#' | grep -v '^```' | grep -v '^$' | head -3 | tr '\n' ' ')
    
    if [ -z "$content" ]; then
        echo "Read more..."
        return
    fi
    
    # Clean and truncate
    local excerpt=$(echo "$content" | sed 's/[*`#\[\]()]/ /g' | sed 's/  */ /g' | cut -c1-180)
    
    # Add ellipsis if needed
    if [ ${#excerpt} -ge 170 ]; then
        echo "$excerpt" | sed 's/ [^ ]*$/.../'
    else
        echo "$excerpt"
    fi
}

# Extract post number from filename
extract_post_number() {
    local file="$1"
    local filename=$(basename "$file" .md)
    
    # Try different strategies
    if [[ "$filename" =~ ^[0-9]+$ ]]; then
        echo "$filename"
    elif [[ "$filename" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})-(.+)$ ]]; then
        # Date-based filename: use date + hash
        local year="${BASH_REMATCH[1]}"
        local month="${BASH_REMATCH[2]}"
        local day="${BASH_REMATCH[3]}"
        local slug="${BASH_REMATCH[4]}"
        local hash=$(echo "$slug" | cksum | cut -d' ' -f1)
        echo "${year}${month}${day}${hash: -3}"
    elif [[ "$filename" =~ ^([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    elif [[ "$filename" =~ ([0-9]+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        # Hash of entire filename
        echo "$filename" | cksum | cut -d' ' -f1
    fi
}

# Extract date information
extract_date() {
    local file="$1"
    local filename=$(basename "$file" .md)
    
    # Date from filename
    if [[ "$filename" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
        local year="${BASH_REMATCH[1]}"
        local month="${BASH_REMATCH[2]}"
        local day="${BASH_REMATCH[3]}"
        echo "$year/$month/$day|$year$month$day|$year|$month|$day"
    else
        # Use current date
        echo "$(date '+%Y/%m/%d|%Y%m%d|%Y|%m|%d')"
    fi
}

# Extract title from file
extract_title() {
    local file="$1"
    local filename=$(basename "$file" .md)
    
    # Try to get title from first line
    local title=$(head -n1 "$file" | sed 's/^# *//' | sed 's/[<>&"'"'"']/./g')
    
    if [ -n "$title" ] && [ "$title" != "." ]; then
        echo "$title"
    elif [[ "$filename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-(.+)$ ]]; then
        # Convert filename to title
        local slug="${BASH_REMATCH[1]}"
        echo "$slug" | sed 's/-/ /g' | sed 's/\b\w/\U&/g'
    else
        # Use filename as title
        echo "$filename" | sed 's/-/ /g' | sed 's/\b\w/\U&/g'
    fi
}

# Get month name
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
        *) echo "Unknown" ;;
    esac
}

# Main processing
log_info "Discovering markdown files..."

if [ ! -d "$CONTENT_DIR" ]; then
    log_error "Content directory '$CONTENT_DIR' not found!"
    exit 1
fi

files=($(find "$CONTENT_DIR" -name "*.md" -type f | sort))
total=${#files[@]}

if [ $total -eq 0 ]; then
    log_error "No markdown files found in $CONTENT_DIR/"
    exit 1
fi

log_success "Found $total markdown files"

# Process each file
declare -A post_data
processed_count=0

log_info "Processing files..."

for i in "${!files[@]}"; do
    file="${files[$i]}"
    
    printf "\r🔄 Processing: %d/%d (%s)" $((i + 1)) $total "$(basename "$file")"
    
    # Skip if file is not readable
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        continue
    fi
    
    # Extract metadata
    title=$(extract_title "$file")
    num=$(extract_post_number "$file")
    date_info=$(extract_date "$file")
    
    # Parse date
    IFS='|' read -r date sort_date year month day <<< "$date_info"
    
    excerpt=$(extract_excerpt "$file")
    
    # Validate
    if [ -z "$title" ] || [ -z "$num" ]; then
        continue
    fi
    
    # Handle duplicates
    if [ -n "${post_data["$num,title"]}" ]; then
        num="${num}_$(echo "$file" | cksum | cut -d' ' -f1 | tail -c 4)"
    fi
    
    # Store data
    post_data["$num,title"]="$title"
    post_data["$num,date"]="$date"
    post_data["$num,excerpt"]="$excerpt"
    post_data["$num,file"]="$file"
    post_data["$num,year"]="$year"
    post_data["$num,month"]="$month"
    post_data["$num,day"]="$day"
    post_data["$num,sort_date"]="$sort_date"
    
    # Process content
    content=$(process_markdown "$file")
    word_count=$(echo "$content" | wc -w)
    reading_time=$(echo "$word_count" | awk '{print int($1/200)+1}')
    
    # Generate post page
    cat > "public/p/${num}.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${title} - ${SITE_TITLE}</title>
    <meta name="description" content="${excerpt:0:160}">
    <style>$(cat /tmp/post.css)</style>
</head>
<body>
    <nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav>
    <article>
        <h1>${title}</h1>
        <small>${date}</small>
        <div class="post-meta">
            <p><strong>Published:</strong> ${date}</p>
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
    
    ((processed_count++))
done

echo # New line after progress

log_success "Processed $processed_count files"

# Get processed post numbers
processed_nums=($(for key in "${!post_data[@]}"; do
    [[ "$key" == *",title" ]] && echo "${key%,title}"
done | sort -n))

if [ ${#processed_nums[@]} -eq 0 ]; then
    log_error "No posts were successfully processed!"
    exit 1
fi

# Generate main page
log_info "Generating main page..."

recent_nums=($(for num in "${processed_nums[@]}"; do
    echo "${post_data["$num,sort_date"]} $num"
done | sort -rn | head -$MAX_POSTS_MAIN | cut -d' ' -f2))

cat > public/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${SITE_TITLE}</title>
    <meta name="description" content="A blog with ${#processed_nums[@]} posts">
    <style>$(cat /tmp/shared.css)</style>
</head>
<body>
    <h1>${SITE_TITLE}</h1>
    <div class="stats">📊 ${#processed_nums[@]} posts published</div>
    
    <input id="search" placeholder="Search posts..." autocomplete="off">
    <div id="search-info" class="search-results" style="display:none">
        <span id="search-count">0</span> posts found
    </div>
    
    <div id="posts">
EOF

for num in "${recent_nums[@]}"; do
    title="${post_data["$num,title"]}"
    date="${post_data["$num,date"]}"
    excerpt="${post_data["$num,excerpt"]}"
    
    [ -z "$title" ] && continue
    
    cat >> public/index.html << EOF
        <article class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}" onclick="window.location.href='p/${num}.html'">
            <small>${date}</small>
            <h2><a href="p/${num}.html">${title}</a></h2>
            <div class="excerpt">${excerpt}</div>
        </article>
EOF
done

cat >> public/index.html << EOF
    </div>
    
    <nav style="margin-top:2em">
        <p>📚 <a href="archive/">View all ${#processed_nums[@]} posts in Archive →</a></p>
    </nav>
    
    <script>$(cat /tmp/search.js)</script>
</body>
</html>
EOF

# Generate archive page
log_info "Generating archive..."

sorted_nums=($(for num in "${processed_nums[@]}"; do
    echo "${post_data["$num,sort_date"]} $num"
done | sort -rn | cut -d' ' -f2))

# Group by year/month
declare -A year_months
for num in "${sorted_nums[@]}"; do
    year="${post_data["$num,year"]}"
    month="${post_data["$num,month"]}"
    ym="$year-$month"
    year_months["$ym"]+="$num "
done

cat > public/archive/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Archive - ${SITE_TITLE}</title>
    <meta name="description" content="Archive of all ${#processed_nums[@]} posts">
    <style>$(cat /tmp/shared.css)</style>
</head>
<body>
    <nav><a href="../">← Home</a></nav>
    <h1>Archive</h1>
    <div class="stats">📊 ${#processed_nums[@]} posts chronologically ordered</div>
    
    <input id="search-main" placeholder="Search all posts..." autocomplete="off">
    <div id="search-info" class="search-results" style="display:none">
        <span id="search-count">0</span> of ${#processed_nums[@]} posts found
    </div>
    
    <div id="sticky-header" class="sticky-header">
        <h2 id="sticky-title">Timeline</h2>
        <input id="search-sticky" placeholder="Search all posts..." autocomplete="off">
    </div>
    
    <div class="archive-content" id="archive">
EOF

current_year=""
for ym in $(printf '%s\n' "${!year_months[@]}" | sort -rn); do
    year=$(echo "$ym" | cut -d- -f1)
    month=$(echo "$ym" | cut -d- -f2)
    month_name=$(get_month_name "$month")
    
    if [ "$year" != "$current_year" ]; then
        [ -n "$current_year" ] && echo "        </div>" >> public/archive/index.html
        echo "        <div class=\"year-section\" data-year=\"$year\">" >> public/archive/index.html
        echo "            <div class=\"year-header\"><h2>$year</h2></div>" >> public/archive/index.html
        current_year="$year"
    fi
    
    echo "            <div class=\"month-section\" data-month=\"$month\" data-year-month=\"$year $month_name\">" >> public/archive/index.html
    echo "                <div class=\"month-header\"><h3>$month_name</h3></div>" >> public/archive/index.html
    
    month_nums=($(printf '%s\n' ${year_months[$ym]} | xargs -n1 | while read num; do
        echo "${post_data["$num,sort_date"]} $num"
    done | sort -rn | cut -d' ' -f2))
    
    for num in "${month_nums[@]}"; do
        title="${post_data["$num,title"]}"
        date="${post_data["$num,date"]}"
        excerpt="${post_data["$num,excerpt"]}"
        
        cat >> public/archive/index.html << EOF
                <article class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}" onclick="window.location.href='../p/${num}.html'">
                    <small>${date}</small>
                    <h3><a href="../p/${num}.html">${title}</a></h3>
                    <div class="excerpt">${excerpt}</div>
                </article>
EOF
    done
    echo "            </div>" >> public/archive/index.html
done

[ -n "$current_year" ] && echo "        </div>" >> public/archive/index.html

cat >> public/archive/index.html << EOF
    </div>
    
    <script>$(cat /tmp/archive.js)</script>
</body>
</html>
EOF

# Cleanup
rm -f /tmp/shared.css /tmp/post.css /tmp/search.js /tmp/archive.js

log_success "Build completed successfully!"
echo
echo "📊 FINAL STATISTICS:"
echo "  ✅ Processed: $processed_count files"
echo "  ✅ Main page: ${#recent_nums[@]} recent posts"
echo "  ✅ Archive: ${#processed_nums[@]} posts organized"
echo "  ✅ Individual pages: ${#processed_nums[@]} generated"
echo
echo "🌐 Your blog is ready!"

if [ $processed_count -ne $total ]; then
    log_warning "Some files were skipped during processing"
fi
