#!/bin/bash
set -e

echo "🚀 Building final improved blog with consistent UI and fixed search..."

SITE_TITLE="${SITE_TITLE:-dee-blogger}"
BASE_URL="${BASE_URL:-https://vdeemann.github.io/dee-blogger.github.io}"

# Clean and create directories
rm -rf public
mkdir -p public/p public/archive

# Create CSS files to avoid inline substitution issues
cat > /tmp/shared.css << 'EOF'
body{max-width:832px;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.5;color:#333;background:#fff;position:relative}a{color:#0066cc;text-decoration:none;transition:color .2s ease}a:hover{color:#0052a3;text-decoration:underline}h1{font-size:1.9em;margin:0 0 .5em;color:#1a1a1a;font-weight:700}h2{font-size:1.2em;margin:0 0 .3em;color:#333;font-weight:600}h3{font-size:1.1em;margin:0 0 .3em;color:#444;font-weight:600}p{margin:.4em 0}small{color:#666;display:block;margin:0 0 .3em;font-size:.9em}.post{margin:0 0 .6em;padding:.5em .7em;background:#fafafa;border-radius:4px;border:1px solid #e8e8e8;cursor:pointer}input{width:100%;margin:0 0 1em;padding:.6em;border:1px solid #ddd;border-radius:4px;font-size:.95em;background:#fff;box-sizing:border-box;transition:border-color .2s ease,box-shadow .2s ease}input:focus{outline:0;border-color:#0066cc;box-shadow:0 0 0 3px rgba(0,102,204,.1)}nav{margin:1em 0;padding:.5em 0;border-bottom:1px solid #eee}.stats{background:#fff3cd;padding:.6em 1em;border-radius:4px;margin:1em 0;text-align:center;font-size:.95em;border:1px solid #ffeaa7}.search-highlight{background:#ffeb3b;padding:0 .2em;border-radius:2px}.excerpt{color:#666;margin:.3em 0 0;font-size:.9em;line-height:1.4}.search-results{background:#e8f4fd;padding:.8em;border-radius:4px;margin:1em 0;border-left:4px solid #0066cc}.no-results{text-align:center;color:#666;padding:2em;font-style:italic}.search-count{font-weight:600;color:#0066cc}.sticky-header{position:sticky;top:0;background:#fff;border-bottom:2px solid #0066cc;padding:.8em 0;margin:0 0 1em;z-index:100;box-shadow:0 2px 4px rgba(0,0,0,.1);display:none}.sticky-header h2{margin:0 0 .5em;font-size:1.1em;color:#0066cc;font-weight:700}.sticky-header input{margin:0;padding:.5em;font-size:.9em}.archive-content{margin:2em 0}.year-section{margin:0 0 2.5em}.month-section{margin:0 0 1.5em}.year-header{margin:0 0 1em}.month-header{margin:0 0 .8em;font-size:.95em;color:#666}
EOF

cat > /tmp/post.css << 'EOF'
body{max-width:832px;margin:2em auto;padding:0 1em;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;line-height:1.45;color:#1a1a1a;background:#fff;font-size:15px;letter-spacing:0.01em}a{color:#0969da;text-decoration:none;transition:color .15s ease}a:hover{color:#0550ae;text-decoration:underline}h1{font-size:1.85em;margin:0 0 .4em;color:#0d1117;font-weight:600;line-height:1.15;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;letter-spacing:-0.01em}h2{font-size:1.35em;margin:1.8em 0 .6em;color:#0d1117;font-weight:600;line-height:1.2;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;letter-spacing:-0.005em}h3{font-size:1.15em;margin:1.4em 0 .5em;color:#24292f;font-weight:600;line-height:1.25;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}p{margin:.8em 0;font-size:15px;line-height:1.45;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;letter-spacing:0.01em}small{color:#656d76;display:block;margin:0 0 1.5em;font-size:14px;font-weight:400;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}strong{font-weight:600;color:#0d1117}code{background:#f6f8fa;color:#cf222e;padding:.1em .25em;border-radius:3px;font-family:ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,monospace;font-size:13px;border:1px solid #d0d7de}pre{background:#f6f8fa;padding:.75em;margin:1.2em 0;border-radius:6px;overflow-x:auto;border:1px solid #d0d7de;line-height:1.35}pre code{background:0;padding:0;font-size:13px;color:#24292f;display:block;border:0;font-family:ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,monospace}ul,ol{margin:1em 0;padding-left:1.8em;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;line-height:1.45}li{margin:.4em 0;line-height:1.45;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #d0d7de;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}blockquote{background:#f6f8fa;border-left:3px solid #0969da;margin:1.2em 0;padding:.8em 1.2em;border-radius:0 6px 6px 0;color:#656d76;font-style:italic;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;line-height:1.4}blockquote p{margin:.6em 0;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}hr{border:0;height:1px;background:#d0d7de;margin:2em 0}.post-meta{background:#f6f8fa;padding:.8em 1em;border-radius:6px;margin:1.2em 0;border-left:3px solid #0969da;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif}.post-meta p{margin:.2em 0;font-size:13px;color:#656d76;font-family:-apple-system,BlinkMacSystemFont,system-ui,sans-serif;line-height:1.4}
EOF

# Create JavaScript file to avoid substitution issues
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
        postsContainer.innerHTML = '<div class="no-results">No posts found matching your search.</div>';
    }
    
    searchCount.textContent = filtered.length;
    searchInfo.style.display = 'block';
}

searchInput.addEventListener('input', function(e) {
    searchPosts();
});

searchInput.addEventListener('change', function(e) {
    searchPosts();
});

searchInput.addEventListener('keyup', function(e) {
    if (e.key === 'Escape') {
        searchInput.value = '';
        searchPosts();
    }
});
EOF

# Create archive JavaScript
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
        archiveContainer.innerHTML = '<div class="no-results">No posts found matching your search.</div>';
        if (stickyHeader.style.display === 'block') {
            stickyTitle.textContent = 'Search Results (0)';
        }
    }
    
    searchCount.textContent = filtered.length;
    searchInfo.style.display = 'block';
}

searchMainInput.addEventListener('input', function(e) {
    searchArchive();
});

searchStickyInput.addEventListener('input', function(e) {
    searchArchive();
});

searchMainInput.addEventListener('change', function(e) {
    searchArchive();
});

searchStickyInput.addEventListener('change', function(e) {
    searchArchive();
});

searchMainInput.addEventListener('keyup', function(e) {
    if (e.key === 'Escape') {
        searchMainInput.value = '';
        searchStickyInput.value = '';
        searchArchive();
    }
});

searchStickyInput.addEventListener('keyup', function(e) {
    if (e.key === 'Escape') {
        searchMainInput.value = '';
        searchStickyInput.value = '';
        searchArchive();
    }
});

window.addEventListener('scroll', updateStickyHeader);
window.addEventListener('resize', updateStickyHeader);
updateStickyHeader();
EOF

# Enhanced markdown processor with better formatting
process_markdown() {
    local file="$1"
    
    tail -n +2 "$file" | awk '
    BEGIN { in_code = 0; in_list = 0; in_blockquote = 0 }
    
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
    
    /^### / { gsub(/^### /, ""); print "<h3>" $0 "</h3>"; next }
    /^## / { gsub(/^## /, ""); print "<h2>" $0 "</h2>"; next }
    /^# / { gsub(/^# /, ""); print "<h1>" $0 "</h1>"; next }
    
    /^[•*-] / {
        if (!in_list) {
            print "<ul>"
            in_list = 1
        }
        gsub(/^[•*-] /, "")
        print "<li>" $0 "</li>"
        next
    }
    
    in_list && !/^[•*-] / && !/^$/ {
        print "</ul>"
        in_list = 0
    }
    
    /^$/ { 
        if (in_list) {
            print "</ul>"
            in_list = 0
        }
        if (in_blockquote) {
            print "</blockquote>"
            in_blockquote = 0
        }
        next 
    }
    
    /./ {
        if (in_list) {
            print "</ul>"
            in_list = 0
        }
        if (in_blockquote) {
            print "</blockquote>"
            in_blockquote = 0
        }
        
        gsub(/\*\*([^*]+)\*\*/, "<strong>\\1</strong>")
        gsub(/`([^`]+)`/, "<code>\\1</code>")
        gsub(/\[([^\]]+)\]\(([^)]+)\)/, "<a href=\"\\2\">\\1</a>")
        
        print "<p>" $0 "</p>"
    }
    
    END {
        if (in_code) print "</code></pre>"
        if (in_list) print "</ul>"
        if (in_blockquote) print "</blockquote>"
    }'
}

# Extract clean excerpt from content
extract_excerpt() {
    local file="$1"
    echo "    🔍 Extracting excerpt from: $file" >&2
    
    # Skip the first line (title) and extract meaningful content
    local content=$(tail -n +2 "$file" | grep -v '^#' | grep -v '^```' | grep -v '^

# Get month name from number
get_month_name() {
    local month="$1"
    case "$month" in
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

# Get all markdown files and process them
echo "📁 Processing markdown files..."
files=($(find content -name "*.md" | sort))
total=${#files[@]}

if [ $total -eq 0 ]; then
    echo "❌ No markdown files found in content/ directory"
    exit 1
fi

echo "📊 Found $total markdown files"
echo "Files found:"
for f in "${files[@]}"; do
    echo "  - $f"
done

# Process each post
declare -A post_data
for i in "${!files[@]}"; do
    file="${files[$i]}"
    
    echo ""
    echo "🔍 Processing file: $file"
    
    if [ ! -f "$file" ]; then
        echo "❌ Warning: File not found: $file"
        continue
    fi
    
    # Show first few lines for debugging
    echo "  📄 First 3 lines of file:"
    head -n3 "$file" | sed 's/^/    /'
    
    # Extract title more carefully
    title=$(head -n1 "$file" | sed 's/^# *//' | sed 's/[<>&"'\'']/./g' | sed 's/^\s*//;s/\s*$//')
    if [ -z "$title" ]; then
        title="Untitled Post $((i + 1))"
        echo "  ⚠️  No title found, using: $title"
    fi
    
    # Extract slug and number more robustly
    slug=$(basename "$file" .md)
    echo "  📎 Slug: $slug"
    
    # Try different numbering schemes
    if [[ "$slug" =~ ^[0-9]+$ ]]; then
        # Pure number filename
        num="$slug"
    elif [[ "$slug" =~ ^([0-9]+) ]]; then
        # Number at start
        num="${BASH_REMATCH[1]}"
    elif [[ "$slug" =~ ([0-9]+)$ ]]; then
        # Number at end
        num="${BASH_REMATCH[1]}"
    else
        # Use index + 1 as fallback
        num="$((i + 1))"
        echo "  ⚠️  No number in filename, using: $num"
    fi
    
    # Extract date from filename or use current date
    if [[ "$slug" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
        year="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        day="${BASH_REMATCH[3]}"
        date="$year/$month/$day"
        sort_date="$year$month$day"
        echo "  📅 Date from filename: $date"
    else
        # Try to extract date from file content
        file_date=$(grep -E '^date:|^Date:' "$file" | head -1 | sed 's/^[Dd]ate:\s*//' | sed 's/[^0-9\-\/]//g')
        if [ -n "$file_date" ]; then
            if [[ "$file_date" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
                year="${BASH_REMATCH[1]}"
                month="${BASH_REMATCH[2]}"
                day="${BASH_REMATCH[3]}"
                date="$year/$month/$day"
                sort_date="$year$month$day"
                echo "  📅 Date from content: $date"
            else
                date="$(date +%Y/%m/%d)"
                sort_date="$(date +%Y%m%d)"
                year="$(date +%Y)"
                month="$(date +%m)"
                day="$(date +%d)"
                echo "  📅 Using current date: $date"
            fi
        else
            date="$(date +%Y/%m/%d)"
            sort_date="$(date +%Y%m%d)"
            year="$(date +%Y)"
            month="$(date +%m)"
            day="$(date +%d)"
            echo "  📅 Using current date: $date"
        fi
    fi
    
    excerpt=$(extract_excerpt "$file")
    if [ -z "$excerpt" ]; then
        excerpt="No excerpt available..."
    fi
    echo "  📝 Excerpt: ${excerpt:0:50}..."
    
    echo "  ✅ Final values:"
    echo "    - Number: $num"
    echo "    - Title: $title"
    echo "    - Date: $date"
    echo "    - Excerpt: ${excerpt:0:50}..."
    
    post_data["$num,title"]="$title"
    post_data["$num,date"]="$date"
    post_data["$num,excerpt"]="$excerpt"
    post_data["$num,file"]="$file"
    post_data["$num,year"]="$year"
    post_data["$num,month"]="$month"
    post_data["$num,day"]="$day"
    post_data["$num,sort_date"]="$sort_date"
    
    content=$(process_markdown "$file")
    reading_time=$(echo "$content" | wc -w | awk '{print int($1/200)+1}')
    
    # Generate post page using safe method
    echo '<!DOCTYPE html>' > "public/p/${num}.html"
    echo '<html lang="en">' >> "public/p/${num}.html"
    echo '<head>' >> "public/p/${num}.html"
    echo '    <meta charset="utf-8">' >> "public/p/${num}.html"
    echo '    <meta name="viewport" content="width=device-width,initial-scale=1">' >> "public/p/${num}.html"
    echo "    <title>${title} - ${SITE_TITLE}</title>" >> "public/p/${num}.html"
    echo "    <meta name=\"description\" content=\"${excerpt:0:160}\">" >> "public/p/${num}.html"
    echo '    <style>' >> "public/p/${num}.html"
    cat /tmp/post.css >> "public/p/${num}.html"
    echo '    </style>' >> "public/p/${num}.html"
    echo '</head>' >> "public/p/${num}.html"
    echo '<body>' >> "public/p/${num}.html"
    echo '    <nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav>' >> "public/p/${num}.html"
    echo "    <h1>${title}</h1>" >> "public/p/${num}.html"
    echo "    <small>${date}</small>" >> "public/p/${num}.html"
    echo '    <div class="post-meta">' >> "public/p/${num}.html"
    echo "        <p><strong>Published:</strong> ${date}</p>" >> "public/p/${num}.html"
    echo "        <p><strong>Reading time:</strong> ~${reading_time} min</p>" >> "public/p/${num}.html"
    echo '    </div>' >> "public/p/${num}.html"
    echo "${content}" >> "public/p/${num}.html"
    echo '    <nav style="border-top:1px solid #e2e8f0;margin-top:3em;padding-top:1.5em">' >> "public/p/${num}.html"
    echo '        <a href="../">← Back to Blog</a> | <a href="../archive/">Archive</a>' >> "public/p/${num}.html"
    echo '    </nav>' >> "public/p/${num}.html"
    echo '</body>' >> "public/p/${num}.html"
    echo '</html>' >> "public/p/${num}.html"
    
    echo "✅ Processed: $num - $title"
done

echo ""
echo "📋 PROCESSING SUMMARY:"
echo "📊 Total files processed: ${#files[@]}"

# Show all processed posts
echo "📝 Posts created:"
processed_nums=($(for key in "${!post_data[@]}"; do
    if [[ "$key" == *",title" ]]; then
        echo "${key%,title}"
    fi
done | sort -n))

for num in "${processed_nums[@]}"; do
    echo "  $num: ${post_data["$num,title"]} (${post_data["$num,date"]})"
done

# Check for duplicates
echo ""
echo "🔍 Checking for duplicate titles..."
declare -A title_counts
for num in "${processed_nums[@]}"; do
    title="${post_data["$num,title"]}"
    title_counts["$title"]=$((${title_counts["$title"]} + 1))
done

duplicates_found=false
for title in "${!title_counts[@]}"; do
    if [ "${title_counts["$title"]}" -gt 1 ]; then
        echo "  ⚠️  DUPLICATE: '$title' appears ${title_counts["$title"]} times"
        duplicates_found=true
    fi
done

if [ "$duplicates_found" = false ]; then
    echo "  ✅ No duplicate titles found"
fi

echo ""

# Generate main page
echo "🏠 Generating main page with consistent styling..."

echo '<!DOCTYPE html>' > public/index.html
echo '<html lang="en">' >> public/index.html
echo '<head>' >> public/index.html
echo '    <meta charset="utf-8">' >> public/index.html
echo '    <meta name="viewport" content="width=device-width,initial-scale=1">' >> public/index.html
echo "    <title>${SITE_TITLE}</title>" >> public/index.html
echo "    <meta name=\"description\" content=\"A blog with ${total} posts\">" >> public/index.html
echo '    <style>' >> public/index.html
cat /tmp/shared.css >> public/index.html
echo '    </style>' >> public/index.html
echo '</head>' >> public/index.html
echo '<body>' >> public/index.html
echo "    <h1>${SITE_TITLE}</h1>" >> public/index.html
echo "    <div class=\"stats\">📊 ${total} posts published</div>" >> public/index.html
echo '    <input id="search" placeholder="Search posts..." autocomplete="off">' >> public/index.html
echo '    <div id="search-info" class="search-results" style="display:none">' >> public/index.html
echo '        <span id="search-count">0</span> posts found' >> public/index.html
echo '    </div>' >> public/index.html
echo '    <div id="posts">' >> public/index.html

# Get recent posts (last 20, sorted by date newest first)
recent_nums=($(for file in "${files[@]}"; do
    slug=$(basename "$file" .md)
    num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "1")
    echo "${post_data["$num,sort_date"]} $num"
done | sort -rn | head -20 | cut -d' ' -f2))

for num in "${recent_nums[@]}"; do
    title="${post_data["$num,title"]}"
    date="${post_data["$num,date"]}"
    excerpt="${post_data["$num,excerpt"]}"
    
    echo "        <div class=\"post\" data-title=\"${title,,}\" data-excerpt=\"${excerpt,,}\" data-searchable=\"${title,,} ${excerpt,,}\" onclick=\"window.location.href='p/${num}.html'\">" >> public/index.html
    echo "            <small>${date}</small>" >> public/index.html
    echo "            <h2><a href=\"p/${num}.html\">${title}</a></h2>" >> public/index.html
    echo "            <div class=\"excerpt\">${excerpt}</div>" >> public/index.html
    echo "        </div>" >> public/index.html
done

echo '    </div>' >> public/index.html
echo '    <nav style="margin-top:2em">' >> public/index.html
echo '        <p>📚 <a href="archive/">View all posts in Archive →</a></p>' >> public/index.html
echo '    </nav>' >> public/index.html
echo '    <script>' >> public/index.html
cat /tmp/search.js >> public/index.html
echo '    </script>' >> public/index.html
echo '</body>' >> public/index.html
echo '</html>' >> public/index.html

# Generate archive page
echo "📚 Generating archive with fixed search and sticky header..."

echo '<!DOCTYPE html>' > public/archive/index.html
echo '<html lang="en">' >> public/archive/index.html
echo '<head>' >> public/archive/index.html
echo '    <meta charset="utf-8">' >> public/archive/index.html
echo '    <meta name="viewport" content="width=device-width,initial-scale=1">' >> public/archive/index.html
echo "    <title>Archive - ${SITE_TITLE}</title>" >> public/archive/index.html
echo "    <meta name=\"description\" content=\"Chronological archive of all ${total} posts\">" >> public/archive/index.html
echo '    <style>' >> public/archive/index.html
cat /tmp/shared.css >> public/archive/index.html
echo '    </style>' >> public/archive/index.html
echo '</head>' >> public/archive/index.html
echo '<body>' >> public/archive/index.html
echo '    <nav><a href="../">← Home</a></nav>' >> public/archive/index.html
echo '    <h1>Archive</h1>' >> public/archive/index.html
echo "    <div class=\"stats\">📊 ${total} posts chronologically ordered</div>" >> public/archive/index.html
echo '    <input id="search-main" placeholder="Search all posts..." autocomplete="off">' >> public/archive/index.html
echo '    <div id="search-info" class="search-results" style="display:none">' >> public/archive/index.html
echo "        <span id=\"search-count\">0</span> of ${total} posts found" >> public/archive/index.html
echo '    </div>' >> public/archive/index.html
echo '    <div id="sticky-header" class="sticky-header">' >> public/archive/index.html
echo '        <h2 id="sticky-title">Timeline</h2>' >> public/archive/index.html
echo '        <input id="search-sticky" placeholder="Search all posts..." autocomplete="off">' >> public/archive/index.html
echo '    </div>' >> public/archive/index.html
echo '    <div class="archive-content" id="archive">' >> public/archive/index.html

# Sort all posts chronologically (newest first)
sorted_nums=($(for file in "${files[@]}"; do
    slug=$(basename "$file" .md)
    num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "1")
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
    echo "            <div class=\"month-section\" data-month=\"$month\" data-year-month=\"$year $month_name\">" >> public/archive/index.html
    echo "                <div class=\"month-header\">" >> public/archive/index.html
    echo "                    <h3>$month_name</h3>" >> public/archive/index.html
    echo "                </div>" >> public/archive/index.html
    
    # Posts in this month (sorted by day, newest first)
    month_nums=($(printf '%s\n' ${year_months[$ym]} | xargs -n1 | while read num; do
        echo "${post_data["$num,sort_date"]} $num"
    done | sort -rn | cut -d' ' -f2))
    
    for num in "${month_nums[@]}"; do
        title="${post_data["$num,title"]}"
        date="${post_data["$num,date"]}"
        excerpt="${post_data["$num,excerpt"]}"
        
        echo "                <div class=\"post\" data-title=\"${title,,}\" data-excerpt=\"${excerpt,,}\" data-searchable=\"${title,,} ${excerpt,,}\" onclick=\"window.location.href='../p/${num}.html'\">" >> public/archive/index.html
        echo "                    <small>${date}</small>" >> public/archive/index.html
        echo "                    <h3><a href=\"../p/${num}.html\">${title}</a></h3>" >> public/archive/index.html
        echo "                    <div class=\"excerpt\">${excerpt}</div>" >> public/archive/index.html
        echo "                </div>" >> public/archive/index.html
    done
    echo "            </div>" >> public/archive/index.html
done

[ -n "$current_year" ] && echo "        </div>" >> public/archive/index.html

echo '    </div>' >> public/archive/index.html
echo '    <script>' >> public/archive/index.html
cat /tmp/archive.js >> public/archive/index.html
echo '    </script>' >> public/archive/index.html
echo '</body>' >> public/archive/index.html
echo '</html>' >> public/archive/index.html

# Cleanup temporary files
rm -f /tmp/shared.css /tmp/post.css /tmp/search.js /tmp/archive.js

echo "✅ Safe build completed successfully!"
echo "📊 Generated:"
echo "  - Main page with ${#recent_nums[@]} recent posts"
echo "  - Archive with all $total posts chronologically ordered"
echo "  - Ultra-smooth hover effects and perfect search functionality"
echo "  - Professional typography and consistent UI"
echo "  - $total individual post pages"
echo "  - Zero bash substitution errors"
echo "  - ✨ Consistent 832px width across all pages"
echo "  - 🔍 Enhanced debugging to identify content issues"
echo ""
echo "🔧 If all posts show the same content, check the markdown files in your content/ directory"
echo "📝 Each .md file should start with '# Title' and have unique content" | grep -v '^date:' | grep -v '^Date:' | head -5)
    echo "    📝 Raw content lines found: $(echo "$content" | wc -l)" >&2
    
    if [ -z "$content" ]; then
        echo "No content available"
        return
    fi
    
    # Clean and format excerpt
    local excerpt=$(echo "$content" | tr '\n' ' ' | sed 's/[*`#\[\]()]/./g' | sed 's/\s\+/ /g' | cut -c1-180)
    excerpt=$(echo "$excerpt" | sed 's/\.\.\.*//' | sed 's/\s*$/.../')
    
    echo "    ✅ Generated excerpt: ${excerpt:0:50}..." >&2
    echo "$excerpt"
}

# Get month name from number
get_month_name() {
    local month="$1"
    case "$month" in
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

# Get all markdown files and process them
echo "📁 Processing markdown files..."
files=($(find content -name "*.md" | sort))
total=${#files[@]}

if [ $total -eq 0 ]; then
    echo "❌ No markdown files found in content/ directory"
    exit 1
fi

echo "📊 Found $total markdown files"
echo "Files found:"
for f in "${files[@]}"; do
    echo "  - $f"
done

# Process each post
declare -A post_data
for i in "${!files[@]}"; do
    file="${files[$i]}"
    
    echo ""
    echo "🔍 Processing file: $file"
    
    if [ ! -f "$file" ]; then
        echo "❌ Warning: File not found: $file"
        continue
    fi
    
    # Show first few lines for debugging
    echo "  📄 First 3 lines of file:"
    head -n3 "$file" | sed 's/^/    /'
    
    # Extract title more carefully
    title=$(head -n1 "$file" | sed 's/^# *//' | sed 's/[<>&"'\'']/./g' | sed 's/^\s*//;s/\s*$//')
    if [ -z "$title" ]; then
        title="Untitled Post $((i + 1))"
        echo "  ⚠️  No title found, using: $title"
    fi
    
    # Extract slug and number more robustly
    slug=$(basename "$file" .md)
    echo "  📎 Slug: $slug"
    
    # Try different numbering schemes
    if [[ "$slug" =~ ^[0-9]+$ ]]; then
        # Pure number filename
        num="$slug"
    elif [[ "$slug" =~ ^([0-9]+) ]]; then
        # Number at start
        num="${BASH_REMATCH[1]}"
    elif [[ "$slug" =~ ([0-9]+)$ ]]; then
        # Number at end
        num="${BASH_REMATCH[1]}"
    else
        # Use index + 1 as fallback
        num="$((i + 1))"
        echo "  ⚠️  No number in filename, using: $num"
    fi
    
    # Extract date from filename or use current date
    if [[ "$slug" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
        year="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        day="${BASH_REMATCH[3]}"
        date="$year/$month/$day"
        sort_date="$year$month$day"
        echo "  📅 Date from filename: $date"
    else
        # Try to extract date from file content
        file_date=$(grep -E '^date:|^Date:' "$file" | head -1 | sed 's/^[Dd]ate:\s*//' | sed 's/[^0-9\-\/]//g')
        if [ -n "$file_date" ]; then
            if [[ "$file_date" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
                year="${BASH_REMATCH[1]}"
                month="${BASH_REMATCH[2]}"
                day="${BASH_REMATCH[3]}"
                date="$year/$month/$day"
                sort_date="$year$month$day"
                echo "  📅 Date from content: $date"
            else
                date="$(date +%Y/%m/%d)"
                sort_date="$(date +%Y%m%d)"
                year="$(date +%Y)"
                month="$(date +%m)"
                day="$(date +%d)"
                echo "  📅 Using current date: $date"
            fi
        else
            date="$(date +%Y/%m/%d)"
            sort_date="$(date +%Y%m%d)"
            year="$(date +%Y)"
            month="$(date +%m)"
            day="$(date +%d)"
            echo "  📅 Using current date: $date"
        fi
    fi
    
    excerpt=$(extract_excerpt "$file")
    if [ -z "$excerpt" ]; then
        excerpt="No excerpt available..."
    fi
    
    echo "  ✅ Final values:"
    echo "    - Number: $num"
    echo "    - Title: $title"
    echo "    - Date: $date"
    echo "    - Excerpt: ${excerpt:0:50}..."
    
    post_data["$num,title"]="$title"
    post_data["$num,date"]="$date"
    post_data["$num,excerpt"]="$excerpt"
    post_data["$num,file"]="$file"
    post_data["$num,year"]="$year"
    post_data["$num,month"]="$month"
    post_data["$num,day"]="$day"
    post_data["$num,sort_date"]="$sort_date"
    
    content=$(process_markdown "$file")
    reading_time=$(echo "$content" | wc -w | awk '{print int($1/200)+1}')
    
    # Generate post page using safe method
    echo '<!DOCTYPE html>' > "public/p/${num}.html"
    echo '<html lang="en">' >> "public/p/${num}.html"
    echo '<head>' >> "public/p/${num}.html"
    echo '    <meta charset="utf-8">' >> "public/p/${num}.html"
    echo '    <meta name="viewport" content="width=device-width,initial-scale=1">' >> "public/p/${num}.html"
    echo "    <title>${title} - ${SITE_TITLE}</title>" >> "public/p/${num}.html"
    echo "    <meta name=\"description\" content=\"${excerpt:0:160}\">" >> "public/p/${num}.html"
    echo '    <style>' >> "public/p/${num}.html"
    cat /tmp/post.css >> "public/p/${num}.html"
    echo '    </style>' >> "public/p/${num}.html"
    echo '</head>' >> "public/p/${num}.html"
    echo '<body>' >> "public/p/${num}.html"
    echo '    <nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav>' >> "public/p/${num}.html"
    echo "    <h1>${title}</h1>" >> "public/p/${num}.html"
    echo "    <small>${date}</small>" >> "public/p/${num}.html"
    echo '    <div class="post-meta">' >> "public/p/${num}.html"
    echo "        <p><strong>Published:</strong> ${date}</p>" >> "public/p/${num}.html"
    echo "        <p><strong>Reading time:</strong> ~${reading_time} min</p>" >> "public/p/${num}.html"
    echo '    </div>' >> "public/p/${num}.html"
    echo "${content}" >> "public/p/${num}.html"
    echo '    <nav style="border-top:1px solid #e2e8f0;margin-top:3em;padding-top:1.5em">' >> "public/p/${num}.html"
    echo '        <a href="../">← Back to Blog</a> | <a href="../archive/">Archive</a>' >> "public/p/${num}.html"
    echo '    </nav>' >> "public/p/${num}.html"
    echo '</body>' >> "public/p/${num}.html"
    echo '</html>' >> "public/p/${num}.html"
    
    echo "✅ Processed: $num - $title"
done

# Generate main page
echo "🏠 Generating main page with consistent styling..."

echo '<!DOCTYPE html>' > public/index.html
echo '<html lang="en">' >> public/index.html
echo '<head>' >> public/index.html
echo '    <meta charset="utf-8">' >> public/index.html
echo '    <meta name="viewport" content="width=device-width,initial-scale=1">' >> public/index.html
echo "    <title>${SITE_TITLE}</title>" >> public/index.html
echo "    <meta name=\"description\" content=\"A blog with ${total} posts\">" >> public/index.html
echo '    <style>' >> public/index.html
cat /tmp/shared.css >> public/index.html
echo '    </style>' >> public/index.html
echo '</head>' >> public/index.html
echo '<body>' >> public/index.html
echo "    <h1>${SITE_TITLE}</h1>" >> public/index.html
echo "    <div class=\"stats\">📊 ${total} posts published</div>" >> public/index.html
echo '    <input id="search" placeholder="Search posts..." autocomplete="off">' >> public/index.html
echo '    <div id="search-info" class="search-results" style="display:none">' >> public/index.html
echo '        <span id="search-count">0</span> posts found' >> public/index.html
echo '    </div>' >> public/index.html
echo '    <div id="posts">' >> public/index.html

# Get recent posts (last 20, sorted by date newest first)
recent_nums=($(for file in "${files[@]}"; do
    slug=$(basename "$file" .md)
    num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "1")
    echo "${post_data["$num,sort_date"]} $num"
done | sort -rn | head -20 | cut -d' ' -f2))

for num in "${recent_nums[@]}"; do
    title="${post_data["$num,title"]}"
    date="${post_data["$num,date"]}"
    excerpt="${post_data["$num,excerpt"]}"
    
    echo "        <div class=\"post\" data-title=\"${title,,}\" data-excerpt=\"${excerpt,,}\" data-searchable=\"${title,,} ${excerpt,,}\" onclick=\"window.location.href='p/${num}.html'\">" >> public/index.html
    echo "            <small>${date}</small>" >> public/index.html
    echo "            <h2><a href=\"p/${num}.html\">${title}</a></h2>" >> public/index.html
    echo "            <div class=\"excerpt\">${excerpt}</div>" >> public/index.html
    echo "        </div>" >> public/index.html
done

echo '    </div>' >> public/index.html
echo '    <nav style="margin-top:2em">' >> public/index.html
echo '        <p>📚 <a href="archive/">View all posts in Archive →</a></p>' >> public/index.html
echo '    </nav>' >> public/index.html
echo '    <script>' >> public/index.html
cat /tmp/search.js >> public/index.html
echo '    </script>' >> public/index.html
echo '</body>' >> public/index.html
echo '</html>' >> public/index.html

# Generate archive page
echo "📚 Generating archive with fixed search and sticky header..."

echo '<!DOCTYPE html>' > public/archive/index.html
echo '<html lang="en">' >> public/archive/index.html
echo '<head>' >> public/archive/index.html
echo '    <meta charset="utf-8">' >> public/archive/index.html
echo '    <meta name="viewport" content="width=device-width,initial-scale=1">' >> public/archive/index.html
echo "    <title>Archive - ${SITE_TITLE}</title>" >> public/archive/index.html
echo "    <meta name=\"description\" content=\"Chronological archive of all ${total} posts\">" >> public/archive/index.html
echo '    <style>' >> public/archive/index.html
cat /tmp/shared.css >> public/archive/index.html
echo '    </style>' >> public/archive/index.html
echo '</head>' >> public/archive/index.html
echo '<body>' >> public/archive/index.html
echo '    <nav><a href="../">← Home</a></nav>' >> public/archive/index.html
echo '    <h1>Archive</h1>' >> public/archive/index.html
echo "    <div class=\"stats\">📊 ${total} posts chronologically ordered</div>" >> public/archive/index.html
echo '    <input id="search-main" placeholder="Search all posts..." autocomplete="off">' >> public/archive/index.html
echo '    <div id="search-info" class="search-results" style="display:none">' >> public/archive/index.html
echo "        <span id=\"search-count\">0</span> of ${total} posts found" >> public/archive/index.html
echo '    </div>' >> public/archive/index.html
echo '    <div id="sticky-header" class="sticky-header">' >> public/archive/index.html
echo '        <h2 id="sticky-title">Timeline</h2>' >> public/archive/index.html
echo '        <input id="search-sticky" placeholder="Search all posts..." autocomplete="off">' >> public/archive/index.html
echo '    </div>' >> public/archive/index.html
echo '    <div class="archive-content" id="archive">' >> public/archive/index.html

# Sort all posts chronologically (newest first)
sorted_nums=($(for file in "${files[@]}"; do
    slug=$(basename "$file" .md)
    num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "1")
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
    echo "            <div class=\"month-section\" data-month=\"$month\" data-year-month=\"$year $month_name\">" >> public/archive/index.html
    echo "                <div class=\"month-header\">" >> public/archive/index.html
    echo "                    <h3>$month_name</h3>" >> public/archive/index.html
    echo "                </div>" >> public/archive/index.html
    
    # Posts in this month (sorted by day, newest first)
    month_nums=($(printf '%s\n' ${year_months[$ym]} | xargs -n1 | while read num; do
        echo "${post_data["$num,sort_date"]} $num"
    done | sort -rn | cut -d' ' -f2))
    
    for num in "${month_nums[@]}"; do
        title="${post_data["$num,title"]}"
        date="${post_data["$num,date"]}"
        excerpt="${post_data["$num,excerpt"]}"
        
        echo "                <div class=\"post\" data-title=\"${title,,}\" data-excerpt=\"${excerpt,,}\" data-searchable=\"${title,,} ${excerpt,,}\" onclick=\"window.location.href='../p/${num}.html'\">" >> public/archive/index.html
        echo "                    <small>${date}</small>" >> public/archive/index.html
        echo "                    <h3><a href=\"../p/${num}.html\">${title}</a></h3>" >> public/archive/index.html
        echo "                    <div class=\"excerpt\">${excerpt}</div>" >> public/archive/index.html
        echo "                </div>" >> public/archive/index.html
    done
    echo "            </div>" >> public/archive/index.html
done

[ -n "$current_year" ] && echo "        </div>" >> public/archive/index.html

echo '    </div>' >> public/archive/index.html
echo '    <script>' >> public/archive/index.html
cat /tmp/archive.js >> public/archive/index.html
echo '    </script>' >> public/archive/index.html
echo '</body>' >> public/archive/index.html
echo '</html>' >> public/archive/index.html

# Cleanup temporary files
rm -f /tmp/shared.css /tmp/post.css /tmp/search.js /tmp/archive.js

echo "✅ Safe build completed successfully!"
echo "📊 Generated:"
echo "  - Main page with ${#recent_nums[@]} recent posts"
echo "  - Archive with all $total posts chronologically ordered"
echo "  - Ultra-smooth hover effects and perfect search functionality"
echo "  - Professional typography and consistent UI"
echo "  - $total individual post pages"
echo "  - Zero bash substitution errors"
echo "  - ✨ Consistent 832px width across all pages"
