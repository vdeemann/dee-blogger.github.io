#!/bin/bash
set -e

echo "🔧 Building elegant, consistent blog..."

rm -rf public
mkdir -p public/p public/archive

SITE_TITLE="${SITE_TITLE:-My Blog}"

# Compact CSS for main/archive pages
COMPACT_CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;line-height:1.4;color:#333;-webkit-font-smoothing:antialiased}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.8em;margin:0 0 .5em 0;color:#222;font-weight:600}h2{font-size:1.1em;margin:0;color:#333;font-weight:600}p{margin:.2em 0;color:#333}small{color:#666;display:block;margin:0;font-size:.85em}.post{margin-bottom:.6em;padding:.4em .6em;background:#fafafa;border-radius:3px;border:1px solid #e8e8e8}input{width:100%;margin-bottom:.5em;padding:.4em;border:1px solid #ddd;border-radius:3px;font-size:.9em}nav{margin:.8em 0;padding:.3em 0}.stats{background:#fff3cd;padding:.5em;border-radius:3px;margin:.5em 0;text-align:center;font-size:.9em}'

# Elegant CSS for individual blog posts with enhanced code formatting
POST_CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;line-height:1.6;color:#333;-webkit-font-smoothing:antialiased}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.8em;margin:0 0 .3em 0;color:#222;font-weight:600}h2{font-size:1.3em;margin:2em 0 1em;color:#333;font-weight:600}h3{font-size:1.1em;margin:1.5em 0 .5em;color:#444;font-weight:600}p{margin:1em 0;color:#333}small{color:#666;display:block;margin-bottom:1.5em;font-size:.9em}strong{font-weight:600}code{background:linear-gradient(135deg,#f8f9fa 0%,#e9ecef 100%);color:#d73a49;padding:.3em .5em;border-radius:4px;font-family:"SF Mono",Monaco,"Cascadia Code","Roboto Mono",monospace;font-size:.88em;border:1px solid #e1e8ed;box-shadow:0 1px 2px rgba(0,0,0,0.1)}pre{background:linear-gradient(135deg,#f8f9fa 0%,#ffffff 100%);padding:1.2em;margin:1.8em 0;border-radius:8px;overflow-x:auto;line-height:1.5;border:1px solid #e1e8ed;box-shadow:0 2px 8px rgba(0,0,0,0.1);position:relative}pre:before{content:"";position:absolute;top:12px;left:12px;width:12px;height:12px;background:#ff5f56;border-radius:50%;box-shadow:20px 0 #ffbd2e,40px 0 #27ca3f}pre code{background:none;padding:0;font-size:.85em;color:#24292e;border:none;box-shadow:none;font-family:"SF Mono",Monaco,"Cascadia Code","Roboto Mono",monospace;display:block;margin-top:8px}ul{margin:1em 0;padding-left:1.5em}li{margin:.5em 0;color:#333}nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #eee}blockquote{background:#f8f9fa;border-left:4px solid #0066cc;margin:1.5em 0;padding:1em 1.5em;border-radius:0 6px 6px 0;color:#555;font-style:italic;box-shadow:0 1px 3px rgba(0,0,0,0.1)}'

files=($(ls content/*.md 2>/dev/null | sort))
total=${#files[@]}

echo "📁 Processing $total files with consistent styling..."

# Enhanced markdown processing function
process_markdown() {
    local file="$1"
    tail -n +3 "$file" | awk '
    BEGIN { in_code_block = 0; in_list = 0 }
    
    # Handle code blocks with language detection
    /^```/ {
        if (in_code_block) {
            print "</code></pre>"
            in_code_block = 0
        } else {
            lang = substr($0, 4)
            if (lang != "") {
                print "<pre data-lang=\"" lang "\"><code>"
            } else {
                print "<pre><code>"
            }
            in_code_block = 1
        }
        next
    }
    
    # If in code block, escape HTML and preserve formatting
    in_code_block {
        gsub(/&/, "\\&amp;")
        gsub(/</, "\\&lt;")
        gsub(/>/, "\\&gt;")
        gsub(/"/, "\\&quot;")
        print
        next
    }
    
    # Handle headers
    /^### / {
        gsub(/^### /, "")
        gsub(/[<>&"'"'"']/, "")
        if (in_list) { print "</ul>"; in_list = 0 }
        print "<h3>" $0 "</h3>"
        next
    }
    
    /^## / {
        gsub(/^## /, "")
        gsub(/[<>&"'"'"']/, "")
        if (in_list) { print "</ul>"; in_list = 0 }
        print "<h2>" $0 "</h2>"
        next
    }
    
    # Handle lists
    /^[•*-] / {
        gsub(/^[•*-] /, "")
        # Process inline formatting
        gsub(/\*\*([^*]+)\*\*/, "<strong>\\1</strong>")
        gsub(/`([^`]+)`/, "<code>\\1</code>")
        gsub(/[<>&"'"'"']/, "")
        if (!in_list) { print "<ul>"; in_list = 1 }
        print "<li>" $0 "</li>"
        next
    }
    
    # Empty lines
    /^$/ {
        if (in_list) { print "</ul>"; in_list = 0 }
        print "</p><p>"
        next
    }
    
    # Regular text with enhanced inline formatting
    {
        if (in_list) { print "</ul>"; in_list = 0 }
        # Process inline formatting with better code handling
        gsub(/\*\*([^*]+)\*\*/, "<strong>\\1</strong>")
        gsub(/`([^`]+)`/, "<code>\\1</code>")
        gsub(/\[([^\]]+)\]\(([^)]+)\)/, "<a href=\"\\2\">\\1</a>")
        # Escape remaining HTML chars
        gsub(/&/, "\\&amp;")
        gsub(/<([^\/])/, "\\&lt;\\1")
        gsub(/([^>])>/, "\\1\\&gt;")
        if (NF > 0) print "<p>" $0 "</p>"
    }
    
    END {
        if (in_list) print "</ul>"
        if (in_code_block) print "</code></pre>"
    }
    ' | sed '
        # Clean up paragraph tags
        s/<\/p><p>/<\/p>\n<p>/g
        s/^<\/p>//
        s/<p>$//'
}

# Generate individual posts with consistent styling
for i in "${!files[@]}"; do
    file="${files[$i]}"
    num=$((i + 1))
    
    # Extract title safely
    title=$(head -1 "$file" | sed 's/^# *//' | sed 's/[<>&"'"'"']//g')
    
    # Process content with enhanced markdown
    content=$(process_markdown "$file")
    
    # Extract date from filename
    date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
    
    # Generate elegant individual post layout
    cat > "public/p/$num.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>$title</title>
<style>$POST_CSS</style>
</head>
<body>
<nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav>
<h1>$title</h1>
<small>$date</small>
$content
<nav style="border-top:1px solid #eee;margin-top:2em;padding-top:1em"><a href="../">← Back to Blog</a></nav>
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

# Generate compact archive
{
    echo "<!DOCTYPE html><title>Archive</title><style>$COMPACT_CSS</style><a href=../>← Home</a><h1>Archive</h1><div class=stats>$total posts</div><input id=s placeholder=\"Search...\" onkeyup=f()><div id=p>"
    
    ls content/*.md | sort -r | while read file; do
        num=1
        for f in $(ls content/*.md | sort); do [ "$f" = "$file" ] && break; num=$((num+1)); done
        
        title=$(head -1 "$file" | sed 's/^# *//' | sed 's/[<>&"'"'"']//g')
        excerpt=$(sed -n '3p' "$file" | sed 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g; s/`\([^`]*\)`/<code>\1<\/code>/g; s/[<>&"'"'"']//g')
        [ -z "$excerpt" ] && excerpt="..."
        date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
        
        echo "<div class=post><small>$date</small><h2><a href=../p/$num.html>$title</a></h2><p>$excerpt</p></div>"
    done
    
    echo "</div><script>let o,p=document.getElementById('p');function f(){let q=s.value.toLowerCase();if(!o)o=p.innerHTML;if(!q){p.innerHTML=o;return}let r=Array.from(p.children).filter(e=>e.textContent.toLowerCase().includes(q));p.innerHTML=r.length?r.map(e=>e.outerHTML).join(''):'<p>No posts found</p>'}</script>"
} > public/archive/index.html

echo "✅ Elegant blog built with enhanced code formatting!"
echo "📊 $total posts generated"
echo "🎨 All posts have uniform styling with elegant code blocks"
echo "💻 Code sections feature gradients, syntax colors, and terminal-style decorations"
echo "🚀 Blog is ready!"
