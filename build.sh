#!/bin/bash
set -e

echo "🔧 Building elegant, consistent blog..."

rm -rf public
mkdir -p public/p public/archive

SITE_TITLE="${SITE_TITLE:-My Blog}"

# Elegant, consistent styling CSS
CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;line-height:1.6;color:#333;-webkit-font-smoothing:antialiased}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.8em;margin:0 0 .3em 0;color:#222;font-weight:600}h2{font-size:1.3em;margin:2em 0 1em;color:#333;font-weight:600}h3{font-size:1.1em;margin:1.5em 0 .5em;color:#444;font-weight:600}p{margin:1em 0;color:#333}small{color:#666;display:block;margin-bottom:1.5em;font-size:.9em}strong{font-weight:600}code{background:#f1f3f4;padding:.2em .4em;border-radius:3px;font-family:"SF Mono",Monaco,monospace;font-size:.9em}pre{background:#f8f9fa;padding:1em;margin:1.5em 0;border-radius:6px;overflow-x:auto;line-height:1.4;border:1px solid #e1e8ed}pre code{background:none;padding:0;font-size:.85em}ul{margin:1em 0;padding-left:1.5em}li{margin:.5em 0;color:#333}blockquote{margin:1.5em 0;padding-left:1em;border-left:4px solid #ddd;color:#666;font-style:italic}.post{margin-bottom:2em;padding:1em;background:#fafafa;border-radius:4px}input{width:100%;margin-bottom:1em;padding:.5em;border:1px solid #ddd;border-radius:4px}nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #eee}.stats{background:#fff3cd;padding:1em;border-radius:4px;margin:1em 0;text-align:center}'

files=($(ls content/*.md 2>/dev/null | sort))
total=${#files[@]}

echo "📁 Processing $total files with consistent styling..."

# Enhanced markdown processing function
process_markdown() {
    local file="$1"
    tail -n +3 "$file" | awk '
    BEGIN { in_code_block = 0; in_list = 0 }
    
    # Handle code blocks
    /^```/ {
        if (in_code_block) {
            print "</code></pre>"
            in_code_block = 0
        } else {
            print "<pre><code>"
            in_code_block = 1
        }
        next
    }
    
    # If in code block, print as-is
    in_code_block {
        gsub(/&/, "\\&amp;")
        gsub(/</, "\\&lt;")
        gsub(/>/, "\\&gt;")
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
    
    # Regular text
    {
        if (in_list) { print "</ul>"; in_list = 0 }
        # Process inline formatting
        gsub(/\*\*([^*]+)\*\*/, "<strong>\\1</strong>")
        gsub(/`([^`]+)`/, "<code>\\1</code>")
        gsub(/\[([^\]]+)\]\(([^)]+)\)/, "<a href=\"\\2\">\\1</a>")
        gsub(/[<>&"'"'"']/, "")
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
    
    # Generate elegant post layout
    cat > "public/p/$num.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>$title</title>
<style>$CSS</style>
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

# Generate main page
{
    echo "<!DOCTYPE html><title>$SITE_TITLE</title><style>$CSS</style><h1>$SITE_TITLE</h1><input id=s placeholder=\"Search...\" onkeyup=f()><div id=p>"
    
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

# Generate archive with consistent formatting
{
    echo "<!DOCTYPE html><title>Archive</title><style>$CSS</style><a href=../>← Home</a><h1>Archive</h1><div class=stats>$total posts</div><input id=s placeholder=\"Search...\" onkeyup=f()><div id=p>"
    
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

echo "✅ Elegant blog built with consistent styling!"
echo "📊 $total posts generated"
echo "🎨 All posts now have uniform, elegant formatting"
echo "🚀 Blog is ready!"
