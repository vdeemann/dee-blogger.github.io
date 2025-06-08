#!/bin/bash
set -e

echo "🔧 Building clean minimal blog..."

# Clean up
rm -rf public
mkdir -p public/p public/archive

# Config
SITE_TITLE="${SITE_TITLE:-My Blog}"

# Clean, minimal CSS
CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.6;color:#333}
a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}
h1{font-size:1.8em;margin-bottom:.5em;color:#222}
h2{font-size:1.3em;margin:0;color:#333}
p{margin-bottom:1em}
small{color:#666;display:block;margin-bottom:1em;font-size:.9em}
.post{margin-bottom:2em;padding:1.2em;background:#fafbfc;border-radius:8px;border:1px solid #e1e8ed}
.post:hover{background:#f5f8fa;transition:all 0.2s ease}
input{width:100%;margin-bottom:1em;padding:.7em;border:1px solid #d1d9e0;border-radius:6px;font-size:1em}
input:focus{outline:none;border-color:#0066cc}
nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #eee}
.archive-link{background:#e8f5e8;padding:1em;border-radius:6px;margin:2em 0;text-align:center;border:1px solid #4caf50}'

# Get files
files=($(ls content/*.md 2>/dev/null | sort))
total=${#files[@]}

echo "📁 Found $total markdown files"

# Generate individual posts
echo "📝 Generating posts..."
for i in "${!files[@]}"; do
    file="${files[$i]}"
    num=$((i + 1))
    
    # Extract info safely
    title=$(head -1 "$file" | sed 's/^# *//' | sed 's/[<>&"'"'"']//g')
    content=$(tail -n +3 "$file" | sed 's/[<>&"'"'"']//g' | sed 's/^$/<p>/' | sed 's/^[^<#-]/<p>&/')
    date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
    
    # Create post with proper structure
    cat > "public/p/$num.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>$title - $SITE_TITLE</title>
<style>$CSS</style>
</head>
<body>
<nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav>
<small>$date</small>
<h1>$title</h1>
$content
<nav style="border-top:1px solid #eee;border-bottom:0;margin-top:2em"><a href="../">← Back to Blog</a></nav>
</body>
</html>
EOF
    
    echo "✅ Post $num: $title"
done

# Generate main page
echo "🏠 Generating main page..."
{
    cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>$SITE_TITLE</title>
<style>$CSS</style>
</head>
<body>
<h1>$SITE_TITLE</h1>
<input id="search" placeholder="Search recent posts..." onkeyup="searchPosts()">
<div id="posts">
EOF
    
    # Recent 20 posts with excerpts
    count=0
    ls content/*.md | sort -r | head -20 | while read file; do
        # Find post number
        num=1
        for f in $(ls content/*.md | sort); do
            if [ "$f" = "$file" ]; then
                break
            fi
            num=$((num + 1))
        done
        
        title=$(head -1 "$file" | sed 's/^# *//' | sed 's/[<>&"'"'"']//g')
        excerpt=$(sed -n '3p' "$file" | sed 's/[<>&"'"'"']//g')
        [ -z "$excerpt" ] && excerpt="..."
        date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
        
        echo "<div class=\"post\">"
        echo "<small>$date</small>"
        echo "<h2><a href=\"p/$num.html\">$title</a></h2>"
        echo "<p>$excerpt</p>"
        echo "</div>"
    done
    
    cat << EOF
</div>
<div class="archive-link">
📚 <a href="archive/">View all $total posts in archive</a> 📚
</div>

<script>
let originalPosts;
function searchPosts() {
    const query = document.getElementById('search').value.toLowerCase();
    const postsContainer = document.getElementById('posts');
    
    if (!originalPosts) {
        originalPosts = postsContainer.innerHTML;
    }
    
    if (!query) {
        postsContainer.innerHTML = originalPosts;
        return;
    }
    
    const posts = Array.from(postsContainer.children);
    const filtered = posts.filter(post => 
        post.textContent.toLowerCase().includes(query)
    );
    
    if (filtered.length > 0) {
        postsContainer.innerHTML = filtered.map(post => post.outerHTML).join('');
    } else {
        postsContainer.innerHTML = '<div class="post"><p>No posts found in recent posts. <a href="archive/">Search all posts</a></p></div>';
    }
}
</script>
</body>
</html>
EOF
} > public/index.html

# Generate archive page
echo "📚 Generating archive..."
{
    cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Archive - $SITE_TITLE</title>
<style>$CSS</style>
</head>
<body>
<nav><a href="../">← Home</a></nav>
<h1>All Posts</h1>
<div style="background:#fff3cd;padding:1em;border-radius:6px;margin:1em 0;text-align:center;border:1px solid #ffc107">
📊 Total: $total posts | 🔍 All searchable below
</div>
<input id="search" placeholder="Search all posts..." onkeyup="searchPosts()">
<div id="posts">
EOF
    
    # All posts with excerpts
    ls content/*.md | sort -r | while read file; do
        # Find post number
        num=1
        for f in $(ls content/*.md | sort); do
            if [ "$f" = "$file" ]; then
                break
            fi
            num=$((num + 1))
        done
        
        title=$(head -1 "$file" | sed 's/^# *//' | sed 's/[<>&"'"'"']//g')
        excerpt=$(sed -n '3p' "$file" | sed 's/[<>&"'"'"']//g')
        [ -z "$excerpt" ] && excerpt="..."
        date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
        
        echo "<div class=\"post\">"
        echo "<small>$date</small>"
        echo "<h2><a href=\"../p/$num.html\">$title</a></h2>"
        echo "<p>$excerpt</p>"
        echo "</div>"
    done
    
    cat << EOF
</div>

<script>
let originalPosts;
function searchPosts() {
    const query = document.getElementById('search').value.toLowerCase();
    const postsContainer = document.getElementById('posts');
    
    if (!originalPosts) {
        originalPosts = postsContainer.innerHTML;
    }
    
    if (!query) {
        postsContainer.innerHTML = originalPosts;
        return;
    }
    
    const posts = Array.from(postsContainer.children);
    const filtered = posts.filter(post => 
        post.textContent.toLowerCase().includes(query)
    );
    
    if (filtered.length > 0) {
        postsContainer.innerHTML = filtered.map(post => post.outerHTML).join('');
    } else {
        postsContainer.innerHTML = '<div class="post"><p>No posts found</p></div>';
    }
}
</script>
</body>
</html>
EOF
} > public/archive/index.html

echo "✅ Blog built successfully!"
echo "📊 Generated $total posts"
echo "🏠 Main page: $(wc -c < public/index.html) bytes"
echo "📚 Archive: $(wc -c < public/archive/index.html) bytes"
echo "🚀 Blog is ready!"
