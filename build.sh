#!/bin/bash
set -e

echo "🔧 Building elegant, consistent blog..."

rm -rf public
mkdir -p public/p public/archive

SITE_TITLE="${SITE_TITLE:-My Blog}"

# Compact CSS for main/archive pages
COMPACT_CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;line-height:1.4;color:#333;-webkit-font-smoothing:antialiased}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.8em;margin:0 0 .5em 0;color:#222;font-weight:600}h2{font-size:1.1em;margin:0;color:#333;font-weight:600}p{margin:.2em 0;color:#333}small{color:#666;display:block;margin:0;font-size:.85em}.post{margin-bottom:.6em;padding:.4em .6em;background:#fafafa;border-radius:3px;border:1px solid #e8e8e8}input{width:100%;margin-bottom:.5em;padding:.4em;border:1px solid #ddd;border-radius:3px;font-size:.9em}nav{margin:.8em 0;padding:.3em 0}.stats{background:#fff3cd;padding:.5em;border-radius:3px;margin:.5em 0;text-align:center;font-size:.9em}'

# Elegant CSS for individual blog posts with copy-enabled code blocks
POST_CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;line-height:1.6;color:#333;-webkit-font-smoothing:antialiased}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.8em;margin:0 0 .3em 0;color:#222;font-weight:600}h2{font-size:1.3em;margin:2em 0 1em;color:#333;font-weight:600}h3{font-size:1.1em;margin:1.5em 0 .5em;color:#444;font-weight:600}p{margin:1em 0;color:#333}small{color:#666;display:block;margin-bottom:1.5em;font-size:.9em}strong{font-weight:600}code{background:#f6f8fa;color:#24292e;padding:.1em .3em;border-radius:3px;font-family:"SF Mono",Monaco,monospace;font-size:.85em}pre{background:#f6f8fa;padding:.4em .6em;margin:.8em 0;border-radius:4px;overflow-x:auto;line-height:1.2;border:1px solid #e1e4e8;position:relative}pre:hover .copy-btn{opacity:1}pre code{background:none;padding:0;font-size:.8em;color:#24292e;font-family:"SF Mono",Monaco,monospace;line-height:1.2;display:block}.copy-btn{position:absolute;top:4px;right:4px;background:#fff;border:1px solid #d1d9e0;border-radius:3px;padding:2px 6px;font-size:11px;color:#586069;cursor:pointer;opacity:0;transition:opacity 0.2s;user-select:none}.copy-btn:hover{background:#f6f8fa;color:#0366d6}.copy-btn:active{background:#e1e8ed}.copy-success{color:#28a745!important}ul{margin:1em 0;padding-left:1.5em}li{margin:.5em 0;color:#333}nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #eee}blockquote{background:#f6f8fa;border-left:4px solid #0366d6;margin:1.5em 0;padding:1em 1.5em;border-radius:0 6px 6px 0;color:#586069;font-style:italic}'

files=($(ls content/*.md 2>/dev/null | sort))
total=${#files[@]}

echo "📁 Processing $total files with consistent styling..."

# Simple but effective markdown processing function
process_markdown() {
    local file="$1"
    tail -n +3 "$file" | sed '
        # Handle code blocks first
        /^```/,/^```/ {
            /^```$/ {
                s/.*/CODEBLOCK_MARKER/
                b
            }
            /^```.*/ {
                s/.*/CODEBLOCK_MARKER/
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
    BEGIN { in_code = 0; in_list = 0 }
    
    /CODEBLOCK_MARKER/ {
        if (in_code) {
            print "</code><span class=\"copy-btn\" onclick=\"copyCode(this)\">Copy</span></pre>"
            in_code = 0
        } else {
            if (in_list) { print "</ul>"; in_list = 0 }
            print "<pre><code>"
            in_code = 1
        }
        next
    }
    
    /^CODE_LINE:/ {
        gsub(/^CODE_LINE:/, "")
        print
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
        print
    }
    
    END {
        if (in_code) print "</code><span class=\"copy-btn\" onclick=\"copyCode(this)\">Copy</span></pre>"
        if (in_list) print "</ul>"
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
    
    # Generate elegant individual post layout with copy functionality
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
<script>
function copyCode(btn) {
    const code = btn.previousElementSibling;
    const text = code.textContent;
    navigator.clipboard.writeText(text).then(() => {
        const original = btn.textContent;
        btn.textContent = 'Copied!';
        btn.classList.add('copy-success');
        setTimeout(() => {
            btn.textContent = original;
            btn.classList.remove('copy-success');
        }, 2000);
    }).catch(() => {
        // Fallback for older browsers
        const textArea = document.createElement('textarea');
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        btn.textContent = 'Copied!';
        setTimeout(() => btn.textContent = 'Copy', 2000);
    });
}
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

echo "✅ Elegant blog built with copy-enabled code blocks!"
echo "📊 $total posts generated"
echo "🎨 All posts have uniform styling with compact, copyable code blocks"
echo "📋 Code sections include elegant copy-to-clipboard functionality"
echo "🚀 Blog is ready!"
