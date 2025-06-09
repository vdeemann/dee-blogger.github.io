#!/bin/bash
set -e

echo "🚀 Building chronological timeline blog with sticky scroll..."

SITE_TITLE="${SITE_TITLE:-dee-blogger}"
BASE_URL="${BASE_URL:-https://vdeemann.github.io/dee-blogger.github.io}"

# Clean and create directories
rm -rf public
mkdir -p public/p public/archive

# Main page CSS (no hover effects)
read -r -d '' MAIN_CSS << 'EOF' || true
body{max-width:45em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.5;color:#333;background:#fff}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.9em;margin:0 0 .5em;color:#1a1a1a;font-weight:700}h2{font-size:1.2em;margin:0 0 .3em;color:#333;font-weight:600}h3{font-size:1.1em;margin:1.5em 0 .5em;color:#444;font-weight:600}p{margin:.4em 0}small{color:#666;display:block;margin:0 0 .5em;font-size:.9em}.post{margin:0 0 .8em;padding:.6em .8em;background:#fafafa;border-radius:4px;border:1px solid #e8e8e8}input{width:100%;margin:0 0 1em;padding:.6em;border:1px solid #ddd;border-radius:4px;font-size:.95em;background:#fff;box-sizing:border-box}nav{margin:1em 0;padding:.5em 0;border-bottom:1px solid #eee}.stats{background:#fff3cd;padding:.6em 1em;border-radius:4px;margin:1em 0;text-align:center;font-size:.95em;border:1px solid #ffeaa7}.search-highlight{background:#ffeb3b;padding:0 .2em;border-radius:2px}.excerpt{color:#666;margin:.3em 0 0;font-size:.9em;line-height:1.4}.search-results{background:#e8f4fd;padding:.8em;border-radius:4px;margin:1em 0;border-left:4px solid #0066cc}.no-results{text-align:center;color:#666;padding:2em;font-style:italic}.search-count{font-weight:600;color:#0066cc}
EOF

# Archive page CSS (with hover effects, no timeline visuals)
read -r -d '' ARCHIVE_CSS << 'EOF' || true
body{max-width:50em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.5;color:#333;background:#fff;position:relative}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.9em;margin:0 0 .5em;color:#1a1a1a;font-weight:700}h2{font-size:1.2em;margin:0 0 .3em;color:#333;font-weight:600}h3{font-size:1.1em;margin:0 0 .3em;color:#444;font-weight:600}p{margin:.4em 0}small{color:#666;display:block;margin:0 0 .3em;font-size:.9em}.post{margin:0 0 .6em;padding:.5em .7em;background:#fafafa;border-radius:4px;border:1px solid #e8e8e8;transition:all .2s ease;cursor:pointer}.post:hover{background:#f5f5f5;border-color:#ddd;transform:translateY(-1px);box-shadow:0 2px 4px rgba(0,0,0,.1)}input{width:100%;margin:0 0 1em;padding:.6em;border:1px solid #ddd;border-radius:4px;font-size:.95em;background:#fff;box-sizing:border-box}nav{margin:1em 0;padding:.5em 0;border-bottom:1px solid #eee}.stats{background:#fff3cd;padding:.6em 1em;border-radius:4px;margin:1em 0;text-align:center;font-size:.95em;border:1px solid #ffeaa7}.search-highlight{background:#ffeb3b;padding:0 .2em;border-radius:2px}.excerpt{color:#666;margin:.3em 0 0;font-size:.9em;line-height:1.4}.search-results{background:#e8f4fd;padding:.8em;border-radius:4px;margin:1em 0;border-left:4px solid #0066cc}.no-results{text-align:center;color:#666;padding:2em;font-style:italic}.search-count{font-weight:600;color:#0066cc}.sticky-header{position:sticky;top:0;background:#fff;border-bottom:2px solid #0066cc;padding:.8em 0;margin:0 0 1em;z-index:100;box-shadow:0 2px 4px rgba(0,0,0,.1);display:none}.sticky-header h2{margin:0 0 .5em;font-size:1em;color:#0066cc}.sticky-header input{margin:0;padding:.5em;font-size:.9em}.archive-content{margin:2em 0}.year-section{margin:0 0 2.5em}.month-section{margin:0 0 1.5em}.year-header{margin:0 0 1em}.month-header{margin:0 0 .8em;font-size:.95em;color:#666}
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

# Process each post
declare -A post_data
for i in "${!files[@]}"; do
    file="${files[$i]}"
    
    # Extract metadata
    title=$(head -n1 "$file" | sed 's/^# *//')
    slug=$(basename "$file" .md)
    num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "$((i + 1))")
    
    # Extract date from filename (YYYY-MM-DD format)
    if [[ "$slug" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
        year="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        day="${BASH_REMATCH[3]}"
        date="$year/$month/$day"
        sort_date="$year$month$day"
    else
        date="$(date +%Y/%m/%d)"
        sort_date="$(date +%Y%m%d)"
        year="$(date +%Y)"
        month="$(date +%m)"
        day="$(date +%d)"
    fi
    
    excerpt=$(extract_excerpt "$file")
    
    # Store data for later use
    post_data["$num,title"]="$title"
    post_data["$num,date"]="$date"
    post_data["$num,excerpt"]="$excerpt"
    post_data["$num,file"]="$file"
    post_data["$num,year"]="$year"
    post_data["$num,month"]="$month"
    post_data["$num,day"]="$day"
    post_data["$num,sort_date"]="$sort_date"
    
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
    <style>${MAIN_CSS}</style>
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
        
        searchInput.addEventListener('input', searchPosts);
    </script>
</body>
</html>
EOF
} > public/index.html

# Generate archive page with chronological timeline
echo "📚 Generating chronological timeline archive..."
{
    cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Archive - ${SITE_TITLE}</title>
    <meta name="description" content="Chronological archive of all ${total} posts">
    <style>${ARCHIVE_CSS}</style>
</head>
<body>
    <nav><a href="../">← Home</a></nav>
    <h1>Archive</h1>
    <div class="stats">📊 ${total} posts chronologically ordered</div>
    <input id="search-main" placeholder="🔍 Search all posts..." onkeyup="searchArchive()" autocomplete="off">
    <div id="search-info" class="search-results" style="display:none">
        <span id="search-count">0</span> of ${total} posts found
    </div>
    
    <div id="sticky-header" class="sticky-header">
        <h2 id="sticky-title">Timeline</h2>
        <input id="search-sticky" placeholder="🔍 Search all posts..." onkeyup="searchArchive()" autocomplete="off">
    </div>
    
    <div class="archive-content" id="archive">
EOF

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
            [ -n "$current_year" ] && echo "        </div>"
            echo "        <div class=\"year-section\" data-year=\"$year\">"
            echo "            <div class=\"year-header\">"
            echo "                <h2>$year</h2>"
            echo "            </div>"
            current_year="$year"
        fi
        
        # Month section
        echo "            <div class=\"month-section\" data-month=\"$month\" data-year-month=\"$year $month_name\">"
        echo "                <div class=\"month-header\">"
        echo "                    <h3>$month_name</h3>"
        echo "                </div>"
        
        # Posts in this month (sorted by day, newest first)
        month_nums=($(printf '%s\n' ${year_months[$ym]} | xargs -n1 | while read num; do
            echo "${post_data["$num,sort_date"]} $num"
        done | sort -rn | cut -d' ' -f2))
        
        for num in "${month_nums[@]}"; do
            title="${post_data["$num,title"]}"
            date="${post_data["$num,date"]}"
            excerpt="${post_data["$num,excerpt"]}"
            
            cat << EOF
                <div class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}" onclick="window.location.href='../p/${num}.html'">
                    <small>${date}</small>
                    <h3><a href="../p/${num}.html">${title}</a></h3>
                    <div class="excerpt">${excerpt}...</div>
                </div>
EOF
        done
        echo "            </div>"
    done
    
    [ -n "$current_year" ] && echo "        </div>"

    cat << 'EOF'
    </div>

    <script>
        let originalArchive = '';
        const searchMainInput = document.getElementById('search-main');
        const searchStickyInput = document.getElementById('search-sticky');
        const archiveContainer = document.getElementById('archive');
        const searchInfo = document.getElementById('search-info');
        const searchCount = document.getElementById('search-count');
        const stickyHeader = document.getElementById('sticky-header');
        const stickyTitle = document.getElementById('sticky-title');
        
        // Sticky scroll functionality
        function updateStickyHeader() {
            const scrollTop = window.pageYOffset;
            const searchMainRect = searchMainInput.getBoundingClientRect();
            
            // Show sticky header when main search input is out of view
            if (searchMainRect.bottom < 0) {
                stickyHeader.style.display = 'block';
                // Sync search values
                if (searchStickyInput.value !== searchMainInput.value) {
                    searchStickyInput.value = searchMainInput.value;
                }
            } else {
                stickyHeader.style.display = 'none';
            }
            
            // Update sticky title based on current section
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
        
        // Search functionality
        function searchArchive() {
            // Get query from whichever input is being used
            const mainQuery = searchMainInput.value.toLowerCase().trim();
            const stickyQuery = searchStickyInput.value.toLowerCase().trim();
            const query = mainQuery || stickyQuery;
            
            // Sync both inputs
            if (mainQuery !== stickyQuery) {
                if (mainQuery) {
                    searchStickyInput.value = searchMainInput.value;
                } else {
                    searchMainInput.value = searchStickyInput.value;
                }
            }
            
            if (!originalArchive) originalArchive = archiveContainer.innerHTML;
            
            if (!query) {
                archiveContainer.innerHTML = originalArchive;
                searchInfo.style.display = 'none';
                updateStickyHeader();
                return;
            }
            
            const posts = Array.from(archiveContainer.querySelectorAll('.post'));
            const filtered = posts.filter(post => {
                const searchable = post.dataset.searchable || '';
                return searchable.includes(query);
            });
            
            if (filtered.length > 0) {
                let html = '<div class="year-section"><div class="year-header"><h2>Search Results</h2></div><div class="month-section">';
                html += filtered.map(post => {
                    let postHtml = post.outerHTML;
                    const regex = new RegExp(`(${query})`, 'gi');
                    postHtml = postHtml.replace(regex, '<span class="search-highlight">$1</span>');
                    return postHtml;
                }).join('');
                html += '</div></div>';
                archiveContainer.innerHTML = html;
            } else {
                archiveContainer.innerHTML = '<div class="no-results">No posts found matching your search.</div>';
            }
            
            searchCount.textContent = filtered.length;
            searchInfo.style.display = 'block';
            
            // Update sticky header for search results
            if (stickyHeader.style.display === 'block') {
                stickyTitle.textContent = 'Search Results';
            }
        }
        
        // Event listeners
        searchMainInput.addEventListener('input', searchArchive);
        searchStickyInput.addEventListener('input', searchArchive);
        window.addEventListener('scroll', updateStickyHeader);
        window.addEventListener('resize', updateStickyHeader);
        
        // Initialize
        updateStickyHeader();
    </script>
</body>
</html>
EOF
} > public/archive/index.html

echo "✅ Chronological archive blog build completed!"
echo "📊 Generated:"
echo "  - Main page with ${#recent_nums[@]} recent posts (no hover effects)"
echo "  - Clean archive with all $total posts chronologically ordered"
echo "  - Sticky scroll with search bar showing current year/month context"
echo "  - Minimal design without timeline visuals"
echo "  - $total individual post pages"
echo "  - Enhanced search functionality with dual search inputs"
