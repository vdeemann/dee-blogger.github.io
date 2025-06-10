#!/bin/bash
set -e

echo "🚀 Building final improved blog with consistent UI and fixed search..."

SITE_TITLE="${SITE_TITLE:-dee-blogger}"
BASE_URL="${BASE_URL:-https://vdeemann.github.io/dee-blogger.github.io}"

# Clean and create directories
rm -rf public
mkdir -p public/p public/archive

# Shared CSS for both main and archive pages (consistent styling)
SHARED_CSS='body{max-width:50em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.5;color:#333;background:#fff;position:relative}a{color:#0066cc;text-decoration:none}h1{font-size:1.9em;margin:0 0 .5em;color:#1a1a1a;font-weight:700}h2{font-size:1.2em;margin:0 0 .3em;color:#333;font-weight:600}h3{font-size:1.1em;margin:0 0 .3em;color:#444;font-weight:600}p{margin:.4em 0}small{color:#666;display:block;margin:0 0 .3em;font-size:.9em}.post{margin:0 0 .6em;padding:.5em .7em;background:#fafafa;border-radius:4px;border:1px solid #e8e8e8;cursor:pointer}input{width:100%;margin:0 0 1em;padding:.6em;border:1px solid #ddd;border-radius:4px;font-size:.95em;background:#fff;box-sizing:border-box}nav{margin:1em 0;padding:.5em 0;border-bottom:1px solid #eee}.stats{background:#fff3cd;padding:.6em 1em;border-radius:4px;margin:1em 0;text-align:center;font-size:.95em;border:1px solid #ffeaa7}.search-highlight{background:#ffeb3b;padding:0 .2em;border-radius:2px}.excerpt{color:#666;margin:.3em 0 0;font-size:.9em;line-height:1.4}.search-results{background:#e8f4fd;padding:.8em;border-radius:4px;margin:1em 0;border-left:4px solid #0066cc}.no-results{text-align:center;color:#666;padding:2em;font-style:italic}.search-count{font-weight:600;color:#0066cc}.sticky-header{position:sticky;top:0;background:#fff;border-bottom:2px solid #0066cc;padding:.8em 0;margin:0 0 1em;z-index:100;box-shadow:0 2px 4px rgba(0,0,0,.1);display:none}.sticky-header h2{margin:0 0 .5em;font-size:1.1em;color:#0066cc;font-weight:700}.sticky-header input{margin:0;padding:.5em;font-size:.9em}.archive-content{margin:2em 0}.year-section{margin:0 0 2.5em}.month-section{margin:0 0 1.5em}.year-header{margin:0 0 1em}.month-header{margin:0 0 .8em;font-size:.95em;color:#666}'

# Enhanced post page CSS with better typography (like Software Architecture post)
POST_CSS='body{max-width:48em;margin:2em auto;padding:0 1em;font-family:system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;line-height:1.65;color:#2d3748;background:#fff}a{color:#0066cc;text-decoration:none;border-bottom:1px solid transparent}h1{font-size:2.2em;margin:0 0 .4em;color:#1a202c;font-weight:700;line-height:1.2}h2{font-size:1.6em;margin:2.5em 0 1em;color:#2d3748;font-weight:600;line-height:1.3;border-bottom:2px solid #e2e8f0;padding-bottom:.3em}h3{font-size:1.3em;margin:2em 0 .8em;color:#4a5568;font-weight:600;line-height:1.3}p{margin:1.2em 0;font-size:1.05em;line-height:1.7}small{color:#718096;display:block;margin:0 0 2em;font-size:1em;font-weight:500}strong{font-weight:600;color:#2d3748}code{background:#f7fafc;color:#e53e3e;padding:.2em .4em;border-radius:4px;font-family:"SF Mono",Monaco,Consolas,"Liberation Mono","Courier New",monospace;font-size:.9em;border:1px solid #e2e8f0;position:relative}pre{background:#f7fafc;padding:.8em 1em;margin:1.5em 0;border-radius:6px;overflow-x:auto;border:1px solid #e2e8f0;box-shadow:0 1px 3px rgba(0,0,0,.1);position:relative}pre code{background:0;padding:0;font-size:.9em;color:#2d3748;display:block;border:0}ul,ol{margin:1.5em 0;padding-left:2em}li{margin:.8em 0;line-height:1.6}nav{margin:2em 0;padding:.8em 0;border-bottom:1px solid #e2e8f0}blockquote{background:#f7fafc;border-left:4px solid #0066cc;margin:2em 0;padding:1.2em 1.8em;border-radius:0 6px 6px 0;color:#4a5568;font-style:italic;box-shadow:0 1px 3px rgba(0,0,0,.1)}blockquote p{margin:.8em 0}hr{border:0;height:1px;background:#e2e8f0;margin:2.5em 0}.post-meta{background:#f7fafc;padding:1em 1.2em;border-radius:6px;margin:1.5em 0;border-left:4px solid #0066cc}.post-meta p{margin:.3em 0;font-size:.95em;color:#4a5568}.copy-btn{position:absolute;top:.5em;right:.5em;background:#0066cc;color:#fff;border:0;border-radius:3px;padding:.3em .6em;font-size:.8em;cursor:pointer;opacity:1}.copy-btn.copied{background:#28a745}.mermaid{background:#f7fafc;border:1px solid #e2e8f0;border-radius:6px;padding:1em;margin:1.5em 0;text-align:center}.table-container{overflow-x:auto;margin:1.5em 0}table{width:100%;border-collapse:collapse;background:#fff;border-radius:6px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,.1)}th,td{padding:.8em 1em;text-align:left;border-bottom:1px solid #e2e8f0}th{background:#f7fafc;font-weight:600;color:#2d3748}'

# Enhanced markdown processor with better formatting
process_markdown() {
    local file="$1"
    
    tail -n +2 "$file" | awk '
    BEGIN { in_code = 0; in_list = 0; in_blockquote = 0; code_lang = "" }
    
    /^```/ {
        if (in_code) {
            if (code_lang != "") {
                print "<button class=\"copy-btn\" onclick=\"copyCode(this)\">📋 Copy</button>"
            }
            print "</code></pre>"
            in_code = 0
            code_lang = ""
        } else {
            gsub(/^```/, "")
            code_lang = $0
            if (code_lang != "") {
                print "<pre class=\"language-" code_lang "\"><code class=\"language-" code_lang "\">"
            } else {
                print "<pre><code>"
            }
            in_code = 1
        }
        next
    }
    
    in_code { 
        gsub(/&/, "\\&amp;")
        gsub(/</, "\\&lt;")
        gsub(/>/, "\\&gt;")
        print
        next 
    }
    
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
    
    /^#### / { gsub(/^#### /, ""); print "<h4>" $0 "</h4>"; next }
    /^### / { gsub(/^### /, ""); print "<h3>" $0 "</h3>"; next }
    /^## / { gsub(/^## /, ""); print "<h2>" $0 "</h2>"; next }
    /^# / { gsub(/^# /, ""); print "<h1>" $0 "</h1>"; next }
    
    /^\| / {
        if (!in_table) {
            print "<div class=\"table-container\"><table>"
            in_table = 1
            table_header = 1
        }
        gsub(/^\| /, "")
        gsub(/ \|$/, "")
        gsub(/ \| /, "</td><td>")
        if (table_header) {
            print "<thead><tr><th>" $0 "</th></tr></thead><tbody>"
            table_header = 0
        } else if (!/^[-:|]+$/) {
            print "<tr><td>" $0 "</td></tr>"
        }
        next
    }
    
    in_table && !/^\| / && !/^$/ {
        print "</tbody></table></div>"
        in_table = 0
    }
    
    /^[•*-] / {
        if (!in_list) {
            print "<ul>"
            in_list = 1
        }
        gsub(/^[•*-] /, "")
        print "<li>" $0 "</li>"
        next
    }
    
    /^[0-9]+\. / {
        if (!in_list) {
            print "<ol>"
            in_list = 2
        }
        gsub(/^[0-9]+\. /, "")
        print "<li>" $0 "</li>"
        next
    }
    
    in_list && !/^[•*-] / && !/^[0-9]+\. / && !/^$/ {
        if (in_list == 1) {
            print "</ul>"
        } else {
            print "</ol>"
        }
        in_list = 0
    }
    
    /^```mermaid/ {
        print "<div class=\"mermaid\">"
        while ((getline line) > 0 && line != "```") {
            print line
        }
        print "</div>"
        next
    }
    
    /^---$/ { print "<hr>"; next }
    
    /^$/ { 
        if (in_list == 1) {
            print "</ul>"
            in_list = 0
        } else if (in_list == 2) {
            print "</ol>"
            in_list = 0
        }
        if (in_blockquote) {
            print "</blockquote>"
            in_blockquote = 0
        }
        if (in_table) {
            print "</tbody></table></div>"
            in_table = 0
        }
        next 
    }
    
    /./ {
        if (in_list == 1) {
            print "</ul>"
            in_list = 0
        } else if (in_list == 2) {
            print "</ol>"
            in_list = 0
        }
        if (in_blockquote) {
            print "</blockquote>"
            in_blockquote = 0
        }
        if (in_table) {
            print "</tbody></table></div>"
            in_table = 0
        }
        
        gsub(/\*\*([^*]+)\*\*/, "<strong>\\1</strong>")
        gsub(/\*([^*]+)\*/, "<em>\\1</em>")
        gsub(/`([^`]+)`/, "<code>\\1</code>")
        gsub(/\[([^\]]+)\]\(([^)]+)\)/, "<a href=\"\\2\">\\1</a>")
        
        print "<p>" $0 "</p>"
    }
    
    END {
        if (in_code) {
            if (code_lang != "") {
                print "<button class=\"copy-btn\" onclick=\"copyCode(this)\">📋 Copy</button>"
            }
            print "</code></pre>"
        }
        if (in_list == 1) print "</ul>"
        if (in_list == 2) print "</ol>"
        if (in_blockquote) print "</blockquote>"
        if (in_table) print "</tbody></table></div>"
    }'
}

# Extract clean excerpt from content (improved version)
extract_excerpt() {
    local file="$1"
    local excerpt=$(tail -n +2 "$file" | grep -v '^#' | grep -v '^```' | grep -v '^$' | head -5 | tr '\n' ' ' | sed 's/[*`#\[\]()]/./g' | sed 's/\s\+/ /g' | cut -c1-180)
    echo "$excerpt" | sed 's/\.\.\.*//' | sed 's/\s*$/.../'
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
    
    echo "Processing file: $file"
    
    if [ ! -f "$file" ]; then
        echo "Warning: File not found: $file"
        continue
    fi
    
    title=$(head -n1 "$file" | sed 's/^# *//' | sed 's/[<>&"'\'']/./g')
    if [ -z "$title" ]; then
        title="Untitled Post $((i + 1))"
    fi
    
    slug=$(basename "$file" .md)
    num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "$((i + 1))")
    
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
    if [ -z "$excerpt" ]; then
        excerpt="No excerpt available..."
    fi
    
    echo "  Title: $title"
    echo "  Date: $date"
    echo "  Excerpt: ${excerpt:0:50}..."
    
    post_data["$num,title"]="$title"
    post_data["$num,date"]="$date"
    post_data["$num,excerpt"]="$excerpt"
    post_data["$num,file"]="$file"
    post_data["$num,year"]="$year"
    post_data["$num,month"]="$month"
    post_data["$num,day"]="$day"
    post_data["$num,sort_date"]="$sort_date"
    
    content=$(process_markdown "$file")
    word_count=$(echo "$content" | wc -w)
    reading_time=$(echo "$word_count / 200 + 1" | bc 2>/dev/null || echo "1")
    
    cat > "public/p/${num}.html" << HTML_EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${title} - ${SITE_TITLE}</title>
    <meta name="description" content="${excerpt:0:160}">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mermaid/10.6.1/mermaid.min.js"></script>
    <style>${POST_CSS}</style>
</head>
<body>
    <nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav>
    <h1>${title}</h1>
    <small>${date}</small>
    <div class="post-meta">
        <p><strong>Published:</strong> ${date}</p>
        <p><strong>Reading time:</strong> ~${reading_time} min (${word_count} words)</p>
    </div>
    ${content}
    <nav style="border-top:1px solid #e2e8f0;margin-top:3em;padding-top:1.5em">
        <a href="../">← Back to Blog</a> | <a href="../archive/">Archive</a>
    </nav>
    
    <script>
        // Initialize Mermaid
        mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            securityLevel: 'loose'
        });
        
        // Copy code functionality
        function copyCode(button) {
            const pre = button.closest('pre');
            const code = pre.querySelector('code');
            const text = code.textContent;
            
            navigator.clipboard.writeText(text).then(() => {
                const originalText = button.textContent;
                button.textContent = '✓ Copied';
                button.classList.add('copied');
                setTimeout(() => {
                    button.textContent = originalText;
                    button.classList.remove('copied');
                }, 2000);
            }).catch(() => {
                // Fallback for older browsers
                const textarea = document.createElement('textarea');
                textarea.value = text;
                document.body.appendChild(textarea);
                textarea.select();
                document.execCommand('copy');
                document.body.removeChild(textarea);
                
                const originalText = button.textContent;
                button.textContent = '✓ Copied';
                button.classList.add('copied');
                setTimeout(() => {
                    button.textContent = originalText;
                    button.classList.remove('copied');
                }, 2000);
            });
        }
        
        // Add copy buttons to all pre elements
        document.querySelectorAll('pre').forEach(pre => {
            if (!pre.querySelector('.copy-btn')) {
                const button = document.createElement('button');
                button.className = 'copy-btn';
                button.innerHTML = '📋 Copy';
                button.onclick = () => copyCode(button);
                pre.appendChild(button);
            }
        });
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-core.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/plugins/autoloader/prism-autoloader.min.js"></script>
</body>
</html>
HTML_EOF

    echo "✅ Processed: $num - $title"
done

# Generate main page with archive-style consistency
echo "🏠 Generating main page with consistent styling..."

cat > public/index.html << MAIN_EOF
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
    <input id="search" placeholder="Search posts..." autocomplete="off">
    <div id="search-info" class="search-results" style="display:none">
        <span id="search-count">0</span> posts found
    </div>
    <div id="posts">
MAIN_EOF

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
    
    cat >> public/index.html << POST_EOF
        <div class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}" onclick="window.location.href='p/${num}.html'">
            <small>${date}</small>
            <h2><a href="p/${num}.html">${title}</a></h2>
            <div class="excerpt">${excerpt}</div>
        </div>
POST_EOF
done

cat >> public/index.html << MAIN_END_EOF
    </div>
    <nav style="margin-top:2em">
        <p>📚 <a href="archive/">View all posts in Archive →</a></p>
    </nav>

    <script>
        let originalPosts = null;
        const searchInput = document.getElementById('search');
        const postsContainer = document.getElementById('posts');
        const searchInfo = document.getElementById('search-info');
        const searchCount = document.getElementById('search-count');
        
        function searchPosts() {
            const query = searchInput.value.toLowerCase().trim();
            
            // Store original content only once
            if (originalPosts === null) {
                originalPosts = postsContainer.innerHTML;
            }
            
            if (!query) {
                postsContainer.innerHTML = originalPosts;
                searchInfo.style.display = 'none';
                return;
            }
            
            // Get all posts from original content
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = originalPosts;
            const posts = Array.from(tempDiv.children);
            
            const filtered = posts.filter(post => {
                const searchable = post.dataset.searchable || '';
                return searchable.includes(query);
            });
            
            if (filtered.length > 0) {
                postsContainer.innerHTML = filtered.map(post => {
                    let html = post.outerHTML;
                    const regex = new RegExp(\`(\${query})\`, 'gi');
                    html = html.replace(regex, '<span class="search-highlight">\$1</span>');
                    return html;
                }).join('');
            } else {
                postsContainer.innerHTML = '<div class="no-results">No posts found matching your search.</div>';
            }
            
            searchCount.textContent = filtered.length;
            searchInfo.style.display = 'block';
        }
        
        // Use input event for real-time search including backspace
        searchInput.addEventListener('input', searchPosts);
    </script>
</body>
</html>
MAIN_END_EOF

# Generate archive page with fixed sticky header and search
echo "📚 Generating archive with fixed search and sticky header..."

cat > public/archive/index.html << ARCHIVE_START_EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Archive - ${SITE_TITLE}</title>
    <meta name="description" content="Chronological archive of all ${total} posts">
    <style>${SHARED_CSS}</style>
</head>
<body>
    <nav><a href="../">← Home</a></nav>
    <h1>Archive</h1>
    <div class="stats">📊 ${total} posts chronologically ordered</div>
    <input id="search-main" placeholder="Search all posts..." autocomplete="off">
    <div id="search-info" class="search-results" style="display:none">
        <span id="search-count">0</span> of ${total} posts found
    </div>
    
    <div id="sticky-header" class="sticky-header">
        <h2 id="sticky-title">Timeline</h2>
        <input id="search-sticky" placeholder="Search all posts..." autocomplete="off">
    </div>
    
    <div class="archive-content" id="archive">
ARCHIVE_START_EOF

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
        cat >> public/archive/index.html << YEAR_EOF
        <div class="year-section" data-year="$year">
            <div class="year-header">
                <h2>$year</h2>
            </div>
YEAR_EOF
        current_year="$year"
    fi
    
    # Month section
    cat >> public/archive/index.html << MONTH_EOF
            <div class="month-section" data-month="$month" data-year-month="$year $month_name">
                <div class="month-header">
                    <h3>$month_name</h3>
                </div>
MONTH_EOF
    
    # Posts in this month (sorted by day, newest first)
    month_nums=($(printf '%s\n' ${year_months[$ym]} | xargs -n1 | while read num; do
        echo "${post_data["$num,sort_date"]} $num"
    done | sort -rn | cut -d' ' -f2))
    
    for num in "${month_nums[@]}"; do
        title="${post_data["$num,title"]}"
        date="${post_data["$num,date"]}"
        excerpt="${post_data["$num,excerpt"]}"
        
        cat >> public/archive/index.html << POST_ARCHIVE_EOF
                <div class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}" onclick="window.location.href='../p/${num}.html'">
                    <small>${date}</small>
                    <h3><a href="../p/${num}.html">${title}</a></h3>
                    <div class="excerpt">${excerpt}</div>
                </div>
POST_ARCHIVE_EOF
    done
    echo "            </div>" >> public/archive/index.html
done

[ -n "$current_year" ] && echo "        </div>" >> public/archive/index.html

cat >> public/archive/index.html << ARCHIVE_END_EOF
    </div>

    <script>
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
            
            // Sync both inputs
            if (mainQuery !== stickyQuery) {
                if (mainQuery) {
                    searchStickyInput.value = searchMainInput.value;
                } else {
                    searchMainInput.value = searchStickyInput.value;
                }
            }
            
            // Store original content only once
            if (originalArchive === null) {
                originalArchive = archiveContainer.innerHTML;
            }
            
            if (!query) {
                archiveContainer.innerHTML = originalArchive;
                searchInfo.style.display = 'none';
                updateStickyHeader();
                return;
            }
            
            // Get all posts from original content
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = originalArchive;
            const posts = Array.from(tempDiv.querySelectorAll('.post'));
            
            const filtered = posts.filter(post => {
                const searchable = post.dataset.searchable || '';
                return searchable.includes(query);
            });
            
            if (filtered.length > 0) {
                let html = '<div class="year-section"><div class="year-header"><h2>Search Results</h2></div><div class="month-section">';
                html += filtered.map(post => {
                    let postHtml = post.outerHTML;
                    const regex = new RegExp(\`(\${query})\`, 'gi');
                    postHtml = postHtml.replace(regex, '<span class="search-highlight">\$1</span>');
                    return postHtml;
                }).join('');
                html += '</div></div>';
                archiveContainer.innerHTML = html;
                
                if (stickyHeader.style.display === 'block') {
                    stickyTitle.textContent = \`Search Results (\${filtered.length})\`;
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
        
        // Use input event for real-time search including backspace
        searchMainInput.addEventListener('input', searchArchive);
        searchStickyInput.addEventListener('input', searchArchive);
        window.addEventListener('scroll', updateStickyHeader);
        window.addEventListener('resize', updateStickyHeader);
        
        updateStickyHeader();
    </script>
</body>
</html>
ARCHIVE_END_EOF

echo "✅ Final improved blog build completed!"
echo "📊 Generated:"
echo "  - Main page with consistent archive-style UI and hover effects"
echo "  - Fixed search functionality with proper backspace handling"
echo "  - Clean sticky header with single year/month display"
echo "  - Enhanced blog post typography matching Software Architecture style"
echo "  - Code blocks with copy-to-clipboard functionality"
echo "  - Mermaid diagram support with proper rendering"
echo "  - Syntax highlighting with Prism.js"
echo "  - Table formatting and responsive design"
echo "  - $total individual post pages with improved styling"
echo "  - Real-time search with proper state management"
