#!/bin/bash
set -e

echo "🔧 Building blog..."

# Clean up and create directories
rm -rf public
mkdir -p public/p public/archive

# Configuration
SITE_TITLE="${SITE_TITLE:-My Blog}"

# Basic CSS
CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.6;color:#333}
a{color:#06c;text-decoration:none}a:hover{text-decoration:underline}
h1{font-size:1.8em;margin-bottom:.5em}h2{font-size:1.3em;margin:2em 0 1em}
p{margin-bottom:1em}small{color:#666;display:block;margin-bottom:1em}
pre{background:#f8f8f8;padding:1em;margin:1.5em 0;border-radius:4px}
.post{margin-bottom:2em;padding:1em;background:#fafafa;border-radius:4px}
input{width:100%;margin-bottom:1em;padding:.5em;border:1px solid #ddd;border-radius:4px}
nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #eee}'

# Get sorted file list
files=($(ls content/*.md 2>/dev/null | sort))
total=${#files[@]}

echo "📁 Found $total markdown files"

# Generate individual posts
echo "📝 Generating posts..."
for i in "${!files[@]}"; do
    file="${files[$i]}"
    num=$((i + 1))
    
    # Extract basic info safely
    title=$(head -1 "$file" | sed 's/^# *//' | tr -d '<>&"')
    content=$(tail -n +3 "$file" | tr -d '<>&"' | sed 's/^$/<p>/' | sed 's/^[^<]/<p>&/')
    
    # Simple date from filename
    date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
    
    # Create post
    cat > "public/p/$num.html" << EOF
<!DOCTYPE html><title>$title</title>
<style>$CSS</style>
<nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav>
<h1>$title</h1>
<small>$date</small>
$content
<nav><a href="../">← Back</a></nav>
EOF
    
    echo "✅ Post $num: $title"
done

# Generate main page with simpler approach
echo "🏠 Generating main page..."
{
    echo "<!DOCTYPE html><title>$SITE_TITLE</title>"
    echo "<style>$CSS</style>"
    echo "<h1>$SITE_TITLE</h1>"
    echo '<input id="s" placeholder="Search posts..." onkeyup="f()">'
    echo '<div id="posts">'
    
    # Get recent 20 posts (simpler approach)
    ls content/*.md 2>/dev/null | sort -r | head -20 | while read file; do
        # Find the post number
        post_num=1
        for f in $(ls content/*.md | sort); do
            if [ "$f" = "$file" ]; then
                break
            fi
            post_num=$((post_num + 1))
        done
        
        title=$(head -1 "$file" | sed 's/^# *//' | tr -d '<>&"')
        excerpt=$(sed -n '3p' "$file" | tr -d '<>&"')
        date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
        
        echo "<div class=\"post\"><small>$date</small><h2><a href=\"p/$post_num.html\">$title</a></h2><p>$excerpt</p></div>"
    done
    
    echo '</div>'
    echo "<p>📚 <a href=\"archive/\">View all $total posts</a></p>"
    
    echo '<script>
function f(){
    let q=s.value.toLowerCase(),d=document.getElementById("posts");
    if(!window.orig)window.orig=d.innerHTML;
    if(!q){d.innerHTML=window.orig;return}
    let r=Array.from(d.children).filter(e=>e.textContent.toLowerCase().includes(q));
    d.innerHTML=r.length?r.map(e=>e.outerHTML).join(""):"<p>No posts found</p>"
}
</script>'
} > public/index.html

# Generate archive with simpler approach
echo "📚 Generating archive..."
{
    echo "<!DOCTYPE html><title>Archive - $SITE_TITLE</title>"
    echo "<style>$CSS</style>"
    echo '<nav><a href="../">← Home</a></nav>'
    echo "<h1>Archive ($total posts)</h1>"
    echo '<input id="s" placeholder="Search all posts..." onkeyup="f()">'
    echo '<div id="posts">'
    
    # All posts in reverse order
    ls content/*.md 2>/dev/null | sort -r | while read file; do
        # Find the post number
        post_num=1
        for f in $(ls content/*.md | sort); do
            if [ "$f" = "$file" ]; then
                break
            fi
            post_num=$((post_num + 1))
        done
        
        title=$(head -1 "$file" | sed 's/^# *//' | tr -d '<>&"')
        excerpt=$(sed -n '3p' "$file" | tr -d '<>&"')
        date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
        
        echo "<div class=\"post\"><small>$date</small><h2><a href=\"../p/$post_num.html\">$title</a></h2><p>$excerpt</p></div>"
    done
    
    echo '</div>'
    echo '<script>
function f(){
    let q=s.value.toLowerCase(),d=document.getElementById("posts");
    if(!window.orig)window.orig=d.innerHTML;
    if(!q){d.innerHTML=window.orig;return}
    let r=Array.from(d.children).filter(e=>e.textContent.toLowerCase().includes(q));
    d.innerHTML=r.length?r.map(e=>e.outerHTML).join(""):"<p>No posts found</p>"
}
</script>'
} > public/archive/index.html

echo "✅ Blog built successfully!"
echo "📊 Generated $total posts"
echo "🏠 Main page: $(wc -c < public/index.html) bytes"
echo "📚 Archive: $(wc -c < public/archive/index.html) bytes"
