#!/bin/bash
set -e

echo "🚀 Building enhanced blog with improved markdown processing and complete post listing..."

SITE_TITLE="${SITE_TITLE:-dee-blogger}"
BASE_URL="${BASE_URL:-https://vdeemann.github.io/dee-blogger.github.io}"

# Clean and create directories
rm -rf public
mkdir -p public/p public/archive

# Enhanced shared CSS for consistent styling across all pages
cat > public/shared.css << 'EOF'
body{max-width:55em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.6;color:#333;background:#fff;position:relative}
a{color:#0066cc;text-decoration:none}
a:hover{text-decoration:underline}
h1{font-size:1.9em;margin:0 0 .5em;color:#1a1a1a;font-weight:700}
h2{font-size:1.3em;margin:1.5em 0 .5em;color:#333;font-weight:600}
h3{font-size:1.1em;margin:1.2em 0 .4em;color:#444;font-weight:600}
h4{font-size:1em;margin:1em 0 .3em;color:#555;font-weight:600}
p{margin:.6em 0}
small{color:#666;display:block;margin:0 0 .3em;font-size:.9em}
.post{margin:0 0 .8em;padding:.7em .9em;background:#fafafa;border-radius:6px;border:1px solid #e8e8e8;cursor:pointer;transition:all 0.2s ease}
.post:hover{background:#f5f5f5;border-color:#ddd;transform:translateY(-1px);box-shadow:0 2px 8px rgba(0,0,0,0.1)}
input{width:100%;margin:0 0 1.2em;padding:.7em;border:1px solid #ddd;border-radius:6px;font-size:.95em;background:#fff;box-sizing:border-box}
nav{margin:1.2em 0;padding:.6em 0;border-bottom:1px solid #eee}
nav a{margin-right:1em;font-weight:500}
.stats{background:#fff3cd;padding:.8em 1.2em;border-radius:6px;margin:1.2em 0;text-align:center;font-size:.95em;border:1px solid #ffeaa7}
.search-highlight{background:#ffeb3b;padding:0 .2em;border-radius:2px;animation:highlight-fade 0.3s ease-out}
.excerpt{color:#666;margin:.4em 0 0;font-size:.9em;line-height:1.4}
.search-results{background:#e8f4fd;padding:1em;border-radius:6px;margin:1.2em 0;border-left:4px solid #0066cc}
.no-results{text-align:center;color:#666;padding:2em;font-style:italic}
.search-count{font-weight:600;color:#0066cc}
.sticky-header{position:sticky;top:0;background:rgba(255,255,255,0.95);backdrop-filter:blur(10px);border-bottom:2px solid #0066cc;padding:1em 0;margin:0 0 1.2em;z-index:100;box-shadow:0 2px 10px rgba(0,0,0,.1);display:none}
.sticky-header h2{margin:0 0 .6em;font-size:1.1em;color:#0066cc;font-weight:700}
.sticky-header input{margin:0;padding:.6em;font-size:.9em}
.archive-content{margin:2em 0}
.year-section{margin:0 0 3em}
.month-section{margin:0 0 2em}
.year-header{margin:0 0 1.2em;border-bottom:2px solid #eee;padding-bottom:.5em}
.month-header{margin:0 0 1em;font-size:.95em;color:#666;font-weight:600}
.post-date{font-size:.85em;color:#888;margin-bottom:.3em}
.post-title{margin:0 0 .3em;font-size:1.05em}
.post-title a{color:#333;font-weight:500}
EOF

# Enhanced post page CSS
cat > public/post.css << 'EOF'
body{max-width:55em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.6;color:#333;background:#fff}
a{color:#0066cc;text-decoration:none}
a:hover{text-decoration:underline}
h1{font-size:2.2em;margin:0 0 .6em;color:#1a1a1a;font-weight:700;line-height:1.2}
h2{font-size:1.4em;margin:2em 0 .6em;color:#333;font-weight:600;border-bottom:2px solid #e2e8f0;padding-bottom:.4em}
h3{font-size:1.2em;margin:1.8em 0 .5em;color:#444;font-weight:600}
h4{font-size:1.05em;margin:1.5em 0 .4em;color:#555;font-weight:600}
p{margin:.8em 0}
small{color:#666;display:block;margin:0 0 .4em;font-size:.9em}
strong{font-weight:600;color:#333}
em{font-style:italic;color:#444}
code{background:#f7fafc;color:#e53e3e;padding:.2em .4em;border-radius:3px;font-family:"SF Mono",Monaco,Consolas,"Liberation Mono","Courier New",monospace;font-size:.85em;border:1px solid #e2e8f0}
pre{background:#f7fafc;padding:1em 1.2em;margin:2em 0;border-radius:8px;overflow-x:auto;border:1px solid #e2e8f0;box-shadow:0 2px 6px rgba(0,0,0,.08);position:relative}
pre code{background:transparent;padding:0;font-size:.9em;color:#2d3748;display:block;border:0;white-space:pre}
ul,ol{margin:1.5em 0;padding-left:2.2em}
li{margin:.6em 0;line-height:1.6}
nav{margin:1.2em 0;padding:.6em 0;border-bottom:1px solid #eee}
nav a{margin-right:1.2em;font-weight:500}
blockquote{background:#f7fafc;border-left:4px solid #0066cc;margin:2em 0;padding:1.2em 1.8em;border-radius:0 8px 8px 0;color:#4a5568;font-style:italic;box-shadow:0 2px 6px rgba(0,0,0,.08)}
blockquote p{margin:.6em 0}
blockquote h1,blockquote h2,blockquote h3,blockquote h4{color:#2d3748;font-style:normal}
hr{border:0;height:1px;background:#e2e8f0;margin:3em 0}
.post-meta{background:#f7fafc;padding:1.2em 1.5em;border-radius:8px;margin:2em 0;border-left:4px solid #0066cc;box-shadow:0 2px 6px rgba(0,0,0,.08)}
.post-meta p{margin:.4em 0;font-size:.95em;color:#4a5568}
.copy-btn{position:absolute;top:.8em;right:.8em;background:#0066cc;color:#fff;border:0;border-radius:4px;padding:.4em .8em;font-size:.8em;cursor:pointer;opacity:.8;transition:all 0.2s ease}
.copy-btn:hover{opacity:1;background:#0052a3}
.copy-btn.copied{background:#28a745}
.mermaid{background:#f7fafc;border:1px solid #e2e8f0;border-radius:8px;padding:1.5em;margin:2em 0;text-align:center;box-shadow:0 2px 6px rgba(0,0,0,.08)}
.table-container{overflow-x:auto;margin:2em 0;border-radius:8px;box-shadow:0 2px 6px rgba(0,0,0,.08)}
table{width:100%;border-collapse:collapse;background:#fff;border-radius:8px;overflow:hidden}
th,td{padding:1em 1.2em;text-align:left;border-bottom:1px solid #e2e8f0}
th{background:#f7fafc;font-weight:600;color:#2d3748}
tr:hover{background:#fafafa}
.toc{background:#f7fafc;border:1px solid #e2e8f0;border-radius:8px;padding:1.5em;margin:2em 0}
.toc h3{margin:0 0 1em;color:#2d3748}
.toc ul{margin:0;padding-left:1.5em}
.toc a{color:#0066cc;font-weight:normal}
EOF

# Improved markdown processor with better handling of complex content
process_markdown() {
    local file="$1"
    
    # Skip the first line (title) and process the rest
    tail -n +2 "$file" | awk '
    BEGIN { 
        in_code = 0
        in_list = 0
        in_blockquote = 0
        in_table = 0
        code_lang = ""
        list_type = ""
        blockquote_content = ""
    }
    
    # Handle code blocks
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
    
    # Handle content inside code blocks
    in_code { 
        gsub(/&/, "\\&amp;")
        gsub(/</, "\\&lt;")
        gsub(/>/, "\\&gt;")
        print
        next 
    }
    
    # Handle blockquotes
    /^> / {
        if (!in_blockquote) {
            print "<blockquote>"
            in_blockquote = 1
        }
        gsub(/^> /, "")
        if ($0 ~ /^#/) {
            gsub(/^#### /, "")
            gsub(/^### /, "")
            gsub(/^## /, "")
            gsub(/^# /, "")
            print "<h4>" $0 "</h4>"
        } else {
            print "<p>" $0 "</p>"
        }
        next
    }
    
    # End blockquote
    in_blockquote && !/^> / && !/^$/ {
        print "</blockquote>"
        in_blockquote = 0
    }
    
    # Handle headers
    /^#### / { gsub(/^#### /, ""); print "<h4>" $0 "</h4>"; next }
    /^### / { gsub(/^### /, ""); print "<h3>" $0 "</h3>"; next }
    /^## / { gsub(/^## /, ""); print "<h2>" $0 "</h2>"; next }
    /^# / { gsub(/^# /, ""); print "<h1>" $0 "</h1>"; next }
    
    # Handle tables
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
    
    # End table
    in_table && !/^\| / && !/^$/ {
        print "</tbody></table></div>"
        in_table = 0
    }
    
    # Handle unordered lists
    /^[•*-] / {
        if (!in_list || list_type != "ul") {
            if (in_list && list_type == "ol") {
                print "</ol>"
            }
            if (!in_list) {
                print "<ul>"
            }
            in_list = 1
            list_type = "ul"
        }
        gsub(/^[•*-] /, "")
        print "<li>" $0 "</li>"
        next
    }
    
    # Handle ordered lists
    /^[0-9]+\. / {
        if (!in_list || list_type != "ol") {
            if (in_list && list_type == "ul") {
                print "</ul>"
            }
            if (!in_list) {
                print "<ol>"
            }
            in_list = 1
            list_type = "ol"
        }
        gsub(/^[0-9]+\. /, "")
        print "<li>" $0 "</li>"
        next
    }
    
    # End lists
    in_list && !/^[•*-] / && !/^[0-9]+\. / && !/^$/ {
        if (list_type == "ul") {
            print "</ul>"
        } else {
            print "</ol>"
        }
        in_list = 0
        list_type = ""
    }
    
    # Handle mermaid diagrams
    /^```mermaid/ {
        print "<div class=\"mermaid\">"
        while ((getline line) > 0 && line != "```") {
            print line
        }
        print "</div>"
        next
    }
    
    # Handle horizontal rules
    /^---+$/ { print "<hr>"; next }
    
    # Handle empty lines
    /^$/ { 
        if (in_list) {
            if (list_type == "ul") {
                print "</ul>"
            } else {
                print "</ol>"
            }
            in_list = 0
            list_type = ""
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
    
    # Handle regular paragraphs
    /./ {
        # Clean up any open elements
        if (in_list) {
            if (list_type == "ul") {
                print "</ul>"
            } else {
                print "</ol>"
            }
            in_list = 0
            list_type = ""
        }
        if (in_blockquote) {
            print "</blockquote>"
            in_blockquote = 0
        }
        if (in_table) {
            print "</tbody></table></div>"
            in_table = 0
        }
        
        # Process inline formatting
        gsub(/\*\*([^*]+)\*\*/, "<strong>\\1</strong>")
        gsub(/\*([^*]+)\*/, "<em>\\1</em>")
        gsub(/`([^`]+)`/, "<code>\\1</code>")
        gsub(/\[([^\]]+)\]\(([^)]+)\)/, "<a href=\"\\2\">\\1</a>")
        
        print "<p>" $0 "</p>"
    }
    
    # Clean up at end
    END {
        if (in_code) {
            if (code_lang != "") {
                print "<button class=\"copy-btn\" onclick=\"copyCode(this)\">📋 Copy</button>"
            }
            print "</code></pre>"
        }
        if (in_list) {
            if (list_type == "ul") {
                print "</ul>"
            } else {
                print "</ol>"
            }
        }
        if (in_blockquote) {
            print "</blockquote>"
        }
        if (in_table) {
            print "</tbody></table></div>"
        }
    }'
}

# Enhanced excerpt extraction that handles complex content
extract_excerpt() {
    local file="$1"
    local excerpt
    
    # Extract first meaningful paragraph, skipping headers and metadata
    excerpt=$(tail -n +2 "$file" | \
        grep -v '^#' | \
        grep -v '^```' | \
        grep -v '^$' | \
        grep -v '^>' | \
        grep -v '^|' | \
        grep -v '^-\+$' | \
        grep -v '^\*' | \
        head -3 | \
        tr '\n' ' ' | \
        sed 's/[*`#\[\]()]/./g' | \
        sed 's/\s\+/ /g' | \
        sed 's/^\s*//' | \
        cut -c1-200)
    
    if [ -z "$excerpt" ]; then
        excerpt="A detailed technical article covering advanced topics and implementation strategies."
    fi
    
    echo "$excerpt" | sed 's/\.\.\.*//' | sed 's/\s*$/.../'
}

# Improved date extraction with better fallback handling
extract_date_from_filename() {
    local filename="$1"
    local basename_file=$(basename "$filename" .md)
    
    # Try to extract date from filename (YYYY-MM-DD format)
    if [[ "$basename_file" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}/${BASH_REMATCH[3]}"
        return
    fi
    
    # Try git commit date
    if command -v git >/dev/null 2>&1 && [ -d .git ]; then
        local git_date=$(git log -1 --format="%ai" -- "$filename" 2>/dev/null | cut -d' ' -f1)
        if [ -n "$git_date" ] && [[ "$git_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            echo "$git_date" | tr '-' '/'
            return
        fi
    fi
    
    # Try file modification date
    if command -v stat >/dev/null 2>&1; then
        local mod_date
        if stat --version >/dev/null 2>&1; then
            # GNU stat
            mod_date=$(stat -c %Y "$filename" 2>/dev/null)
        else
            # BSD stat (macOS)
            mod_date=$(stat -f %m "$filename" 2>/dev/null)
        fi
        
        if [ -n "$mod_date" ] && [ "$mod_date" -gt 0 ]; then
            date -d "@$mod_date" "+%Y/%m/%d" 2>/dev/null || date -r "$mod_date" "+%Y/%m/%d" 2>/dev/null
            return
        fi
    fi
    
    # Fallback to current date
    date "+%Y/%m/%d"
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
        *) echo "Month $month" ;;
    esac
}

# Safe text escaping for HTML
html_escape() {
    local text="$1"
    echo "$text" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
}

# Find all markdown files and process them
echo "📁 Scanning for markdown files..."

# Look for markdown files in common locations
files=()
for location in "content" "posts" "articles" "_posts" "."; do
    if [ -d "$location" ]; then
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find "$location" -name "*.md" -type f -print0 2>/dev/null)
    fi
done

# Remove duplicates and sort
if [ ${#files[@]} -gt 0 ]; then
    readarray -t files < <(printf '%s\n' "${files[@]}" | sort -u)
fi

total=${#files[@]}

if [ $total -eq 0 ]; then
    echo "❌ No markdown files found!"
    echo "Searched in: content/, posts/, articles/, _posts/, and current directory"
    echo "Please ensure your markdown files are in one of these directories."
    exit 1
fi

echo "📊 Found $total markdown files to process"

# Process each post
declare -A post_data
processed_count=0

for i in "${!files[@]}"; do
    file="${files[$i]}"
    
    echo "Processing ($((i+1))/$total): $file"
    
    if [ ! -f "$file" ]; then
        echo "⚠️  Warning: File not found: $file"
        continue
    fi
    
    if [ ! -s "$file" ]; then
        echo "⚠️  Warning: File is empty: $file"
        continue
    fi
    
    # Extract title from first line
    title=$(head -n1 "$file" | sed 's/^#* *//' | sed 's/^\s*//' | sed 's/\s*$//')
    if [ -z "$title" ]; then
        title="Untitled Post $((i + 1))"
    fi
    
    # Generate unique slug/ID
    slug=$(basename "$file" .md)
    # Use file index as unique ID to avoid conflicts
    num=$((i + 1))
    
    # Extract date
    date_string=$(extract_date_from_filename "$file")
    
    # Parse date components
    if [[ "$date_string" =~ ^([0-9]{4})/([0-9]{2})/([0-9]{2})$ ]]; then
        year="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        day="${BASH_REMATCH[3]}"
        sort_date="$year$month$day"
    else
        echo "⚠️  Warning: Could not parse date '$date_string' for $file"
        year="$(date +%Y)"
        month="$(date +%m)"
        day="$(date +%d)"
        date_string="$year/$month/$day"
        sort_date="$year$month$day"
    fi
    
    # Extract excerpt
    excerpt=$(extract_excerpt "$file")
    if [ -z "$excerpt" ]; then
        excerpt="A comprehensive technical article with detailed insights and practical examples..."
    fi
    
    echo "  ✓ Title: $title"
    echo "  ✓ Date: $date_string"
    echo "  ✓ Excerpt: ${excerpt:0:60}..."
    
    # Store post data
    post_data["$num,title"]="$title"
    post_data["$num,date"]="$date_string"
    post_data["$num,excerpt"]="$excerpt"
    post_data["$num,file"]="$file"
    post_data["$num,year"]="$year"
    post_data["$num,month"]="$month"
    post_data["$num,day"]="$day"
    post_data["$num,sort_date"]="$sort_date"
    post_data["$num,slug"]="$slug"
    
    # Process markdown content
    content=$(process_markdown "$file")
    if [ -z "$content" ]; then
        echo "⚠️  Warning: No content extracted from $file"
        content="<p>Content could not be processed.</p>"
    fi
    
    # Calculate reading stats
    word_count=$(echo "$content" | wc -w)
    reading_time=$(( (word_count + 199) / 200 ))  # Round up
    if [ $reading_time -eq 0 ]; then
        reading_time=1
    fi
    
    # HTML escape values for safe insertion
    title_safe=$(html_escape "$title")
    excerpt_safe=$(html_escape "$excerpt")
    slug_safe=$(html_escape "$slug")
    
    # Generate individual post HTML using here document to avoid sed issues
    cat > "public/p/${num}.html" << HTML_END
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${title_safe} - ${SITE_TITLE}</title>
    <meta name="description" content="${excerpt_safe:0:160}">
    <meta name="author" content="${SITE_TITLE}">
    <meta property="og:title" content="${title_safe}">
    <meta property="og:description" content="${excerpt_safe:0:160}">
    <meta property="og:type" content="article">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism.min.css">
    <link rel="stylesheet" href="../post.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mermaid/10.6.1/mermaid.min.js"></script>
</head>
<body>
    <nav>
        <a href="../">← Blog Home</a>
        <a href="../archive/">Archive</a>
    </nav>
    
    <article>
        <header>
            <h1>${title_safe}</h1>
            <small>Published on ${date_string}</small>
            
            <div class="post-meta">
                <p><strong>📅 Published:</strong> ${date_string}</p>
                <p><strong>⏱️ Reading time:</strong> ~${reading_time} min (${word_count} words)</p>
                <p><strong>📝 Source:</strong> ${slug_safe}.md</p>
            </div>
        </header>
        
        <main>
${content}
        </main>
    </article>
    
    <nav style="border-top:1px solid #e2e8f0;margin-top:3em;padding-top:1.5em">
        <a href="../">← Back to Blog</a> | 
        <a href="../archive/">View Archive</a>
    </nav>
    
    <script>
        // Initialize Mermaid with better configuration
        mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            securityLevel: 'loose',
            flowchart: {
                useMaxWidth: true,
                htmlLabels: true
            }
        });
        
        // Enhanced copy code functionality
        function copyCode(button) {
            const pre = button.closest('pre');
            const code = pre.querySelector('code');
            const text = code.textContent;
            
            navigator.clipboard.writeText(text).then(() => {
                const originalText = button.textContent;
                button.textContent = '✓ Copied!';
                button.classList.add('copied');
                setTimeout(() => {
                    button.textContent = originalText;
                    button.classList.remove('copied');
                }, 2000);
            }).catch(() => {
                // Fallback for older browsers
                const textarea = document.createElement('textarea');
                textarea.value = text;
                textarea.style.position = 'fixed';
                textarea.style.opacity = '0';
                document.body.appendChild(textarea);
                textarea.select();
                document.execCommand('copy');
                document.body.removeChild(textarea);
                
                const originalText = button.textContent;
                button.textContent = '✓ Copied!';
                button.classList.add('copied');
                setTimeout(() => {
                    button.textContent = originalText;
                    button.classList.remove('copied');
                }, 2000);
            });
        }
        
        // Add copy buttons to all pre elements after page load
        document.addEventListener('DOMContentLoaded', function() {
            document.querySelectorAll('pre').forEach(pre => {
                if (!pre.querySelector('.copy-btn')) {
                    const button = document.createElement('button');
                    button.className = 'copy-btn';
                    button.innerHTML = '📋 Copy';
                    button.onclick = () => copyCode(button);
                    pre.appendChild(button);
                }
            });
        });
    </script>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-core.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/plugins/autoloader/prism-autoloader.min.js"></script>
</body>
</html>
HTML_END
    
    processed_count=$((processed_count + 1))
    echo "  ✅ Generated: public/p/${num}.html"
done

echo "📄 Successfully processed $processed_count out of $total files"

# Generate main page
echo "🏠 Generating main page..."

cat > public/index.html << 'MAIN_START'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
MAIN_START

# Add title and meta tags
cat >> public/index.html << MAIN_META
    <title>${SITE_TITLE}</title>
    <meta name="description" content="Technical blog with ${processed_count} posts covering software architecture, development, and technology insights">
    <meta name="author" content="${SITE_TITLE}">
    <link rel="stylesheet" href="shared.css">
</head>
<body>
    <header>
        <h1>${SITE_TITLE}</h1>
        <div class="stats">📊 ${processed_count} posts published</div>
    </header>
    
    <main>
        <input id="search" placeholder="🔍 Search posts by title or content..." autocomplete="off">
        <div id="search-info" class="search-results" style="display:none">
            Found <span id="search-count">0</span> posts matching your search
        </div>
        
        <div id="posts">
MAIN_META

# Get all posts sorted by date (newest first)
all_nums=($(for ((i=1; i<=processed_count; i++)); do
    echo "${post_data["$i,sort_date"]} $i"
done | sort -rn | cut -d' ' -f2))

# Show recent posts on main page (latest 15)
recent_count=0
max_recent=15

for num in "${all_nums[@]}"; do
    if [ $recent_count -ge $max_recent ]; then
        break
    fi
    
    title="${post_data["$num,title"]}"
    date="${post_data["$num,date"]}"
    excerpt="${post_data["$num,excerpt"]}"
    
    if [ -z "$title" ]; then
        continue
    fi
    
    # Prepare data for search and display (properly escaped)
    title_lower=$(echo "${title}" | tr '[:upper:]' '[:lower:]' | html_escape)
    excerpt_lower=$(echo "${excerpt}" | tr '[:upper:]' '[:lower:]' | html_escape)
    searchable_lower=$(echo "${title} ${excerpt}" | tr '[:upper:]' '[:lower:]' | html_escape)
    title_display=$(html_escape "$title")
    excerpt_display=$(html_escape "$excerpt")
    
    cat >> public/index.html << POST_ENTRY
            <div class="post" data-title="${title_lower}" data-excerpt="${excerpt_lower}" data-searchable="${searchable_lower}" onclick="window.location.href='p/${num}.html'">
                <div class="post-date">${date}</div>
                <div class="post-title">
                    <a href="p/${num}.html">${title_display}</a>
                </div>
                <div class="excerpt">${excerpt_display}</div>
            </div>
POST_ENTRY
    
    recent_count=$((recent_count + 1))
done

cat >> public/index.html << 'MAIN_END'
        </div>
        
        <nav style="margin-top:2em">
            <p>📚 <a href="archive/">View all posts in Archive →</a></p>
        </nav>
    </main>
    
    <script>
        (function() {
            let originalPosts = null;
            let postsData = [];
            let searchTimeout = null;
            let lastQuery = '';
            
            const searchInput = document.getElementById('search');
            const postsContainer = document.getElementById('posts');
            const searchInfo = document.getElementById('search-info');
            const searchCount = document.getElementById('search-count');
            
            if (!searchInput || !postsContainer || !searchInfo || !searchCount) {
                console.error('Search elements not found');
                return;
            }
            
            // Cache original posts and extract searchable data
            function initializeSearch() {
                if (originalPosts === null) {
                    originalPosts = postsContainer.innerHTML;
                    
                    // Extract and cache post data for faster searching
                    const tempDiv = document.createElement('div');
                    tempDiv.innerHTML = originalPosts;
                    postsData = Array.from(tempDiv.children).map(post => ({
                        element: post,
                        searchable: (post.dataset.searchable || '').toLowerCase(),
                        html: post.outerHTML
                    }));
                }
            }
            
            // Optimized highlighting using DocumentFragment
            function highlightText(text, query) {
                if (!query || query.length < 2) return text; // Skip highlighting for very short queries
                
                const escapedQuery = query.replace(/[.*+?^${}()|[\]\\]/g, '\\cat >> public/index.html << 'MAIN_END'
        </div>
        
        <nav style="margin-top:2em">
            <p>📚 <a href="archive/">View all posts in Archive →</a></p>
        </nav>
    </main>
    
    <script>
        (function() {
            let originalPosts = null;
            const searchInput = document.getElementById('search');
            const postsContainer = document.getElementById('posts');
            const searchInfo = document.getElementById('search-info');
            const searchCount = document.getElementById('search-count');
            
            if (!searchInput || !postsContainer || !searchInfo || !searchCount) {
                console.error('Search elements not found');
                return;
            }
            
            function escapeRegExp(string) {
                return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            }
            
            function highlightText(text, query) {
                if (!query) return text;
                const escapedQuery = escapeRegExp(query);
                const regex = new RegExp('(' + escapedQuery + ')', 'gi');
                return text.replace(regex, '<span class="search-highlight">$1</span>');
            }
            
            function searchPosts() {
                const query = searchInput.value.toLowerCase().trim();
                
                if (originalPosts === null) {
                    originalPosts = postsContainer.innerHTML;
                }
                
                if (!query) {
                    postsContainer.innerHTML = originalPosts;
                    searchInfo.style.display = 'none';
                    return;
                }
                
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
                        html = highlightText(html, query);
                        return html;
                    }).join('');
                } else {
                    postsContainer.innerHTML = '<div class="no-results">No posts found matching your search. Try different keywords.</div>';
                }
                
                searchCount.textContent = filtered.length;
                searchInfo.style.display = 'block';
            }
            
            searchInput.addEventListener('input', searchPosts);
            console.log('Main page search initialized');
        })();
    </script>
</body>
</html>
MAIN_END');
                const regex = new RegExp('(' + escapedQuery + ')', 'gi');
                return text.replace(regex, '<span class="search-highlight">$1</span>');
            }
            
            // Fast search implementation with debouncing
            function performSearch(query) {
                initializeSearch();
                
                if (!query || query === lastQuery) return;
                lastQuery = query;
                
                if (query.length === 0) {
                    postsContainer.innerHTML = originalPosts;
                    searchInfo.style.display = 'none';
                    return;
                }
                
                // Filter posts efficiently
                const filtered = postsData.filter(post => 
                    post.searchable.includes(query)
                );
                
                if (filtered.length > 0) {
                    // Use DocumentFragment for efficient DOM manipulation
                    const fragment = document.createDocumentFragment();
                    const tempContainer = document.createElement('div');
                    
                    // Only highlight if query is substantial to avoid performance issues
                    if (query.length >= 2) {
                        tempContainer.innerHTML = filtered.map(post => 
                            highlightText(post.html, query)
                        ).join('');
                    } else {
                        tempContainer.innerHTML = filtered.map(post => post.html).join('');
                    }
                    
                    // Move all children to fragment at once
                    while (tempContainer.firstChild) {
                        fragment.appendChild(tempContainer.firstChild);
                    }
                    
                    // Replace content in one operation
                    postsContainer.innerHTML = '';
                    postsContainer.appendChild(fragment);
                } else {
                    postsContainer.innerHTML = '<div class="no-results">No posts found matching your search. Try different keywords.</div>';
                }
                
                searchCount.textContent = filtered.length;
                searchInfo.style.display = 'block';
            }
            
            // Debounced search function
            function debouncedSearch() {
                const query = searchInput.value.toLowerCase().trim();
                
                // Clear existing timeout
                if (searchTimeout) {
                    clearTimeout(searchTimeout);
                }
                
                // Immediate search for short queries or clearing
                if (query.length <= 1) {
                    performSearch(query);
                    return;
                }
                
                // Debounced search for longer queries (150ms delay)
                searchTimeout = setTimeout(() => {
                    performSearch(query);
                }, 150);
            }
            
            // Use more efficient event handling
            searchInput.addEventListener('input', debouncedSearch);
            
            // Initialize on load
            initializeSearch();
            console.log('Optimized main page search initialized');
        })();
    </script>
</body>
</html>
MAIN_END

# Generate archive page
echo "📚 Generating archive page..."

cat > public/archive/index.html << 'ARCHIVE_START'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
ARCHIVE_START

cat >> public/archive/index.html << ARCHIVE_META
    <title>Archive - ${SITE_TITLE}</title>
    <meta name="description" content="Complete chronological archive of all ${processed_count} posts">
    <link rel="stylesheet" href="../shared.css">
</head>
<body>
    <nav><a href="../">← Home</a></nav>
    
    <header>
        <h1>Post Archive</h1>
        <div class="stats">📊 All ${processed_count} posts in chronological order</div>
    </header>
    
    <main>
        <input id="search-main" placeholder="🔍 Search all posts..." autocomplete="off">
        <div id="search-info" class="search-results" style="display:none">
            Found <span id="search-count">0</span> of ${processed_count} posts
        </div>
        
        <div id="sticky-header" class="sticky-header">
            <h2 id="sticky-title">Archive</h2>
            <input id="search-sticky" placeholder="🔍 Search all posts..." autocomplete="off">
        </div>
        
        <div class="archive-content" id="archive">
ARCHIVE_META

# Group posts by year and month
declare -A year_months
for num in "${all_nums[@]}"; do
    year="${post_data["$num,year"]}"
    month="${post_data["$num,month"]}"
    if [ -n "$year" ] && [ -n "$month" ]; then
        ym="$year-$month"
        year_months["$ym"]+="$num "
    fi
done

# Generate archive structure
current_year=""
for ym in $(printf '%s\n' "${!year_months[@]}" | sort -rn); do
    year=$(echo "$ym" | cut -d- -f1)
    month=$(echo "$ym" | cut -d- -f2)
    month_name=$(get_month_name "$month")
    
    # Year section header
    if [ "$year" != "$current_year" ]; then
        [ -n "$current_year" ] && echo "        </div>" >> public/archive/index.html
        cat >> public/archive/index.html << YEAR_SECTION
        <div class="year-section" data-year="$year">
            <div class="year-header">
                <h2>$year</h2>
            </div>
YEAR_SECTION
        current_year="$year"
    fi
    
    # Month section
    cat >> public/archive/index.html << MONTH_SECTION
            <div class="month-section" data-month="$month" data-year-month="$year $month_name">
                <div class="month-header">
                    <h3>$month_name $year</h3>
                </div>
MONTH_SECTION
    
    # Posts in this month (sorted by day, newest first)
    month_nums=($(printf '%s\n' ${year_months[$ym]} | xargs -n1 | while read -r num; do
        echo "${post_data["$num,sort_date"]} $num"
    done | sort -rn | cut -d' ' -f2))
    
    for num in "${month_nums[@]}"; do
        title="${post_data["$num,title"]}"
        date="${post_data["$num,date"]}"
        excerpt="${post_data["$num,excerpt"]}"
        
        if [ -z "$title" ]; then
            continue
        fi
        
        # Prepare data safely
        title_lower=$(echo "${title}" | tr '[:upper:]' '[:lower:]' | html_escape)
        excerpt_lower=$(echo "${excerpt}" | tr '[:upper:]' '[:lower:]' | html_escape)
        searchable_lower=$(echo "${title} ${excerpt}" | tr '[:upper:]' '[:lower:]' | html_escape)
        title_display=$(html_escape "$title")
        excerpt_display=$(html_escape "$excerpt")
        
        cat >> public/archive/index.html << ARCHIVE_POST
                <div class="post" data-title="${title_lower}" data-excerpt="${excerpt_lower}" data-searchable="${searchable_lower}" onclick="window.location.href='../p/${num}.html'">
                    <div class="post-date">${date}</div>
                    <div class="post-title">
                        <a href="../p/${num}.html">${title_display}</a>
                    </div>
                    <div class="excerpt">${excerpt_display}</div>
                </div>
ARCHIVE_POST
    done
    echo "            </div>" >> public/archive/index.html
done

[ -n "$current_year" ] && echo "        </div>" >> public/archive/index.html

cat >> public/archive/index.html << 'ARCHIVE_END'
        </div>
    </main>
    
    <script>
        (function() {
            let originalArchive = null;
            let archiveData = [];
            let searchTimeout = null;
            let lastQuery = '';
            let isSearchActive = false;
            
            const searchMainInput = document.getElementById('search-main');
            const searchStickyInput = document.getElementById('search-sticky');
            const archiveContainer = document.getElementById('archive');
            const searchInfo = document.getElementById('search-info');
            const searchCount = document.getElementById('search-count');
            const stickyHeader = document.getElementById('sticky-header');
            const stickyTitle = document.getElementById('sticky-title');
            
            if (!searchMainInput || !searchStickyInput || !archiveContainer) {
                console.error('Archive search elements not found');
                return;
            }
            
            // Cache archive data for faster searching
            function initializeArchive() {
                if (originalArchive === null) {
                    originalArchive = archiveContainer.innerHTML;
                    
                    // Extract and cache post data
                    const tempDiv = document.createElement('div');
                    tempDiv.innerHTML = originalArchive;
                    const posts = tempDiv.querySelectorAll('.post');
                    
                    archiveData = Array.from(posts).map(post => ({
                        element: post.cloneNode(true),
                        searchable: (post.dataset.searchable || '').toLowerCase(),
                        html: post.outerHTML
                    }));
                }
            }
            
            // Optimized highlighting with performance checks
            function highlightText(text, query) {
                if (!query || query.length < 2) return text;
                
                const escapedQuery = query.replace(/[.*+?^${}()|[\]\\]/g, '\\cat >> public/archive/index.html << 'ARCHIVE_END'
        </div>
    </main>
    
    <script>
        (function() {
            let originalArchive = null;
            const searchMainInput = document.getElementById('search-main');
            const searchStickyInput = document.getElementById('search-sticky');
            const archiveContainer = document.getElementById('archive');
            const searchInfo = document.getElementById('search-info');
            const searchCount = document.getElementById('search-count');
            const stickyHeader = document.getElementById('sticky-header');
            const stickyTitle = document.getElementById('sticky-title');
            
            if (!searchMainInput || !searchStickyInput || !archiveContainer) {
                console.error('Archive search elements not found');
                return;
            }
            
            function escapeRegExp(string) {
                return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            }
            
            function highlightText(text, query) {
                if (!query) return text;
                const escapedQuery = escapeRegExp(query);
                const regex = new RegExp('(' + escapedQuery + ')', 'gi');
                return text.replace(regex, '<span class="search-highlight">$1</span>');
            }
            
            function updateStickyHeader() {
                try {
                    const searchMainRect = searchMainInput.getBoundingClientRect();
                    
                    if (searchMainRect.bottom < 0) {
                        stickyHeader.style.display = 'block';
                        if (searchStickyInput.value !== searchMainInput.value) {
                            searchStickyInput.value = searchMainInput.value;
                        }
                    } else {
                        stickyHeader.style.display = 'none';
                    }
                    
                    // Update sticky header title based on visible section
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
                            
                            let title = 'Archive';
                            if (yearSection) {
                                title = yearSection.dataset.year || 'Archive';
                                if (monthSection && monthSection.dataset.yearMonth) {
                                    title = monthSection.dataset.yearMonth;
                                }
                            }
                            
                            stickyTitle.textContent = title;
                        } else {
                            stickyTitle.textContent = 'Archive';
                        }
                    }
                } catch (error) {
                    console.error('Sticky header update error:', error);
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
                
                // Store original content
                if (originalArchive === null) {
                    originalArchive = archiveContainer.innerHTML;
                }
                
                if (!query) {
                    archiveContainer.innerHTML = originalArchive;
                    searchInfo.style.display = 'none';
                    updateStickyHeader();
                    return;
                }
                
                // Search through posts
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
                        postHtml = highlightText(postHtml, query);
                        return postHtml;
                    }).join('');
                    html += '</div></div>';
                    archiveContainer.innerHTML = html;
                    
                    if (stickyHeader.style.display === 'block') {
                        stickyTitle.textContent = 'Search Results (' + filtered.length + ')';
                    }
                } else {
                    archiveContainer.innerHTML = '<div class="no-results">No posts found matching your search. Try different keywords.</div>';
                    if (stickyHeader.style.display === 'block') {
                        stickyTitle.textContent = 'Search Results (0)';
                    }
                }
                
                searchCount.textContent = filtered.length;
                searchInfo.style.display = 'block';
            }
            
            // Event listeners
            searchMainInput.addEventListener('input', searchArchive);
            searchStickyInput.addEventListener('input', searchArchive);
            window.addEventListener('scroll', updateStickyHeader);
            window.addEventListener('resize', updateStickyHeader);
            
            // Initialize
            updateStickyHeader();
            console.log('Archive search initialized');
        })();
    </script>
</body>
</html>
ARCHIVE_END');
                const regex = new RegExp('(' + escapedQuery + ')', 'gi');
                return text.replace(regex, '<span class="search-highlight">$1</span>');
            }
            
            // Throttled sticky header update
            let stickyUpdateTimeout = null;
            function updateStickyHeader() {
                if (stickyUpdateTimeout) return;
                
                stickyUpdateTimeout = setTimeout(() => {
                    try {
                        const searchMainRect = searchMainInput.getBoundingClientRect();
                        
                        if (searchMainRect.bottom < 0) {
                            stickyHeader.style.display = 'block';
                            if (searchStickyInput.value !== searchMainInput.value) {
                                searchStickyInput.value = searchMainInput.value;
                            }
                        } else {
                            stickyHeader.style.display = 'none';
                        }
                        
                        // Update title only if sticky header is visible and not in search mode
                        if (stickyHeader.style.display === 'block' && !isSearchActive) {
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
                                
                                let title = 'Archive';
                                if (yearSection) {
                                    title = yearSection.dataset.year || 'Archive';
                                    if (monthSection && monthSection.dataset.yearMonth) {
                                        title = monthSection.dataset.yearMonth;
                                    }
                                }
                                stickyTitle.textContent = title;
                            } else {
                                stickyTitle.textContent = 'Archive';
                            }
                        }
                    } catch (error) {
                        console.error('Sticky header update error:', error);
                    }
                    stickyUpdateTimeout = null;
                }, 16); // ~60fps
            }
            
            // High-performance search function
            function performSearch(query) {
                initializeArchive();
                
                if (query === lastQuery) return;
                lastQuery = query;
                
                // Sync inputs efficiently
                if (searchMainInput.value !== searchStickyInput.value) {
                    const activeInput = document.activeElement;
                    if (activeInput === searchMainInput) {
                        searchStickyInput.value = searchMainInput.value;
                    } else if (activeInput === searchStickyInput) {
                        searchMainInput.value = searchStickyInput.value;
                    }
                }
                
                if (!query) {
                    archiveContainer.innerHTML = originalArchive;
                    searchInfo.style.display = 'none';
                    isSearchActive = false;
                    updateStickyHeader();
                    return;
                }
                
                isSearchActive = true;
                
                // Efficient filtering
                const filtered = archiveData.filter(post => 
                    post.searchable.includes(query)
                );
                
                if (filtered.length > 0) {
                    // Use optimized DOM construction
                    const fragment = document.createDocumentFragment();
                    const searchContainer = document.createElement('div');
                    searchContainer.className = 'year-section';
                    
                    const headerDiv = document.createElement('div');
                    headerDiv.className = 'year-header';
                    headerDiv.innerHTML = '<h2>Search Results</h2>';
                    
                    const monthDiv = document.createElement('div');
                    monthDiv.className = 'month-section';
                    
                    // Only apply highlighting for substantial queries
                    if (query.length >= 2) {
                        monthDiv.innerHTML = filtered.map(post => 
                            highlightText(post.html, query)
                        ).join('');
                    } else {
                        monthDiv.innerHTML = filtered.map(post => post.html).join('');
                    }
                    
                    searchContainer.appendChild(headerDiv);
                    searchContainer.appendChild(monthDiv);
                    fragment.appendChild(searchContainer);
                    
                    // Single DOM update
                    archiveContainer.innerHTML = '';
                    archiveContainer.appendChild(fragment);
                    
                    if (stickyHeader.style.display === 'block') {
                        stickyTitle.textContent = 'Search Results (' + filtered.length + ')';
                    }
                } else {
                    archiveContainer.innerHTML = '<div class="no-results">No posts found matching your search. Try different keywords.</div>';
                    if (stickyHeader.style.display === 'block') {
                        stickyTitle.textContent = 'Search Results (0)';
                    }
                }
                
                searchCount.textContent = filtered.length;
                searchInfo.style.display = 'block';
            }
            
            // Optimized debounced search
            function debouncedSearch() {
                const mainQuery = searchMainInput.value.toLowerCase().trim();
                const stickyQuery = searchStickyInput.value.toLowerCase().trim();
                const query = mainQuery || stickyQuery;
                
                if (searchTimeout) {
                    clearTimeout(searchTimeout);
                }
                
                // Immediate response for clearing or very short queries
                if (query.length <= 1) {
                    performSearch(query);
                    return;
                }
                
                // Debounced search for performance
                searchTimeout = setTimeout(() => {
                    performSearch(query);
                }, 120);
            }
            
            // Optimized event listeners
            searchMainInput.addEventListener('input', debouncedSearch);
            searchStickyInput.addEventListener('input', debouncedSearch);
            
            // Throttled scroll and resize handlers
            let scrollTimeout = null;
            window.addEventListener('scroll', () => {
                if (!scrollTimeout) {
                    scrollTimeout = setTimeout(() => {
                        updateStickyHeader();
                        scrollTimeout = null;
                    }, 16);
                }
            }, { passive: true });
            
            window.addEventListener('resize', updateStickyHeader, { passive: true });
            
            // Initialize
            initializeArchive();
            updateStickyHeader();
            console.log('Optimized archive search initialized');
        })();
    </script>
</body>
</html>
ARCHIVE_END

echo ""
echo "✅ Enhanced blog build completed successfully!"
echo ""
echo "📊 Summary:"
echo "  ✓ Processed $processed_count markdown files"
echo "  ✓ Generated individual post pages with enhanced styling"
echo "  ✓ Created main page with recent posts and search"
echo "  ✓ Built comprehensive archive with chronological organization"
echo "  ✓ Added sticky navigation and improved search functionality"
echo "  ✓ Enhanced code block formatting with copy-to-clipboard"
echo "  ✓ Integrated mermaid diagram support"
echo "  ✓ Improved mobile responsiveness and accessibility"
echo ""
echo "🚀 Features included:"
echo "  • Real-time search with highlighting"
echo "  • Responsive design with hover effects"  
echo "  • Code syntax highlighting with Prism.js"
echo "  • Mermaid diagram rendering"
echo "  • Copy-to-clipboard functionality"
echo "  • Sticky archive navigation"
echo "  • SEO-optimized meta tags"
echo "  • Reading time calculations"
echo "  • Chronological post organization"
echo ""
echo "📁 Output structure:"
echo "  public/"
echo "  ├── index.html (main page with recent posts)"
echo "  ├── shared.css (shared styles)"
echo "  ├── post.css (post-specific styles)"
echo "  ├── archive/"
echo "  │   └── index.html (complete archive)"
echo "  └── p/"
echo "      ├── 1.html"
echo "      ├── 2.html"
echo "      └── ... (individual post pages)"
echo ""
echo "🎯 All blog posts should now be correctly listed and formatted!"
