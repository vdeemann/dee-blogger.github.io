#!/bin/bash
set -e

echo "🔧 Building elegant, consistent blog with Mermaid support..."

rm -rf public
mkdir -p public/p public/archive

SITE_TITLE="${SITE_TITLE:-My Blog}"

# Compact CSS for main page + Timeline CSS for archive
COMPACT_CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;line-height:1.4;color:#333;-webkit-font-smoothing:antialiased}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.8em;margin:0 0 .5em 0;color:#222;font-weight:600}h2{font-size:1.1em;margin:0;color:#333;font-weight:600}p{margin:.2em 0;color:#333}small{color:#666;display:block;margin:0;font-size:.85em}.post{margin-bottom:.6em;padding:.4em .6em;background:#fafafa;border-radius:3px;border:1px solid #e8e8e8}input{width:100%;margin-bottom:.5em;padding:.4em;border:1px solid #ddd;border-radius:3px;font-size:.9em}nav{margin:.8em 0;padding:.3em 0}.stats{background:#fff3cd;padding:.5em;border-radius:3px;margin:.5em 0;text-align:center;font-size:.9em}'

# Timeline CSS for archive page
TIMELINE_CSS='body{max-width:45em;margin:2em auto;padding:0 1em;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;line-height:1.5;color:#333;-webkit-font-smoothing:antialiased}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.8em;margin:0 0 .5em 0;color:#222;font-weight:600}h2{font-size:1.1em;margin:0;color:#333;font-weight:600}p{margin:.3em 0;color:#333}small{color:#666;display:block;margin:0;font-size:.85em}input{width:100%;margin-bottom:1em;padding:.4em;border:1px solid #ddd;border-radius:3px;font-size:.9em}nav{margin:.8em 0;padding:.3em 0}.stats{background:#fff3cd;padding:.5em;border-radius:3px;margin:.5em 0;text-align:center;font-size:.9em}.timeline{position:relative;margin:2em 0;padding-left:2em}.timeline:before{content:"";position:absolute;left:15px;top:0;bottom:0;width:2px;background:linear-gradient(to bottom,#0066cc,#e1e8ed)}.year-section{margin-bottom:3em}.year-header{position:relative;margin-bottom:1.5em}.year-header h2{background:#0066cc;color:white;padding:.5em 1em;border-radius:20px;display:inline-block;font-size:1.2em;margin:0;position:relative;z-index:2}.year-header:before{content:"";position:absolute;left:-10px;top:50%;transform:translateY(-50%);width:20px;height:20px;background:#0066cc;border-radius:50%;border:3px solid white;box-shadow:0 0 0 2px #0066cc}.month-section{margin-bottom:2em;position:relative}.month-header{position:relative;margin-bottom:1em;padding-left:1em}.month-header h3{background:#f8f9fa;color:#333;padding:.3em .8em;border-radius:15px;display:inline-block;font-size:1em;margin:0;border:1px solid #e1e8ed;position:relative;z-index:2}.month-header:before{content:"";position:absolute;left:-6px;top:50%;transform:translateY(-50%);width:12px;height:12px;background:white;border:2px solid #0066cc;border-radius:50%}.post-item{position:relative;margin-bottom:.8em;padding:.6em .8em;background:white;border-radius:6px;border:1px solid #e1e8ed;margin-left:1em;transition:all 0.2s ease}.post-item:hover{background:#f8f9fa;border-color:#0066cc;transform:translateX(2px);box-shadow:0 2px 4px rgba(0,102,204,0.1)}.post-item:before{content:"";position:absolute;left:-7px;top:50%;transform:translateY(-50%);width:6px;height:6px;background:#0066cc;border-radius:50%}.search-active .timeline:before{background:#ddd}.search-active .year-header:before,.search-active .month-header:before,.search-active .post-item:before{background:#ddd;border-color:#ddd}.search-active .year-header h2{background:#666}'

# Enhanced CSS for individual blog posts with Mermaid support (Chart.js CSS removed)
POST_CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;line-height:1.6;color:#333;-webkit-font-smoothing:antialiased}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.8em;margin:0 0 .3em 0;color:#222;font-weight:600}h2{font-size:1.3em;margin:2em 0 1em;color:#333;font-weight:600}h3{font-size:1.1em;margin:1.5em 0 .5em;color:#444;font-weight:600}p{margin:1em 0;color:#333}small{color:#666;display:block;margin-bottom:1.5em;font-size:.9em}strong{font-weight:600}code{background:#f6f8fa;color:#24292e;padding:.1em .3em;border-radius:3px;font-family:"SF Mono",Monaco,monospace;font-size:.85em}.code-container{position:relative;margin:.8em 0}.copy-btn{position:absolute;top:4px;right:4px;background:#fff;border:1px solid #d1d9e0;border-radius:3px;padding:4px 8px;font-size:11px;color:#586069;cursor:pointer;font-family:system-ui;z-index:10;box-shadow:0 1px 2px rgba(0,0,0,0.1)}.copy-btn:hover{background:#f6f8fa;color:#0366d6;border-color:#0366d6}.copy-btn:active{background:#e1e8ed;transform:scale(0.95)}.copy-success{color:#fff!important;background:#28a745!important;border-color:#28a745!important}pre{background:#f6f8fa;padding:.3em .5em;margin:0;border-radius:4px;overflow-x:auto;line-height:1.1;border:1px solid #e1e4e8}pre code{background:none;padding:0;font-size:.75em;color:#24292e;font-family:"SF Mono",Monaco,monospace;line-height:1.1;display:block;white-space:pre}ul{margin:1em 0;padding-left:1.5em}li{margin:.5em 0;color:#333}nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #eee}blockquote{background:#f6f8fa;border-left:4px solid #0366d6;margin:1.5em 0;padding:1em 1.5em;border-radius:0 6px 6px 0;color:#586069;font-style:italic}.mermaid{margin:1.5em 0;text-align:center;background:#fff;border:1px solid #e1e4e8;border-radius:6px;padding:1em}.mermaid-container{position:relative;margin:1.5em 0}.mermaid-title{background:#f6f8fa;color:#333;padding:.5em 1em;border:1px solid #e1e4e8;border-bottom:none;border-radius:6px 6px 0 0;font-size:.9em;font-weight:600;margin:0}'

files=($(ls content/*.md 2>/dev/null | sort))
total=${#files[@]}

echo "📁 Processing $total files with Mermaid support..."

# Enhanced markdown processing function with Mermaid support
process_markdown() {
    local file="$1"
    tail -n +3 "$file" | sed '
        # Handle Mermaid diagrams first
        /^```mermaid/,/^```$/ {
            /^```mermaid.*/ {
                s/.*/MERMAID_START/
                b
            }
            /^```$/ {
                s/.*/MERMAID_END/
                b
            }
            s/^/MERMAID_LINE:/
            b
        }
        
        # Handle regular code blocks
        /^```/,/^```/ {
            /^```$/ {
                s/.*/CODEBLOCK_END/
                b
            }
            /^```.*/ {
                s/.*/CODEBLOCK_START/
                b
            }
            s/&/\&amp;/g
            s/</\&lt;/g
            s/>/\&gt;/g
            s/^/CODE_LINE:/
            b
        }
        
        # Handle headers
        s/^### \(.*\)/<h3>\1<\/h3>/
        s/^## \(.*\)/<h2>\1<\/h2>/
        s/^# \(.*\)/<h1>\1<\/h1>/
        
        # Handle lists
        s/^[•*-] \(.*\)/<li>\1<\/li>/
        
        # Handle bold and inline code
        s/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g
        s/`\([^`]*\)`/<code>\1<\/code>/g
        
        # Handle links
        s/\[\([^]]*\)\](\([^)]*\))/<a href="\2">\1<\/a>/g
        
        # Handle empty lines
        /^$/ s/^$/<\/p><p>/
        
        # Wrap regular text in paragraphs
        /^[^<]/ s/^/<p>/
        /^<p>/ s/$/<\/p>/
    ' | awk '
    BEGIN { 
        in_code = 0
        in_mermaid = 0
        in_list = 0
        code_content = ""
        mermaid_content = ""
        mermaid_title = ""
    }
    
    /MERMAID_START/ {
        if (in_list) { print "</ul>"; in_list = 0 }
        in_mermaid = 1
        mermaid_content = ""
        # Extract title from mermaid line if present
        if (match($0, /```mermaid (.+)$/)) {
            mermaid_title = substr($0, RSTART + 11, RLENGTH - 11)
        } else {
            mermaid_title = ""
        }
        next
    }
    
    /MERMAID_END/ {
        if (in_mermaid) {
            if (mermaid_title != "") {
                print "<div class=\"mermaid-container\">"
                print "<div class=\"mermaid-title\">" mermaid_title "</div>"
                print "<div class=\"mermaid\">" mermaid_content "</div>"
                print "</div>"
            } else {
                print "<div class=\"mermaid\">" mermaid_content "</div>"
            }
            in_mermaid = 0
            mermaid_content = ""
            mermaid_title = ""
        }
        next
    }
    
    /^MERMAID_LINE:/ {
        gsub(/^MERMAID_LINE:/, "")
        if (mermaid_content != "") mermaid_content = mermaid_content "\n"
        mermaid_content = mermaid_content $0
        next
    }
    
    /CODEBLOCK_START/ {
        if (in_list) { print "</ul>"; in_list = 0 }
        in_code = 1
        code_content = ""
        next
    }
    
    /CODEBLOCK_END/ {
        if (in_code) {
            print "<div class=\"code-container\">"
            print "<button class=\"copy-btn\" onclick=\"copyCode(this)\">📋 Copy</button>"
            print "<pre><code>" code_content "</code></pre>"
            print "</div>"
            in_code = 0
            code_content = ""
        }
        next
    }
    
    /^CODE_LINE:/ {
        gsub(/^CODE_LINE:/, "")
        if (code_content != "") code_content = code_content "\n"
        code_content = code_content $0
        next
    }
    
    /^<li>/ {
        if (!in_list) { print "<ul>"; in_list = 1 }
        print
        next
    }
    
    /^<h[123]>/ {
        if (in_list) { print "</ul>"; in_list = 0 }
        print
        next
    }
    
    /^<\/p><p>$/ {
        if (in_list) { print "</ul>"; in_list = 0 }
        print
        next
    }
    
    {
        if (in_list && !/^<li>/) { print "</ul>"; in_list = 0 }
        if (!in_mermaid && !in_code) print
    }
    
    END {
        if (in_code) {
            print "<div class=\"code-container\">"
            print "<button class=\"copy-btn\" onclick=\"copyCode(this)\">📋 Copy</button>"
            print "<pre><code>" code_content "</code></pre>"
            print "</div>"
        }
        if (in_mermaid) {
            if (mermaid_title != "") {
                print "<div class=\"mermaid-container\">"
                print "<div class=\"mermaid-title\">" mermaid_title "</div>"
                print "<div class=\"mermaid\">" mermaid_content "</div>"
                print "</div>"
            } else {
                print "<div class=\"mermaid\">" mermaid_content "</div>"
            }
        }
        if (in_list) print "</ul>"
    }
    ' | sed '
        # Clean up paragraph tags
        s/<\/p><p>/<\/p>\n<p>/g
        s/^<\/p>//
        s/<p>$//'
}

# Generate individual posts with Mermaid support
for i in "${!files[@]}"; do
    file="${files[$i]}"
    num=$((i + 1))
    
    # Extract title safely
    title=$(head -1 "$file" | sed 's/^# *//' | sed 's/[<>&"'"'"']//g')
    
    # Process content with enhanced markdown including Mermaid
    content=$(process_markdown "$file")
    
    # Extract date from filename
    date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
    
    # Generate individual post layout with Mermaid support (Chart.js removed)
    cat > "public/p/$num.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>$title</title>
<style>$POST_CSS</style>
<script src="https://cdnjs.cloudflare.com/ajax/libs/mermaid/10.6.1/mermaid.min.js"></script>
</head>
<body>
<nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav>
<h1>$title</h1>
<small>$date</small>
$content
<nav style="border-top:1px solid #eee;margin-top:2em;padding-top:1em"><a href="../">← Back to Blog</a></nav>
<script>
// Initialize Mermaid with custom configuration
mermaid.initialize({
    startOnLoad: true,
    theme: 'default',
    themeVariables: {
        primaryColor: '#0066cc',
        primaryTextColor: '#333',
        primaryBorderColor: '#e1e4e8',
        lineColor: '#666',
        secondaryColor: '#f6f8fa',
        tertiaryColor: '#fff'
    },
    flowchart: {
        htmlLabels: true,
        curve: 'linear'
    },
    sequence: {
        actorMargin: 50,
        width: 150,
        height: 65,
        boxMargin: 10,
        boxTextMargin: 5,
        noteMargin: 10,
        messageMargin: 35
    },
    gantt: {
        titleTopMargin: 25,
        barHeight: 20,
        fontSize: 11,
        fontFamily: '-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif'
    }
});

// Copy code functionality
function copyCode(btn) {
    const pre = btn.nextElementSibling;
    const code = pre.querySelector('code');
    const text = code.textContent;
    
    navigator.clipboard.writeText(text).then(() => {
        const original = btn.textContent;
        btn.textContent = '✓ Copied!';
        btn.classList.add('copy-success');
        setTimeout(() => {
            btn.textContent = original;
            btn.classList.remove('copy-success');
        }, 2000);
    }).catch(() => {
        // Fallback for older browsers
        const textArea = document.createElement('textarea');
        textArea.value = text;
        textArea.style.position = 'absolute';
        textArea.style.left = '-9999px';
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        
        const original = btn.textContent;
        btn.textContent = '✓ Copied!';
        btn.classList.add('copy-success');
        setTimeout(() => {
            btn.textContent = original;
            btn.classList.remove('copy-success');
        }, 2000);
    });
}

// Auto-resize Mermaid diagrams for mobile
function resizeMermaidDiagrams() {
    const mermaidDivs = document.querySelectorAll('.mermaid');
    mermaidDivs.forEach(div => {
        const svg = div.querySelector('svg');
        if (svg) {
            svg.style.maxWidth = '100%';
            svg.style.height = 'auto';
        }
    });
}

// Run resize on load and window resize
window.addEventListener('load', resizeMermaidDiagrams);
window.addEventListener('resize', resizeMermaidDiagrams);
</script>
</body>
</html>
EOF
    
    echo "✅ Post $num: $title"
done

# Generate compact main page
{
    echo "<!DOCTYPE html><title>$SITE_TITLE</title><style>$COMPACT_CSS</style><h1>$SITE_TITLE</h1><input id=s placeholder=\"Search...\" onkeyup=f()><div id=p>"
    
    # Recent 20 posts with consistent formatting
    count=0
    ls content/*.md | sort -r | head -20 | while read file; do
        num=1
        for f in $(ls content/*.md | sort); do [ "$f" = "$file" ] && break; num=$((num+1)); done
        
        title=$(head -1 "$file" | sed 's/^# *//' | sed 's/[<>&"'"'"']//g')
        excerpt=$(sed -n '3p' "$file" | sed 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g; s/`\([^`]*\)`/<code>\1<\/code>/g; s/[<>&"'"'"']//g')
        [ -z "$excerpt" ] && excerpt="..."
        date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
        
        echo "<div class=post><small>$date</small><h2><a href=p/$num.html>$title</a></h2><p>$excerpt</p></div>"
    done
    
    echo "</div><p>📚 <a href=archive/>View all $total posts</a></p><script>let o,p=document.getElementById('p');function f(){let q=s.value.toLowerCase();if(!o)o=p.innerHTML;if(!q){p.innerHTML=o;return}let r=Array.from(p.children).filter(e=>e.textContent.toLowerCase().includes(q));p.innerHTML=r.length?r.map(e=>e.outerHTML).join(''):'<p>No posts found</p>'}</script>"
} > public/index.html

# Generate timeline archive
{
    echo "<!DOCTYPE html><title>Archive</title><style>$TIMELINE_CSS</style><a href=../>← Home</a><h1>Archive Timeline</h1><div class=stats>📊 Total: $total posts organized chronologically</div><input id=s placeholder=\"Search all posts...\" onkeyup=f()><div class=\"timeline\" id=timeline>"
    
    # Create associative arrays for grouping posts by year/month
    declare -A years
    declare -A months
    
    # First pass: collect all posts and organize by date
    while IFS= read -r file; do
        [ ! -f "$file" ] && continue
        
        filename=$(basename "$file")
        date_part=$(echo "$filename" | cut -d- -f1-3)
        year=$(echo "$date_part" | cut -d- -f1)
        month=$(echo "$date_part" | cut -d- -f2)
        
        # Convert month number to name
        case "$month" in
            01) month_name="January" ;;
            02) month_name="February" ;;
            03) month_name="March" ;;
            04) month_name="April" ;;
            05) month_name="May" ;;
            06) month_name="June" ;;
            07) month_name="July" ;;
            08) month_name="August" ;;
            09) month_name="September" ;;
            10) month_name="October" ;;
            11) month_name="November" ;;
            12) month_name="December" ;;
        esac
        
        years["$year"]=1
        months["$year-$month"]="$month_name"
        
    done < <(ls content/*.md | sort -r)
    
    # Generate timeline by year (newest first)
    for year in $(printf '%s\n' "${!years[@]}" | sort -nr); do
        echo "<div class=\"year-section\">"
        echo "<div class=\"year-header\"><h2>$year</h2></div>"
        
        # Generate months for this year (newest first)
        for month_key in $(printf '%s\n' "${!months[@]}" | grep "^$year-" | sort -nr); do
            month_num=$(echo "$month_key" | cut -d- -f2)
            month_name="${months[$month_key]}"
            
            echo "<div class=\"month-section\">"
            echo "<div class=\"month-header\"><h3>$month_name</h3></div>"
            
            # Generate posts for this year/month
            ls content/*.md | sort -r | while read file; do
                [ ! -f "$file" ] && continue
                
                filename=$(basename "$file")
                file_year=$(echo "$filename" | cut -d- -f1)
                file_month=$(echo "$filename" | cut -d- -f2)
                
                if [ "$file_year" = "$year" ] && [ "$file_month" = "$month_num" ]; then
                    # Find post number
                    num=1
                    for f in $(ls content/*.md | sort); do
                        if [ "$f" = "$file" ]; then
                            break
                        fi
                        num=$((num + 1))
                    done
                    
                    title=$(head -1 "$file" | sed 's/^# *//' | sed 's/[<>&"'"'"']//g')
                    excerpt=$(sed -n '3p' "$file" | sed 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g; s/`\([^`]*\)`/<code>\1<\/code>/g; s/[<>&"'"'"']//g')
                    [ -z "$excerpt" ] && excerpt="..."
                    date=$(echo "$filename" | cut -d- -f1-3 | sed 's/-/\//g')
                    
                    echo "<div class=\"post-item\">"
                    echo "<small>$date</small>"
                    echo "<h2><a href=\"../p/$num.html\">$title</a></h2>"
                    echo "<p>$excerpt</p>"
                    echo "</div>"
                fi
            done
            
            echo "</div>" # Close month-section
        done
        
        echo "</div>" # Close year-section
    done
    
    echo "</div>" # Close timeline
    
    # Enhanced search script for timeline
    cat << 'EOF'
<script>
let originalTimeline;
function f() {
    const query = document.getElementById('s').value.toLowerCase();
    const timeline = document.getElementById('timeline');
    const body = document.body;
    
    if (!originalTimeline) {
        originalTimeline = timeline.innerHTML;
    }
    
    if (!query) {
        timeline.innerHTML = originalTimeline;
        body.classList.remove('search-active');
        return;
    }
    
    body.classList.add('search-active');
    
    // Find all matching posts
    const yearSections = Array.from(timeline.children);
    let hasResults = false;
    let filteredHTML = '';
    
    yearSections.forEach(yearSection => {
        const yearHeader = yearSection.querySelector('.year-header h2').textContent;
        const monthSections = Array.from(yearSection.querySelectorAll('.month-section'));
        let yearHasResults = false;
        let yearHTML = '';
        
        monthSections.forEach(monthSection => {
            const monthHeader = monthSection.querySelector('.month-header h3').textContent;
            const posts = Array.from(monthSection.querySelectorAll('.post-item'));
            let monthHasResults = false;
            let monthHTML = '';
            
            posts.forEach(post => {
                if (post.textContent.toLowerCase().includes(query)) {
                    monthHTML += post.outerHTML;
                    monthHasResults = true;
                    hasResults = true;
                }
            });
            
            if (monthHasResults) {
                yearHTML += `<div class="month-section">
                    <div class="month-header"><h3>${monthHeader}</h3></div>
                    ${monthHTML}
                </div>`;
                yearHasResults = true;
            }
        });
        
        if (yearHasResults) {
            filteredHTML += `<div class="year-section">
                <div class="year-header"><h2>${yearHeader}</h2></div>
                ${yearHTML}
            </div>`;
        }
    });
    
    if (hasResults) {
        timeline.innerHTML = filteredHTML;
    } else {
        timeline.innerHTML = '<div class="post-item"><p>No posts found</p></div>';
    }
}
</script>
EOF
} > public/archive/index.html

echo "✅ Blog built with Mermaid.js support!"
echo "📊 $total posts generated"
echo "🎨 Main page: Compact post listings"
echo "📋 Individual posts: Copy-enabled code blocks + Mermaid diagrams"
echo "📈 Mermaid support: Flowcharts, sequence diagrams, Gantt charts, and more"
echo "🗓️ Archive: Beautiful vertical timeline organized by year/month"
echo "🚀 Blog is ready with Mermaid diagram support!"
