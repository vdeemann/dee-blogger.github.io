#!/bin/bash
set -e

echo "🚀 Building enhanced blog with improved markdown processing and complete post listing..."

SITE_TITLE="${SITE_TITLE:-dee-blogger}"
BASE_URL="${BASE_URL:-https://vdeemann.github.io/dee-blogger.github.io}"

# Clean and create directories
rm -rf public
mkdir -p public/p public/archive

# Enhanced shared CSS for consistent styling across all pages (hover effects removed)
cat > public/shared.css << 'EOF'
body{max-width:55em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.6;color:#333;background:#f0ece8;position:relative}
a{color:#0066cc;text-decoration:none}
a:hover{text-decoration:underline}
h1{font-size:1.9em;margin:0 0 .5em;color:#1a1a1a;font-weight:700}
h2{font-size:1.3em;margin:1.5em 0 .5em;color:#333;font-weight:600}
h3{font-size:1.1em;margin:1.2em 0 .4em;color:#444;font-weight:600}
h4{font-size:1em;margin:1em 0 .3em;color:#555;font-weight:600}
p{margin:.6em 0}
small{color:#666;display:block;margin:0 0 .3em;font-size:.9em}
.post{margin:0 0 .8em;padding:.7em .9em;background:#fafafa;border-radius:6px;border:1px solid #e8e8e8;cursor:pointer;transition:all 0.2s ease;transform-origin:top;opacity:1}
.post:hover{border-color:#0066cc}
input{width:100%;margin:0 0 1.2em;padding:.7em;border:1px solid #ddd;border-radius:6px;font-size:.95em;background:#fff;box-sizing:border-box;transition:all 0.2s ease}
input:focus{outline:none;border-color:#0066cc;box-shadow:0 0 0 3px rgba(0,102,204,0.1);background:#f8faff}
input.searching{background:#f0f8ff url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%230066cc" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>') no-repeat right 10px center;background-size:20px;padding-right:40px}
nav{margin:1.2em 0;padding:.6em 0;border-bottom:1px solid #eee}
nav a{margin-right:1em;font-weight:500}
.stats{background:#fff3cd;padding:.8em 1.2em;border-radius:6px;margin:1.2em 0;text-align:center;font-size:.95em;border:1px solid #ffeaa7}
.search-highlight{background:#ffeb3b;padding:2px 4px;border-radius:3px;font-weight:600;color:#000;box-shadow:0 0 0 2px rgba(255,235,59,0.3);animation:highlight-pulse 0.5s ease-out}
@keyframes highlight-pulse{0%{transform:scale(1.2);background:#fff59d}100%{transform:scale(1);background:#ffeb3b}}
.excerpt{color:#666;margin:.4em 0 0;font-size:.9em;line-height:1.4}
.search-results{background:#e8f4fd;padding:1em;border-radius:6px;margin:1.2em 0;border-left:4px solid #0066cc;animation:slideIn 0.3s ease-out}
@keyframes slideIn{from{opacity:0;transform:translateY(-10px)}to{opacity:1;transform:translateY(0)}}
.no-results{text-align:center;color:#666;padding:2em;font-style:italic;animation:fadeIn 0.3s ease-out}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
.search-term{font-weight:600;color:#0066cc}
.no-results{text-align:center;color:#666;padding:2em;font-style:italic}
.search-count{font-weight:600;color:#0066cc}
.sticky-header{position:sticky;top:0;background:rgba(240,236,232,0.95);backdrop-filter:blur(10px);border-bottom:2px solid #0066cc;padding:1em 0;margin:0 0 1.2em;z-index:100;box-shadow:0 2px 10px rgba(0,0,0,.1);display:none}
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
.global-search{position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.8);z-index:1000;display:none;animation:fadeIn 0.2s ease-out}
.global-search.active{display:flex;align-items:flex-start;justify-content:center;padding:3em 1em}
.global-search-container{background:#fff;border-radius:12px;width:100%;max-width:45em;max-height:80vh;display:flex;flex-direction:column;box-shadow:0 20px 60px rgba(0,0,0,0.3);animation:slideDown 0.3s ease-out}
@keyframes slideDown{from{transform:translateY(-30px);opacity:0}to{transform:translateY(0);opacity:1}}
.global-search-header{padding:1.5em;border-bottom:1px solid #e8e8e8;position:relative}
.global-search-header h2{margin:0;font-size:1.3em;color:#333}
.global-search-close{position:absolute;top:1.5em;right:1.5em;background:none;border:none;font-size:1.5em;color:#666;cursor:pointer;padding:0;width:32px;height:32px;display:flex;align-items:center;justify-content:center;border-radius:50%;transition:all 0.2s}
.global-search-close:hover{background:#f0f0f0;color:#333}
.global-search-input{width:100%;padding:1em 3em 1em 1.2em;border:2px solid #0066cc;border-radius:8px;font-size:1.1em;margin-top:1em;background:#fff url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%230066cc" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>') no-repeat right 12px center;background-size:24px}
.global-search-input:focus{outline:none;box-shadow:0 0 0 4px rgba(0,102,204,0.15)}
.global-search-results{flex:1;overflow-y:auto;padding:1.5em}
.global-search-status{padding:1em;text-align:center;color:#666;font-style:italic}
.search-result-item{margin-bottom:1.5em;padding:1em;background:#fafafa;border-radius:8px;border:1px solid #e8e8e8;cursor:pointer;transition:all 0.2s}
.search-result-item:hover{border-color:#0066cc;transform:translateY(-2px);box-shadow:0 4px 12px rgba(0,0,0,0.1)}
.search-result-title{font-size:1.1em;font-weight:600;margin-bottom:0.3em}
.search-result-title a{color:#333}
.search-result-date{font-size:0.85em;color:#888;margin-bottom:0.5em}
.search-result-excerpt{font-size:0.9em;color:#666;line-height:1.5}
.search-trigger{position:fixed;bottom:2em;right:2em;background:#0066cc;color:#fff;border:none;border-radius:50%;width:60px;height:60px;display:flex;align-items:center;justify-content:center;font-size:1.5em;cursor:pointer;box-shadow:0 4px 12px rgba(0,102,204,0.3);transition:all 0.2s;z-index:999}
.search-trigger:hover{transform:scale(1.1);box-shadow:0 6px 20px rgba(0,102,204,0.4)}
kbd{background:#f0f0f0;border:1px solid #ccc;border-radius:3px;padding:2px 5px;font-family:monospace;font-size:0.9em;box-shadow:0 1px 2px rgba(0,0,0,0.1)}
@media (max-width: 600px){.global-search-container{margin:1em;max-height:90vh}.search-trigger{width:50px;height:50px;font-size:1.3em}}
EOF

# Enhanced post page CSS with 3D code block effects
cat > public/post.css << 'EOF'
body{max-width:55em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.6;color:#333;background:#f0ece8}
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

/* 3D code effect for inline code */
code{
  background:#e7e3de;
  color:#e53e3e;
  padding:.2em .4em;
  border-radius:3px;
  font-family:"SF Mono",Monaco,Consolas,"Liberation Mono","Courier New",monospace;
  font-size:.85em;
  border:1px solid #d4d0cb;
  box-shadow:0 1px 0 #fff,0 2px 4px rgba(0,0,0,0.08);
  text-shadow:0 1px 0 #fff,0 2px 4px rgba(0,0,0,0.1);
}

/* 3D code block styling */
pre{
  background:#e7e3de;
  padding:1em 1.2em;
  margin:2em 0;
  border-radius:10px;
  overflow-x:auto;
  border:1px solid #d4d0cb;
  box-shadow:0 2px 12px rgba(0,0,0,0.08),0 1px 0 #fff;
  position:relative;
}

pre::after{
  content:'';
  position:absolute;
  bottom:-1px;
  left:0;
  right:0;
  height:1px;
  background:linear-gradient(to right,transparent,#fff 20%,#fff 80%,transparent);
}

pre code{
  background:transparent;
  padding:0;
  font-size:.9em;
  color:#222;
  display:block;
  border:0;
  white-space:pre;
  box-shadow:none;
  font-family:'Fira Mono','Consolas',monospace;
  line-height:1.7;
}

/* 3D text effect for all code content */
pre code span,
pre code{
  text-shadow:
    0 2px 6px #fff,
    0 1px 0 #fff,
    0 4px 12px rgba(0,0,0,0.16),
    1px 2px 2px rgba(0,0,0,0.10),
    0 0.5px 0 #e5e5e5;
}

/* Remove 3D effect on selection/highlight for focus */
pre code::selection,
pre code span::selection,
pre code::-moz-selection,
pre code span::-moz-selection{
  text-shadow:none;
  background:#b3d4fc;
  color:#000;
}

/* Syntax highlighting colors with 3D effect */
.language-elixir .token.keyword,
.language-javascript .token.keyword,
.language-scheme .token.keyword,
.kw{color:#2b7bb9;font-weight:bold}
.language-elixir .token.function,
.language-javascript .token.function,
.fn{color:#d72660}
.language-elixir .token.string,
.language-javascript .token.string,
.language-scheme .token.string,
.str{color:#399f4a}
.language-elixir .token.comment,
.language-javascript .token.comment,
.language-scheme .token.comment,
.com{color:#8d99ae;font-style:italic}
.language-elixir .token.variable,
.language-javascript .token.variable,
.var{color:#222}
.language-elixir .token.number,
.language-javascript .token.number,
.num{color:#b48ead}

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
.copy-btn{position:absolute;top:.8em;right:.8em;background:#0066cc;color:#fff;border:0;border-radius:4px;padding:.4em .8em;font-size:.8em;cursor:pointer;opacity:.8;transition:all 0.2s;z-index:10}
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
search_paths=("content" "posts" "articles" "_posts" ".")

for location in "${search_paths[@]}"; do
    if [ -d "$location" ]; then
        echo "  🔍 Searching in: $location/"
        while IFS= read -r -d '' file; do
            if [ -f "$file" ] && [ -s "$file" ]; then
                files+=("$file")
                echo "    ✓ Found: $file"
            fi
        done < <(find "$location" -maxdepth 3 -name "*.md" -type f -print0 2>/dev/null)
    else
        echo "  ⚠️ Directory not found: $location/"
    fi
done

# Remove duplicates and sort
if [ ${#files[@]} -gt 0 ]; then
    readarray -t files < <(printf '%s\n' "${files[@]}" | sort -u)
    echo "📋 After deduplication: ${#files[@]} unique files"
else
    # Also try a simple find in current directory as fallback
    echo "  🔍 Fallback: searching current directory for any .md files..."
    while IFS= read -r -d '' file; do
        if [ -f "$file" ] && [ -s "$file" ]; then
            files+=("$file")
            echo "    ✓ Found: $file"
        fi
    done < <(find . -name "*.md" -type f -print0 2>/dev/null)
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
    echo "  ✓ Sort date: $sort_date"
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
    <link rel="stylesheet" href="../shared.css">
    <script src="../search-index.js" defer></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mermaid/10.6.1/mermaid.min.js"></script>
</head>
<body>
    <nav>
        <a href="../">← Blog Home</a>
        <a href="../archive/">Archive</a>
        <span style="float:right">Press <kbd>Ctrl+K</kbd> to search</span>
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

# Get all posts sorted by date (newest first) - MOVED HERE FROM LATER
echo "📊 Sorting posts by date..."
all_nums=()
for ((i=1; i<=processed_count; i++)); do
    sort_date="${post_data["$i,sort_date"]}"
    if [ -n "$sort_date" ]; then
        all_nums+=("$sort_date $i")
    else
        echo "  ⚠️ Warning: No sort date for post $i"
        all_nums+=("99999999 $i")  # Put at end if no date
    fi
done

# Sort by date (newest first) and extract post numbers
sorted_nums=($(printf '%s\n' "${all_nums[@]}" | sort -rn | cut -d' ' -f2))

echo "📋 Posts sorted in order: ${sorted_nums[*]:0:10}..." # Show first 10

# Generate search index for global search
echo "🔍 Generating search index..."
cat > public/search-index.js << 'SEARCH_INDEX_START'
window.searchIndex = [
SEARCH_INDEX_START

# Add all posts to search index
search_index_count=0
for num in "${sorted_nums[@]}"; do
    title="${post_data["$num,title"]}"
    date="${post_data["$num,date"]}"
    excerpt="${post_data["$num,excerpt"]}"
    slug="${post_data["$num,slug"]}"
    
    if [ -z "$title" ]; then
        echo "  ⚠️ Skipping post $num in search index - no title"
        continue
    fi
    
    # Escape for JavaScript - ensure no line breaks
    title_js=$(echo "$title" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed "s/'/\\\\'/g" | tr -d '\n\r')
    excerpt_js=$(echo "$excerpt" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed "s/'/\\\\'/g" | tr -d '\n\r')
    date_js=$(echo "$date" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr -d '\n\r')
    
    cat >> public/search-index.js << SEARCH_ENTRY
{
    id: ${num},
    title: "${title_js}",
    excerpt: "${excerpt_js}",
    date: "${date_js}",
    url: "p/${num}.html"
},
SEARCH_ENTRY
    
    search_index_count=$((search_index_count + 1))
done

echo "  ✅ Added $search_index_count posts to search index"

# Close search index
cat >> public/search-index.js << 'SEARCH_INDEX_END'
];

// Global search functionality
(function() {
    let searchOverlay = null;
    let searchInput = null;
    let searchResults = null;
    let searchStatus = null;
    
    function escapeRegExp(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\    function escapeRegExp(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\echo "📄 Successfully processed $processed_count out of $total files"

# Generate main page
echo "🏠 Generating main page..."');
    }');
    }
    
    function highlightText(text, query) {
        if (!query || query.length === 0) return text;
        
        // Escape the query for regex
        const escapedQuery = escapeRegExp(query);
        
        // Create a case-insensitive regex for the exact query
        const regex = new RegExp('(' + escapedQuery + ')', 'gi');
        
        // Replace matches with highlighted version
        return text.replace(regex, '<span class="search-highlight">$1</span>');
    }
    
    function performGlobalSearch(query) {
        if (!query || query.trim().length === 0) {
            searchResults.innerHTML = '';
            searchStatus.textContent = 'Type to search across all ' + window.searchIndex.length + ' posts...';
            return;
        }
        
        const queryLower = query.toLowerCase().trim();
        
        // Search through all posts character by character
        const matches = window.searchIndex.filter(post => {
            const titleLower = post.title.toLowerCase();
            const excerptLower = post.excerpt.toLowerCase();
            const dateLower = post.date.toLowerCase();
            
            // Check if query appears in any field
            return titleLower.includes(queryLower) || 
                   excerptLower.includes(queryLower) || 
                   dateLower.includes(queryLower);
        });
        
        if (matches.length === 0) {
            searchResults.innerHTML = '';
            searchStatus.innerHTML = '<div class="no-results">No posts found matching "<span class="search-term">' + escapeHtml(query) + '</span>"</div>';
            return;
        }
        
        // Sort by relevance
        matches.sort((a, b) => {
            const aTitle = a.title.toLowerCase();
            const bTitle = b.title.toLowerCase();
            const aExcerpt = a.excerpt.toLowerCase();
            const bExcerpt = b.excerpt.toLowerCase();
            
            // Title matches are most important
            const aTitleIndex = aTitle.indexOf(queryLower);
            const bTitleIndex = bTitle.indexOf(queryLower);
            
            if (aTitleIndex !== -1 && bTitleIndex === -1) return -1;
            if (aTitleIndex === -1 && bTitleIndex !== -1) return 1;
            
            // If both have title matches, prefer matches at the beginning
            if (aTitleIndex !== -1 && bTitleIndex !== -1) {
                if (aTitleIndex !== bTitleIndex) return aTitleIndex - bTitleIndex;
            }
            
            // Then check excerpt matches
            const aExcerptIndex = aExcerpt.indexOf(queryLower);
            const bExcerptIndex = bExcerpt.indexOf(queryLower);
            
            if (aExcerptIndex !== -1 && bExcerptIndex === -1) return -1;
            if (aExcerptIndex === -1 && bExcerptIndex !== -1) return 1;
            
            // Finally, sort by date (newest first)
            return b.id - a.id;
        });
        
        // Display results
        searchStatus.innerHTML = 'Found <span class="search-count">' + matches.length + '</span> posts matching "<span class="search-term">' + escapeHtml(query) + '</span>"';
        
        searchResults.innerHTML = matches.map(post => {
            const highlightedTitle = highlightText(escapeHtml(post.title), query);
            const highlightedExcerpt = highlightText(escapeHtml(post.excerpt), query);
            const highlightedDate = highlightText(escapeHtml(post.date), query);
            
            return '<div class="search-result-item" onclick="window.location.href=\'' + getRelativePath() + post.url + '\'">' +
                '<div class="search-result-date">' + highlightedDate + '</div>' +
                '<div class="search-result-title"><a href="' + getRelativePath() + post.url + '">' + highlightedTitle + '</a></div>' +
                '<div class="search-result-excerpt">' + highlightedExcerpt + '</div>' +
                '</div>';
        }).join('');
    }
    
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    function getRelativePath() {
        // Determine relative path based on current location
        if (window.location.pathname.includes('/p/')) {
            return '../';
        } else if (window.location.pathname.includes('/archive/')) {
            return '../';
        }
        return '';
    }
    
    function createSearchOverlay() {
        // Create overlay HTML
        const overlay = document.createElement('div');
        overlay.className = 'global-search';
        overlay.innerHTML = 
            '<div class="global-search-container">' +
                '<div class="global-search-header">' +
                    '<h2>Search All Posts</h2>' +
                    '<button class="global-search-close">×</button>' +
                    '<input type="text" class="global-search-input" placeholder="Search titles, content, and dates..." autofocus>' +
                '</div>' +
                '<div class="global-search-status">Type to search across all ' + window.searchIndex.length + ' posts...</div>' +
                '<div class="global-search-results"></div>' +
            '</div>';
        
        document.body.appendChild(overlay);
        
        searchOverlay = overlay;
        searchInput = overlay.querySelector('.global-search-input');
        searchResults = overlay.querySelector('.global-search-results');
        searchStatus = overlay.querySelector('.global-search-status');
        
        // Event listeners
        overlay.querySelector('.global-search-close').addEventListener('click', closeSearch);
        
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) {
                closeSearch();
            }
        });
        
        // Character-by-character search
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            const query = this.value;
            
            if (query.length === 0) {
                performGlobalSearch('');
                return;
            }
            
            // Small delay for performance
            searchTimeout = setTimeout(() => performGlobalSearch(query), 50);
        });
        
        // Handle escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && searchOverlay.classList.contains('active')) {
                closeSearch();
            }
        });
    }
    
    function openSearch() {
        if (!searchOverlay) {
            createSearchOverlay();
        }
        searchOverlay.classList.add('active');
        searchInput.focus();
        searchInput.value = '';
        performGlobalSearch('');
    }
    
    function closeSearch() {
        if (searchOverlay) {
            searchOverlay.classList.remove('active');
        }
    }
    
    // Create search trigger button
    function createSearchTrigger() {
        const trigger = document.createElement('button');
        trigger.className = 'search-trigger';
        trigger.innerHTML = '🔍';
        trigger.title = 'Search all posts';
        trigger.addEventListener('click', openSearch);
        document.body.appendChild(trigger);
    }
    
    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', createSearchTrigger);
    } else {
        createSearchTrigger();
    }
    
    // Keyboard shortcut (Ctrl/Cmd + K)
    document.addEventListener('keydown', function(e) {
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            openSearch();
        }
    });
    
    // Expose globally for programmatic access
    window.globalSearch = {
        open: openSearch,
        close: closeSearch
    };
})();
SEARCH_INDEX_END

echo "✅ Search index generated with $search_index_count posts"

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
    <script src="search-index.js" defer></script>
</head>
<body>
    <header>
        <h1>${SITE_TITLE}</h1>
        <div class="stats">📊 ${processed_count} posts published | Press <kbd>Ctrl+K</kbd> to search</div>
    </header>
    
    <main>
        <input id="search" placeholder="🔍 Search posts by title or content..." autocomplete="off">
        <div id="search-info" class="search-results" style="display:none">
            Found <span id="search-count">0</span> posts matching "<span id="search-term"></span>"
        </div>
        
        <div id="posts">
MAIN_META

# Show recent posts on main page (latest 15)
recent_count=0
max_recent=15

echo "🏠 Adding posts to main page..."
for num in "${sorted_nums[@]}"; do
    if [ $recent_count -ge $max_recent ]; then
        break
    fi
    
    title="${post_data["$num,title"]}"
    date="${post_data["$num,date"]}"
    excerpt="${post_data["$num,excerpt"]}"
    
    if [ -z "$title" ]; then
        echo "  ⚠️ Skipping post $num - no title found"
        continue
    fi
    
    echo "  ✓ Adding post $num: $title"
    
    # Prepare data for search and display (properly escaped)
    title_lower=$(echo "${title}" | tr '[:upper:]' '[:lower:]' | html_escape)
    excerpt_lower=$(echo "${excerpt}" | tr '[:upper:]' '[:lower:]' | html_escape)
    date_lower=$(echo "${date}" | tr '[:upper:]' '[:lower:]')
    searchable_lower=$(echo "${title} ${excerpt} ${date}" | tr '[:upper:]' '[:lower:]' | html_escape)
    title_display=$(html_escape "$title")
    excerpt_display=$(html_escape "$excerpt")
    
    cat >> public/index.html << POST_ENTRY_END
            <div class="post" data-title="${title_lower}" data-excerpt="${excerpt_lower}" data-date="${date_lower}" data-searchable="${searchable_lower}" onclick="window.location.href='p/${num}.html'">
                <div class="post-date">${date}</div>
                <div class="post-title">
                    <a href="p/${num}.html">${title_display}</a>
                </div>
                <div class="excerpt">${excerpt_display}</div>
            </div>
POST_ENTRY_END
    
    recent_count=$((recent_count + 1))
done

echo "📄 Added $recent_count posts to main page"

# If no posts were added, add a placeholder
if [ $recent_count -eq 0 ]; then
    echo "⚠️ No posts found to display on main page"
    cat >> public/index.html << 'NO_POSTS'
            <div class="no-results">
                <h3>Welcome to the Blog!</h3>
                <p>No posts have been published yet. Check back soon for new content!</p>
            </div>
NO_POSTS
fi

# Close the posts div and add navigation
cat >> public/index.html << 'MAIN_FOOTER'
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
            const searchTerm = document.getElementById('search-term');
            
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
                    searchInput.classList.remove('searching');
                    return;
                }
                
                searchInput.classList.add('searching');
                
                const tempDiv = document.createElement('div');
                tempDiv.innerHTML = originalPosts;
                const posts = Array.from(tempDiv.children);
                
                console.log('Searching for:', query, 'in', posts.length, 'posts');
                
                const filtered = posts.filter(post => {
                    const searchable = post.dataset.searchable || '';
                    const titleData = post.dataset.title || '';
                    const excerptData = post.dataset.excerpt || '';
                    const dateData = post.dataset.date || '';
                    
                    // Search in all fields
                    return searchable.includes(query) || 
                           titleData.includes(query) || 
                           excerptData.includes(query) ||
                           dateData.includes(query);
                });
                
                console.log('Found', filtered.length, 'matches');
                
                if (filtered.length > 0) {
                    // Create highlighted posts
                    const highlightedPosts = filtered.map(post => {
                        const postClone = post.cloneNode(true);
                        
                        // Highlight in title
                        const titleEl = postClone.querySelector('.post-title a');
                        if (titleEl) {
                            titleEl.innerHTML = highlightText(titleEl.textContent, query);
                        }
                        
                        // Highlight in excerpt
                        const excerptEl = postClone.querySelector('.excerpt');
                        if (excerptEl) {
                            excerptEl.innerHTML = highlightText(excerptEl.textContent, query);
                        }
                        
                        // Highlight in date
                        const dateEl = postClone.querySelector('.post-date');
                        if (dateEl) {
                            dateEl.innerHTML = highlightText(dateEl.textContent, query);
                        }
                        
                        return postClone.outerHTML;
                    }).join('');
                    
                    postsContainer.innerHTML = highlightedPosts;
                } else {
                    postsContainer.innerHTML = '<div class="no-results">No posts found matching your search. Try different keywords.</div>';
                }
                
                searchCount.textContent = filtered.length;
                searchTerm.textContent = query;
                searchInfo.style.display = 'block';
            }
            
            let searchTimeout;
            searchInput.addEventListener('input', function() {
                clearTimeout(searchTimeout);
                if (!searchInput.value.trim()) {
                    searchPosts();
                    return;
                }
                searchTimeout = setTimeout(searchPosts, 50);
            });
            
            console.log('Main page search initialized');
        })();
    </script>
</body>
</html>
MAIN_FOOTER

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
    <script src="../search-index.js" defer></script>
</head>
<body>
    <nav><a href="../">← Home</a> | Press <kbd>Ctrl+K</kbd> for global search</nav>
    
    <header>
        <h1>Post Archive</h1>
        <div class="stats">📊 All ${processed_count} posts in chronological order</div>
    </header>
    
    <main>
        <input id="search-main" placeholder="🔍 Search all posts..." autocomplete="off">
        <div id="search-info" class="search-results" style="display:none">
            Found <span id="search-count">0</span> of ${processed_count} posts matching "<span id="search-term"></span>"
        </div>
        
        <div id="sticky-header" class="sticky-header">
            <h2 id="sticky-title">Archive</h2>
            <input id="search-sticky" placeholder="🔍 Search all posts..." autocomplete="off">
        </div>
        
        <div class="archive-content" id="archive">
ARCHIVE_META

# Group posts by year and month
declare -A year_months
for num in "${sorted_nums[@]}"; do
    year="${post_data["$num,year"]}"
    month="${post_data["$num,month"]}"
    if [ -n "$year" ] && [ -n "$month" ]; then
        ym="$year-$month"
        year_months["$ym"]+="$num "
    fi
done

echo "📅 Grouped posts by year/month: ${!year_months[*]}"

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
        date_lower=$(echo "${date}" | tr '[:upper:]' '[:lower:]')
        searchable_lower=$(echo "${title} ${excerpt} ${date}" | tr '[:upper:]' '[:lower:]' | html_escape)
        title_display=$(html_escape "$title")
        excerpt_display=$(html_escape "$excerpt")
        
        cat >> public/archive/index.html << ARCHIVE_POST
                <div class="post" data-title="${title_lower}" data-excerpt="${excerpt_lower}" data-date="${date_lower}" data-searchable="${searchable_lower}" onclick="window.location.href='../p/${num}.html'">
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

# Close the archive content and add complete working scripts
cat >> public/archive/index.html << 'ARCHIVE_END'
        </div>
    </main>
    
    <script>
        (function() {
            let originalArchive = null;
            let isSearchActive = false;
            
            const searchMainInput = document.getElementById('search-main');
            const searchStickyInput = document.getElementById('search-sticky');
            const archiveContainer = document.getElementById('archive');
            const searchInfo = document.getElementById('search-info');
            const searchCount = document.getElementById('search-count');
            const searchTerm = document.getElementById('search-term');
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
                const searchMainRect = searchMainInput.getBoundingClientRect();
                
                if (searchMainRect.bottom < 0) {
                    stickyHeader.style.display = 'block';
                    if (!isSearchActive) {
                        // Update title based on visible section
                        const sections = document.querySelectorAll('.year-section, .month-section');
                        let currentSection = null;
                        
                        for (let section of sections) {
                            const rect = section.getBoundingClientRect();
                            if (rect.top <= 150 && rect.bottom > 0) {
                                currentSection = section;
                                break;
                            }
                        }
                        
                        if (currentSection) {
                            if (currentSection.dataset.yearMonth) {
                                stickyTitle.textContent = currentSection.dataset.yearMonth;
                            } else if (currentSection.dataset.year) {
                                stickyTitle.textContent = currentSection.dataset.year;
                            }
                        }
                    }
                } else {
                    stickyHeader.style.display = 'none';
                }
            }
            
            function searchArchive() {
                const mainQuery = searchMainInput.value.toLowerCase().trim();
                const stickyQuery = searchStickyInput.value.toLowerCase().trim();
                const query = mainQuery || stickyQuery;
                
                // Sync both inputs
                if (document.activeElement === searchMainInput) {
                    searchStickyInput.value = searchMainInput.value;
                } else if (document.activeElement === searchStickyInput) {
                    searchMainInput.value = searchStickyInput.value;
                }
                
                // Store original content
                if (originalArchive === null) {
                    originalArchive = archiveContainer.innerHTML;
                }
                
                if (!query) {
                    archiveContainer.innerHTML = originalArchive;
                    searchInfo.style.display = 'none';
                    searchMainInput.classList.remove('searching');
                    searchStickyInput.classList.remove('searching');
                    isSearchActive = false;
                    updateStickyHeader();
                    return;
                }
                
                isSearchActive = true;
                searchMainInput.classList.add('searching');
                searchStickyInput.classList.add('searching');
                
                // Search through posts
                const tempDiv = document.createElement('div');
                tempDiv.innerHTML = originalArchive;
                const posts = Array.from(tempDiv.querySelectorAll('.post'));
                
                const filtered = posts.filter(post => {
                    const searchable = post.dataset.searchable || '';
                    const titleData = post.dataset.title || '';
                    const excerptData = post.dataset.excerpt || '';
                    const dateData = post.dataset.date || '';
                    
                    // Search in all fields
                    return searchable.includes(query) || 
                           titleData.includes(query) || 
                           excerptData.includes(query) ||
                           dateData.includes(query);
                });
                
                if (filtered.length > 0) {
                    // Create search results section
                    let html = '<div class="year-section"><div class="year-header"><h2>Search Results</h2></div><div class="month-section">';
                    
                    // Add highlighted posts
                    filtered.forEach(post => {
                        const postClone = post.cloneNode(true);
                        
                        // Highlight in title
                        const titleEl = postClone.querySelector('.post-title a');
                        if (titleEl) {
                            titleEl.innerHTML = highlightText(titleEl.textContent, query);
                        }
                        
                        // Highlight in excerpt
                        const excerptEl = postClone.querySelector('.excerpt');
                        if (excerptEl) {
                            excerptEl.innerHTML = highlightText(excerptEl.textContent, query);
                        }
                        
                        // Highlight in date
                        const dateEl = postClone.querySelector('.post-date');
                        if (dateEl) {
                            dateEl.innerHTML = highlightText(dateEl.textContent, query);
                        }
                        
                        html += postClone.outerHTML;
                    });
                    
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
                searchTerm.textContent = query;
                searchInfo.style.display = 'block';
            }
            
            // Event listeners
            let searchTimeout;
            function handleSearch() {
                clearTimeout(searchTimeout);
                if (!this.value.trim()) {
                    searchArchive();
                    return;
                }
                searchTimeout = setTimeout(searchArchive, 50);
            }
            
            searchMainInput.addEventListener('input', handleSearch);
            searchStickyInput.addEventListener('input', handleSearch);
            
            // Scroll event for sticky header
            let scrollTimeout = null;
            window.addEventListener('scroll', function() {
                if (!scrollTimeout) {
                    scrollTimeout = setTimeout(function() {
                        updateStickyHeader();
                        scrollTimeout = null;
                    }, 10);
                }
            });
            
            window.addEventListener('resize', updateStickyHeader);
            
            // Initialize
            updateStickyHeader();
            console.log('Archive search and sticky header initialized');
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
echo "  ✓ Generated individual post pages with 3D code block effects"
echo "  ✓ Created main page with recent posts and search"
echo "  ✓ Built comprehensive archive with chronological organization"
echo "  ✓ Character-by-character search with real-time highlighting"
echo "  ✓ Fixed sticky navigation on archive page"
echo "  ✓ Global search index with $search_index_count posts"
echo ""
echo "🚀 Features included:"
echo "  • 3D glassmorphic code blocks with smooth shadows"
echo "  • Subtle embossed text effect for code syntax"
echo "  • White bottom highlight line for glass effect"
echo "  • Text selection removes 3D effect for focus"
echo "  • Global character-by-character search (Ctrl+K)"
echo "  • Real-time search with yellow highlighting"
echo "  • Search across titles, excerpts, and dates"
echo "  • Floating search button on all pages"
echo "  • Relevance-based search results"
echo "  • Case-insensitive search across all posts"
echo "  • Visual search indicators and animations"
echo "  • Clean design with subtle border hover effects"  
echo "  • Code syntax highlighting with Prism.js"
echo "  • Mermaid diagram rendering"
echo "  • Copy-to-clipboard functionality"
echo "  • Working sticky archive navigation"
echo "  • SEO-optimized meta tags"
echo "  • Reading time calculations"
echo "  • Chronological post organization"
echo ""
echo "📁 Output structure:"
echo "  public/"
echo "  ├── index.html (main page with recent posts)"
echo "  ├── shared.css (shared styles)"
echo "  ├── post.css (post-specific styles with 3D effects)"
echo "  ├── search-index.js (global search index with $search_index_count posts)"
echo "  ├── archive/"
echo "  │   └── index.html (complete archive)"
echo "  └── p/"
echo "      ├── 1.html"
echo "      ├── 2.html"
echo "      └── ... (individual post pages)"
echo ""
echo "🎨 3D Code Block Effects:"
echo "   - Beige tinted background (#e7e3de)"
echo "   - Multi-layered text shadows for depth"
echo "   - Glass-like bottom highlight"
echo "   - Selection removes 3D effect for readability"
echo "   - Smooth visual hierarchy with shadows"
