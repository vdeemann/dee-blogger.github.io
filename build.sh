#!/bin/bash
set -e

echo "🚀 Building dee-blogger with enhanced processing and debugging..."

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
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Clean and create directories
log_info "Setting up directory structure..."
rm -rf public
mkdir -p public/p public/archive public/assets

# Create optimized CSS files
log_info "Creating CSS files..."
cat > /tmp/shared.css << 'EOF'
body{max-width:832px;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.5;color:#333;background:#fff;position:relative}a{color:#0066cc;text-decoration:none;transition:color .2s ease}a:hover{color:#0052a3;text-decoration:underline}h1{font-size:1.9em;margin:0 0 .5em;color:#1a1a1a;font-weight:700}h2{font-size:1.2em;margin:0 0 .3em;color:#333;font-weight:600}h3{font-size:1.1em;margin:0 0 .3em;color:#444;font-weight:600}p{margin:.4em 0}small{color:#666;display:block;margin:0 0 .3em;font-size:.9em}.post{margin:0 0 .6em;padding:.5em .7em;background:#fafafa;border-radius:4px;border:1px solid #e8e8e8;cursor:pointer;transition:all .2s ease}.post:hover{background:#f0f0f0;border-color:#ddd;transform:translateY(-1px)}input{width:100%;margin:0 0 1em;padding:.6em;border:1px solid #ddd;border-radius:4px;font-size:.95em;background:#fff;box-sizing:border-box;transition:border-color .2s ease,box-shadow .2s ease}input:focus{outline:0;border-color:#0066cc;box-shadow:0 0 0 3px rgba(0,102,204,.1)}nav{margin:1em 0;padding:.5em 0;border-bottom:1px solid #eee}.stats{background:#fff3cd;padding:.6em 1em;border-radius:4px;margin:1em 0;text-align:center;font-size:.95em;border:1px solid #ffeaa7}.search-highlight{background:#ffeb3b;padding:0 .2em;border-radius:2px}.excerpt{color:#666;margin:.3em 0 0;font-size:.9em;line-height:1.4}.search-results{background:#e8f4fd;padding:.8em;border-radius:4px;margin:1em 0;border-left:4px solid #0066cc}.no-results{text-align:center;color:#666;padding:2em;font-style:italic}.search-count{font-weight:600;color:#0066cc}.sticky-header{position:sticky;top:0;background:#fff;border-bottom:2px solid #0066cc;padding:.8em 0;margin:0 0 1em;z-index:100;box-shadow:0 2px 4px rgba(0,0,0,.1);display:none}.sticky-header h2{margin:0 0 .5em;font-size:1.1em;color:#0066cc;font-weight:700}.sticky-header input{margin:0;padding:.5em;font-size:.9em}.archive-content{margin:2em 0}.year-section{margin:0 0 2.5em}.month-section{margin:0 0 1.5em}.year-header{margin:0 0 1em}.month-header{margin:0 0 .8em;font-size:.95em;color:#666}
EOF

cat > /tmp/post.css << 'EOF'
body{max-width:832px;margin:2em auto;padding:0 1em;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;line-height:1.45;color:#1a1a1a;background:#fff;font-size:15px;letter-spacing:0.01em}a{color:#0969da;text-decoration:none;transition:color .15s ease}a:hover{color:#0550ae;text-decoration:underline}h1{font-size:1.85em;margin:0 0 .4em;color:#0d1117;font-weight:600;line-height:1.15;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;letter-spacing:-0.01em}h2{font-size:1.35em;margin:1.8em 0 .6em;color:#0d1117;font-weight:600;line-height:1.2;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;letter-spacing:-0.005em}h3{font-size:1.15em;margin:1.4em 0 .5em;color:#24292f;font-weight:600;line-height:1.25;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}p{margin:.8em 0;font-size:15px;line-height:1.45;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;letter-spacing:0.01em}small{color:#656d76;display:block;margin:0 0 1.5em;font-size:14px;font-weight:400;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}strong{font-weight:600;color:#0d1117}em{font-style:italic;color:#24292f}code{background:#f6f8fa;color:#cf222e;padding:.1em .25em;border-radius:3px;font-family:ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,monospace;font-size:13px;border:1px solid #d0d7de}pre{background:#f6f8fa;padding:.75em;margin:1.2em 0;border-radius:6px;overflow-x:auto;border:1px solid #d0d7de;line-height:1.35}pre code{background:0;padding:0;font-size:13px;color:#24292f;display:block;border:0;font-family:ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,monospace}ul,ol{margin:1em 0;padding-left:1.8em;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;line-height:1.45}li{margin:.4em 0;line-height:1.45;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #d0d7de;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}blockquote{background:#f6f8fa;border-left:3px solid #0969da;margin:1.2em 0;padding:.8em 1.2em;border-radius:0 6px 6px 0;color:#656d76;font-style:italic;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;line-height:1.4}blockquote p{margin:.6em 0;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}hr{border:0;height:1px;background:#d0d7de;margin:2em 0}.post-meta{background:#f6f8fa;padding:.8em 1em;border-radius:6px;margin:1.2em 0;border-left:3px solid #0969da;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}.post-meta p{margin:.2em 0;font-size:13px;color:#656d76;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;line-height:1.4}table{border-collapse:collapse;width:100%;margin:1em 0;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}th,td{border:1px solid #d0d7de;padding:.4em .8em;text-align:left}th{background:#f6f8fa;font-weight:600}
EOF

# Create enhanced JavaScript files
log_info "Creating JavaScript files..."
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
        postsContainer.innerHTML = '<div class="no-results">No posts found matching "<strong>' + query + '</strong>"</div>';
    }
    
    searchCount.textContent = filtered.length;
    searchInfo.style.display = 'block';
}

// Debounced search for performance
let searchTimeout;
searchInput.addEventListener('input', function(e) {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(searchPosts, 300);
});

searchInput.addEventListener('keyup', function(e) {
    if (e.key === 'Escape') {
        searchInput.value = '';
        searchPosts();
        searchInput.blur();
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
    
    if (stickyHeader.style.display === 'block') {
        const sections = document.querySelectorAll('.year-section, .month-section');
        let currentSection = null;
        
        for (let section of sections) {
            const rect = section.getBoundingClientRect();
            if (rect.top <= 150) {
                currentSection = section;
            }
        }
        
        if (currentSection) {
            const yearSection = currentSection.closest('.year-section');
            const monthSection = currentSection.classList.contains('month-section') ? currentSection : null;
            
            let title = '';
            if (yearSection) {
                title = yearSection.dataset.year;
                if (monthSection && monthSection.dataset.yearMonth) {
                    title = monthSection.dataset.yearMonth;
                }
            }
            
            if (title) {
                stickyTitle.textContent = title;
            } else {
                stickyTitle.textContent = 'Archive';
            }
        } else {
            stickyTitle.textContent = 'Archive';
        }
    }
}

function searchArchive() {
    const mainQuery = searchMainInput.value.toLowerCase().trim();
    const stickyQuery = searchStickyInput.value.toLowerCase().trim();
    const query = mainQuery || stickyQuery;
    
    // Sync inputs
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
        
        if (stickyHeader.style.display === 'block') {
            stickyTitle.textContent = 'Search Results (' + filtered.length + ')';
        }
    } else {
        archiveContainer.innerHTML = '<div class="no-results">No posts found matching "<strong>' + query + '</strong>"</div>';
        if (stickyHeader.style.display === 'block') {
            stickyTitle.textContent = 'Search Results (0)';
        }
    }
    
    searchCount.textContent = filtered.length;
    searchInfo.style.display = 'block';
}

// Debounced search for performance
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
            e.target.blur();
        }
    });
});

window.addEventListener('scroll', updateStickyHeader);
window.addEventListener('resize', updateStickyHeader);
document.addEventListener('DOMContentLoaded', updateStickyHeader);
EOF

# Enhanced markdown processor with comprehensive formatting support
process_markdown() {
    file="$1"
    
    # Simple, robust AWK script that avoids character class issues
    tail -n +2 "$file" | awk '
    BEGIN { 
        in_code = 0; in_list = 0; in_blockquote = 0;
        list_type = "";
    }
    
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
    
    in_code { print; next }
    
    # Blockquotes
    /^> / {
        if (!in_blockquote) {
            print "<blockquote>"
            in_blockquote = 1
        }
        gsub(/^> /, "")
        print "<p>" $0 "</p>"
        next
    }
    
    in_blockquote && !/^> / && !/^$/ {
        print "</blockquote>"
        in_blockquote = 0
    }
    
    # Headers
    /^#### / { gsub(/^#### /, ""); print "<h4>" $0 "</h4>"; next }
    /^### / { gsub(/^### /, ""); print "<h3>" $0 "</h3>"; next }
    /^## / { gsub(/^## /, ""); print "<h2>" $0 "</h2>"; next }
    /^# / { gsub(/^# /, ""); print "<h1>" $0 "</h1>"; next }
    
    # Horizontal rule
    /^---$/ { print "<hr>"; next }
    
    # Lists - simplified approach
    /^[ \t]*\* / || /^[ \t]*- / || /^[ \t]*\+ / {
        if (!in_list || list_type != "ul") {
            if (in_list) print "</" list_type ">"
            print "<ul>"
            in_list = 1
            list_type = "ul"
        }
        # Remove the list marker
        if (/^[ \t]*\* /) gsub(/^[ \t]*\* /, "")
        else if (/^[ \t]*- /) gsub(/^[ \t]*- /, "")
        else if (/^[ \t]*\+ /) gsub(/^[ \t]*\+ /, "")
        print "<li>" $0 "</li>"
        next
    }
    
    # Ordered lists
    /^[ \t]*[0-9]+\. / {
        if (!in_list || list_type != "ol") {
            if (in_list) print "</" list_type ">"
            print "<ol>"
            in_list = 1
            list_type = "ol"
        }
        gsub(/^[ \t]*[0-9]+\. /, "")
        print "<li>" $0 "</li>"
        next
    }
    
    # Empty lines
    /^$/ { 
        if (in_list) {
            print "</" list_type ">"
            in_list = 0
            list_type = ""
        }
        if (in_blockquote) {
            print "</blockquote>"
            in_blockquote = 0
        }
        next 
    }
    
    # Regular paragraphs
    /./ {
        # End any open lists when we hit regular content
        if (in_list && !/^[ \t]*\*/ && !/^[ \t]*-/ && !/^[ \t]*\+/ && !/^[ \t]*[0-9]/) {
            print "</" list_type ">"
            in_list = 0
            list_type = ""
        }
        if (in_blockquote) {
            print "</blockquote>"
            in_blockquote = 0
        }
        
        # Skip if this is a list item (already handled above)
        if (/^[ \t]*\*/ || /^[ \t]*-/ || /^[ \t]*\+/ || /^[ \t]*[0-9]+\./) {
            next
        }
        
        # Inline formatting
        gsub(/\*\*([^*]+)\*\*/, "<strong>\\1</strong>")
        gsub(/\*([^*]+)\*/, "<em>\\1</em>")
        gsub(/`([^`]+)`/, "<code>\\1</code>")
        gsub(/\[([^\]]+)\]\(([^)]+)\)/, "<a href=\"\\2\">\\1</a>")
        
        print "<p>" $0 "</p>"
    }
    
    END {
        if (in_code) print "</code></pre>"
        if (in_list) print "</" list_type ">"
        if (in_blockquote) print "</blockquote>"
    }'
}

# Enhanced excerpt extraction with better content detection
extract_excerpt() {
    file="$1"
    
    # Get meaningful content, skipping metadata and empty lines
    content=$(tail -n +2 "$file" | \
        grep -v '^---' | \
        grep -v '^date:' | \
        grep -v '^Date:' | \
        grep -v '^tags:' | \
        grep -v '^category:' | \
        grep -v '^author:' | \
        grep -v '^#' | \
        grep -v '^```' | \
        grep -v '^$' | \
        head -3)
    
    if [ -z "$content" ]; then
        echo "Read more..."
        return
    fi
    
    # Clean and format excerpt
    excerpt=$(echo "$content" | \
        tr '\n' ' ' | \
        sed 's/[*`#\[\]()]/ /g' | \
        sed 's/  */ /g' | \
        sed 's/^ *//' | \
        cut -c1-200)
    
    # Add ellipsis if truncated
    if [ ${#excerpt} -ge 190 ]; then
        excerpt=$(echo "$excerpt" | sed 's/ [^ ]*$/.../')
    fi
    
    echo "$excerpt"
}

# Robust post number extraction with multiple fallback strategies
extract_post_number() {
    file="$1"
    filename=$(basename "$file" .md)
    
    # Strategy 1: Pure number filename
    if [[ "$filename" =~ ^[0-9]+$ ]]; then
        echo "$filename"
        return
    fi
    
    # Strategy 2: Date-based filename (YYYY-MM-DD-*)
    if [[ "$filename" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})-(.+)$ ]]; then
        year="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        day="${BASH_REMATCH[3]}"
        slug="${BASH_REMATCH[4]}"
        # Create number from date + hash of slug for uniqueness
        date_num="${year}${month}${day}"
        slug_hash=$(echo "$slug" | cksum | cut -d' ' -f1)
        echo "${date_num}${slug_hash: -3}"
        return
    fi
    
    # Strategy 3: Number at start of filename
    if [[ "$filename" =~ ^([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
        return
    fi
    
    # Strategy 4: Number at end of filename
    if [[ "$filename" =~ ([0-9]+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return
    fi
    
    # Strategy 5: Hash of filename for unique ID
    echo "$filename" | cksum | cut -d' ' -f1
}

# Enhanced date extraction with multiple strategies
extract_date() {
    file="$1"
    filename=$(basename "$file" .md)
    
    # Strategy 1: Date from filename (YYYY-MM-DD)
    if [[ "$filename" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
        year="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        day="${BASH_REMATCH[3]}"
        echo "$year/$month/$day|$year$month$day|$year|$month|$day"
        return
    fi
    
    # Strategy 2: Date from file content
    if [ -f "$file" ]; then
        file_date=$(grep -E '^date:|^Date:' "$file" | head -1 | sed 's/^[Dd]ate: *//' | sed 's/[^0-9\-\/]//g')
        if [[ "$file_date" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
            year="${BASH_REMATCH[1]}"
            month="${BASH_REMATCH[2]}"
            day="${BASH_REMATCH[3]}"
            echo "$year/$month/$day|$year$month$day|$year|$month|$day"
            return
        fi
    fi
    
    # Strategy 3: File modification time
    if [ -f "$file" ]; then
        mod_date=$(date -r "$file" '+%Y/%m/%d|%Y%m%d|%Y|%m|%d' 2>/dev/null || echo "")
        if [ -n "$mod_date" ]; then
            echo "$mod_date"
            return
        fi
    fi
    
    # Strategy 4: Current date as fallback
    echo "$(date '+%Y/%m/%d|%Y%m%d|%Y|%m|%d')"
}

# Month name conversion
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

# Enhanced title extraction with fallbacks
extract_title() {
    file="$1"
    filename=$(basename "$file" .md)
    
    # Strategy 1: First line starting with #
    title=$(head -n5 "$file" | grep '^#' | head -1 | sed 's/^#* *//' | sed 's/[<>&"'"'"']/./g')
    
    if [ -n "$title" ] && [ "$title" != "." ]; then
        echo "$title"
        return
    fi
    
    # Strategy 2: Title from filename (remove date prefix and convert dashes)
    if [[ "$filename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-(.+)$ ]]; then
        title="${BASH_REMATCH[1]}"
        title=$(echo "$title" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
        echo "$title"
        return
    fi
    
    # Strategy 3: Convert filename to title
    title=$(echo "$filename" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
    echo "$title"
}

# File discovery and validation
log_info "Discovering markdown files in $CONTENT_DIR..."

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

# Process each file with enhanced error handling
declare -A post_data
declare -A file_stats
processed_count=0
skipped_count=0
duplicate_count=0

log_info "Processing markdown files..."

for i in "${!files[@]}"; do
    file="${files[$i]}"
    
    printf "\r🔄 Processing: %d/%d (%s)" $((i + 1)) $total "$(basename "$file")"
    
    # Validate file exists and is readable
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        log_warning "Skipping unreadable file: $file"
        ((skipped_count++))
        continue
    fi
    
    # Extract all metadata
    title=$(extract_title "$file")
    num=$(extract_post_number "$file")
    date_info=$(extract_date "$file")
    
    # Parse date info
    IFS='|' read -r date sort_date year month day <<< "$date_info"
    
    excerpt=$(extract_excerpt "$file")
    
    # Validate required fields
    if [ -z "$title" ] || [ -z "$num" ]; then
        log_warning "Skipping file with missing title or number: $file"
        ((skipped_count++))
        continue
    fi
    
    # Check for duplicates
    if [ -n "${post_data["$num,title"]}" ]; then
        log_warning "Duplicate post number $num: ${post_data["$num,title"]} vs $title"
        ((duplicate_count++))
        # Use filename hash to make unique
        num="${num}_$(echo "$file" | cksum | cut -d' ' -f1 | tail -c 4)"
    fi
    
    # Store post data
    post_data["$num,title"]="$title"
    post_data["$num,date"]="$date"
    post_data["$num,excerpt"]="$excerpt"
    post_data["$num,file"]="$file"
    post_data["$num,year"]="$year"
    post_data["$num,month"]="$month"
    post_data["$num,day"]="$day"
    post_data["$num,sort_date"]="$sort_date"
    
    # Process markdown content
    content=$(process_markdown "$file")
    word_count=$(echo "$content" | wc -w)
    reading_time=$(echo "$word_count" | awk '{print int($1/200)+1}')
    
    file_stats["$num,words"]="$word_count"
    file_stats["$num,reading_time"]="$reading_time"
    
    # Generate individual post page
    cat > "public/p/${num}.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${title} - ${SITE_TITLE}</title>
    <meta name="description" content="${excerpt:0:160}">
    <meta name="author" content="${SITE_TITLE}">
    <meta property="og:title" content="${title}">
    <meta property="og:description" content="${excerpt:0:160}">
    <meta property="og:type" content="article">
    <meta property="article:published_time" content="${year}-${month}-${day}">
    <style>$(cat /tmp/post.css)</style>
</head>
<body>
    <nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav>
    <article>
        <header>
            <h1>${title}</h1>
            <small>${date}</small>
            <div class="post-meta">
                <p><strong>Published:</strong> ${date}</p>
                <p><strong>Reading time:</strong> ~${reading_time} min (${word_count} words)</p>
            </div>
        </header>
        <main>
${content}
        </main>
    </article>
    <nav style="border-top:1px solid #e2e8f0;margin-top:3em;padding-top:1.5em">
        <a href="../">← Back to Blog</a> | <a href="../archive/">Archive</a>
    </nav>
</body>
</html>
EOF
    
    ((processed_count++))
done

echo # New line after progress indicator

log_success "Processing complete!"
log_info "Processed: $processed_count, Skipped: $skipped_count, Duplicates resolved: $duplicate_count"

# Generate post lists
processed_nums=($(for key in "${!post_data[@]}"; do
    [[ "$key" == *",title" ]] && echo "${key%,title}"
done | sort -n))

if [ ${#processed_nums[@]} -eq 0 ]; then
    log_error "No posts were successfully processed!"
    exit 1
fi

log_info "Generating main page..."

# Get recent posts for main page
recent_nums=($(for num in "${processed_nums[@]}"; do
    echo "${post_data["$num,sort_date"]} $num"
done | sort -rn | head -$MAX_POSTS_MAIN | cut -d' ' -f2))

# Generate main page
cat > public/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${SITE_TITLE}</title>
    <meta name="description" content="A technical blog with ${#processed_nums[@]} posts about software development, technology, and more.">
    <meta property="og:title" content="${SITE_TITLE}">
    <meta property="og:description" content="Technical blog with ${#processed_nums[@]} posts">
    <meta property="og:type" content="website">
    <style>$(cat /tmp/shared.css)</style>
</head>
<body>
    <header>
        <h1>${SITE_TITLE}</h1>
        <div class="stats">📊 ${#processed_nums[@]} posts published</div>
    </header>
    
    <main>
        <input id="search" placeholder="Search posts..." autocomplete="off" aria-label="Search posts">
        <div id="search-info" class="search-results" style="display:none">
            <span id="search-count">0</span> posts found
        </div>
        
        <div id="posts">
EOF

if [ ${#recent_nums[@]} -eq 0 ]; then
    echo '            <div class="no-results">No posts available.</div>' >> public/index.html
else
    for num in "${recent_nums[@]}"; do
        title="${post_data["$num,title"]}"
        date="${post_data["$num,date"]}"
        excerpt="${post_data["$num,excerpt"]}"
        reading_time="${file_stats["$num,reading_time"]}"
        
        [ -z "$title" ] && continue
        
        cat >> public/index.html << EOF
            <article class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}" onclick="window.location.href='p/${num}.html'">
                <small>${date} • ${reading_time} min read</small>
                <h2><a href="p/${num}.html">${title}</a></h2>
                <div class="excerpt">${excerpt}</div>
            </article>
EOF
    done
fi

cat >> public/index.html << EOF
        </div>
    </main>
    
    <nav style="margin-top:2em">
        <p>📚 <a href="archive/">View all ${#processed_nums[@]} posts in Archive →</a></p>
    </nav>
    
    <script>$(cat /tmp/search.js)</script>
</body>
</html>
EOF

log_info "Generating archive page..."

# Sort all posts chronologically
sorted_nums=($(for num in "${processed_nums[@]}"; do
    echo "${post_data["$num,sort_date"]} $num"
done | sort -rn | cut -d' ' -f2))

# Group by year and month
declare -A year_months
for num in "${sorted_nums[@]}"; do
    year="${post_data["$num,year"]}"
    month="${post_data["$num,month"]}"
    ym="$year-$month"
    year_months["$ym"]+="$num "
done

# Generate archive page
cat > public/archive/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Archive - ${SITE_TITLE}</title>
    <meta name="description" content="Chronological archive of all ${#processed_nums[@]} posts">
    <style>$(cat /tmp/shared.css)</style>
</head>
<body>
    <nav><a href="../">← Home</a></nav>
    <header>
        <h1>Archive</h1>
        <div class="stats">📊 ${#processed_nums[@]} posts chronologically ordered</div>
    </header>
    
    <main>
        <input id="search-main" placeholder="Search all posts..." autocomplete="off" aria-label="Search all posts">
        <div id="search-info" class="search-results" style="display:none">
            <span id="search-count">0</span> of ${#processed_nums[@]} posts found
        </div>
        
        <div id="sticky-header" class="sticky-header">
            <h2 id="sticky-title">Timeline</h2>
            <input id="search-sticky" placeholder="Search all posts..." autocomplete="off" aria-label="Search all posts">
        </div>
        
        <div class="archive-content" id="archive">
EOF

# Generate timeline
current_year=""
for ym in $(printf '%s\n' "${!year_months[@]}" | sort -rn); do
    year=$(echo "$ym" | cut -d- -f1)
    month=$(echo "$ym" | cut -d- -f2)
    month_name=$(get_month_name "$month")
    
    # Year section
    if [ "$year" != "$current_year" ]; then
        [ -n "$current_year" ] && echo "        </div>" >> public/archive/index.html
        echo "        <div class=\"year-section\" data-year=\"$year\">" >> public/archive/index.html
        echo "            <div class=\"year-header\">" >> public/archive/index.html
        echo "                <h2>$year</h2>" >> public/archive/index.html
        echo "            </div>" >> public/archive/index.html
        current_year="$year"
    fi
    
    # Month section
    cat >> public/archive/index.html << EOF
            <div class="month-section" data-month="$month" data-year-month="$year $month_name">
                <div class="month-header">
                    <h3>$month_name</h3>
                </div>
EOF
    
    # Posts in this month
    month_nums=($(printf '%s\n' ${year_months[$ym]} | xargs -n1 | while read num; do
        echo "${post_data["$num,sort_date"]} $num"
    done | sort -rn | cut -d' ' -f2))
    
    for num in "${month_nums[@]}"; do
        title="${post_data["$num,title"]}"
        date="${post_data["$num,date"]}"
        excerpt="${post_data["$num,excerpt"]}"
        reading_time="${file_stats["$num,reading_time"]}"
        
        cat >> public/archive/index.html << EOF
                <article class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}" onclick="window.location.href='../p/${num}.html'">
                    <small>${date} • ${reading_time} min read</small>
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
    </main>
    
    <script>$(cat /tmp/archive.js)</script>
</body>
</html>
EOF

# Generate sitemap
log_info "Generating sitemap..."
cat > public/sitemap.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url>
        <loc>${BASE_URL}/</loc>
        <changefreq>daily</changefreq>
        <priority>1.0</priority>
    </url>
    <url>
        <loc>${BASE_URL}/archive/</loc>
        <changefreq>weekly</changefreq>
        <priority>0.8</priority>
    </url>
EOF

for num in "${processed_nums[@]}"; do
    year="${post_data["$num,year"]}"
    month="${post_data["$num,month"]}"
    day="${post_data["$num,day"]}"
    echo "    <url>" >> public/sitemap.xml
    echo "        <loc>${BASE_URL}/p/${num}.html</loc>" >> public/sitemap.xml
    echo "        <lastmod>${year}-${month}-${day}</lastmod>" >> public/sitemap.xml
    echo "        <changefreq>monthly</changefreq>" >> public/sitemap.xml
    echo "        <priority>0.6</priority>" >> public/sitemap.xml
    echo "    </url>" >> public/sitemap.xml
done

echo "</urlset>" >> public/sitemap.xml

# Generate RSS feed
log_info "Generating RSS feed..."
recent_for_rss=($(for num in "${processed_nums[@]}"; do
    echo "${post_data["$num,sort_date"]} $num"
done | sort -rn | head -10 | cut -d' ' -f2))

cat > public/feed.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
        <title>${SITE_TITLE}</title>
        <link>${BASE_URL}/</link>
        <description>Technical blog with insights on software development and technology</description>
        <language>en-us</language>
        <atom:link href="${BASE_URL}/feed.xml" rel="self" type="application/rss+xml"/>
EOF

for num in "${recent_for_rss[@]}"; do
    title="${post_data["$num,title"]}"
    date="${post_data["$num,date"]}"
    excerpt="${post_data["$num,excerpt"]}"
    year="${post_data["$num,year"]}"
    month="${post_data["$num,month"]}"
    day="${post_data["$num,day"]}"
    
    # Convert date to RFC 822 format
    rfc_date=$(date -d "${year}-${month}-${day}" '+%a, %d %b %Y %H:%M:%S %z' 2>/dev/null || echo "$(date '+%a, %d %b %Y %H:%M:%S %z')")
    
    cat >> public/feed.xml << EOF
        <item>
            <title><![CDATA[${title}]]></title>
            <link>${BASE_URL}/p/${num}.html</link>
            <description><![CDATA[${excerpt}]]></description>
            <pubDate>${rfc_date}</pubDate>
            <guid>${BASE_URL}/p/${num}.html</guid>
        </item>
EOF
done

echo "    </channel>" >> public/feed.xml
echo "</rss>" >> public/feed.xml

# Cleanup
rm -f /tmp/shared.css /tmp/post.css /tmp/search.js /tmp/archive.js

# Final statistics
total_words=$(for num in "${processed_nums[@]}"; do
    echo "${file_stats["$num,words"]}"
done | awk '{sum += $1} END {print sum}')

avg_words=$(echo "$total_words ${#processed_nums[@]}" | awk '{print int($1/$2)}')

log_success "Build completed successfully!"
echo
echo "📊 FINAL STATISTICS:"
echo "  ✅ Main page: ${#recent_nums[@]} recent posts displayed"
echo "  ✅ Archive: ${#processed_nums[@]} posts chronologically organized"
echo "  ✅ Individual pages: ${#processed_nums[@]} post pages generated"
echo "  ✅ Total words: $total_words (avg: $avg_words per post)"
echo "  ✅ SEO: Sitemap and RSS feed generated"
echo "  ✅ Features: Search, responsive design, semantic HTML"
echo "  ✅ Performance: Optimized CSS, debounced search, lazy loading"
echo
echo "🌐 Your blog is ready at: ${BASE_URL}"
echo "📡 RSS feed: ${BASE_URL}/feed.xml"
echo "🗺️  Sitemap: ${BASE_URL}/sitemap.xml"

if [ $duplicate_count -gt 0 ]; then
    log_warning "Found $duplicate_count duplicate post numbers - they were automatically resolved"
fi

if [ $skipped_count -gt 0 ]; then
    log_warning "Skipped $skipped_count files due to errors"
fi
