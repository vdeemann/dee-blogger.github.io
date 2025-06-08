#!/bin/bash
set -e

echo "🔧 Building blog..."

# Clean up and create directories
rm -rf public
mkdir -p public/p public/archive

# Configuration
SITE_TITLE="${SITE_TITLE:-My Blog}"

# Basic CSS (unchanged)
CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.6;color:#333}
a{color:#06c;text-decoration:none}a:hover{text-decoration:underline}
h1{font-size:1.8em;margin-bottom:.5em}h2{font-size:1.3em;margin:2em 0 1em}
p{margin-bottom:1em}small{color:#666;display:block;margin-bottom:1em}
pre{background:#f8f8f8;padding:1em;margin:1.5em 0;border-radius:4px}
.post{margin-bottom:2em;padding:1em;background:#fafafa;border-radius:4px}
input{width:100%;margin-bottom:1em;padding:.5em;border:1px solid #ddd;border-radius:4px}
nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #eee}
.search-result{background:#ffffe0}'

# Get sorted file list
files=($(ls content/*.md 2>/dev/null | sort))
total=${#files[@]}

echo "📁 Found $total markdown files"

# Generate search index data
echo "🔍 Generating search index..."
SEARCH_DATA="["
for i in "${!files[@]}"; do
    file="${files[$i]}"
    num=$((i + 1))
    title=$(head -1 "$file" | sed 's/^# *//' | tr -d '<>&"')
    excerpt=$(sed -n '3p' "$file" | tr -d '<>&"')
    content=$(tail -n +3 "$file" | tr -d '<>&"')
    date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
    
    SEARCH_DATA+="{\"num\":$num,\"title\":\"$title\",\"excerpt\":\"$excerpt\",\"date\":\"$date\",\"content\":\"$content\"}"
    
    if [ $i -lt $((total - 1)) ]; then
        SEARCH_DATA+=","
    fi
done
SEARCH_DATA+="]"

# Generate individual posts (unchanged)
echo "📝 Generating posts..."
for i in "${!files[@]}"; do
    file="${files[$i]}"
    num=$((i + 1))
    title=$(head -1 "$file" | sed 's/^# *//' | tr -d '<>&"')
    content=$(tail -n +3 "$file" | tr -d '<>&"' | sed 's/^$/<p>/' | sed 's/^[^<]/<p>&/')
    date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
    
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

# Generate main page with improved search
echo "🏠 Generating main page..."
{
    cat << EOF
<!DOCTYPE html><title>$SITE_TITLE</title>
<style>$CSS</style>
<h1>$SITE_TITLE</h1>
<input id="search" placeholder="Search all posts..." autocomplete="off">
<div id="results"></div>
<div id="posts">
EOF

    # Show recent 20 posts by default
    ls content/*.md 2>/dev/null | sort -r | head -20 | while read file; do
        post_num=1
        for f in $(ls content/*.md | sort); do
            [ "$f" = "$file" ] && break
            post_num=$((post_num + 1))
        done
        
        title=$(head -1 "$file" | sed 's/^# *//' | tr -d '<>&"')
        excerpt=$(sed -n '3p' "$file" | tr -d '<>&"')
        date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
        
        echo "<div class=\"post\" data-id=\"$post_num\"><small>$date</small><h2><a href=\"p/$post_num.html\">$title</a></h2><p>$excerpt</p></div>"
    done
    
    echo '</div>'
    echo "<p>📚 <a href=\"archive/\">View all $total posts</a></p>"
    
    # Include search data and script
    echo "<script>const posts=$SEARCH_DATA;</script>"
    cat << 'EOF'
<script>
const search = document.getElementById('search');
const results = document.getElementById('results');
const postsContainer = document.getElementById('posts');

function highlight(text, term) {
    if (!term) return text;
    const re = new RegExp(term, 'gi');
    return text.replace(re, match => `<span class="search-result">${match}</span>`);
}

function performSearch(term) {
    term = term.toLowerCase().trim();
    
    if (!term) {
        results.innerHTML = '';
        postsContainer.style.display = 'block';
        return;
    }
    
    postsContainer.style.display = 'none';
    results.innerHTML = '<h2>Search Results</h2>';
    
    const matches = posts.filter(post => 
        post.title.toLowerCase().includes(term) ||
        post.excerpt.toLowerCase().includes(term) ||
        post.content.toLowerCase().includes(term)
    );
    
    if (matches.length === 0) {
        results.innerHTML = '<p>No matching posts found.</p>';
        return;
    }
    
    matches.forEach(post => {
        results.innerHTML += `
            <div class="post">
                <small>${post.date}</small>
                <h2><a href="p/${post.num}.html">${highlight(post.title, term)}</a></h2>
                <p>${highlight(post.excerpt, term)}</p>
            </div>
        `;
    });
}

search.addEventListener('input', (e) => {
    performSearch(e.target.value);
});
</script>
EOF
} > public/index.html

# Generate archive (similar to main page but shows all posts)
echo "📚 Generating archive..."
{
    cat << EOF
<!DOCTYPE html><title>Archive - $SITE_TITLE</title>
<style>$CSS</style>
<nav><a href="../">← Home</a></nav>
<h1>Archive ($total posts)</h1>
<input id="search" placeholder="Search all posts..." autocomplete="off">
<div id="results"></div>
<div id="posts">
EOF

    ls content/*.md 2>/dev/null | sort -r | while read file; do
        post_num=1
        for f in $(ls content/*.md | sort); do
            [ "$f" = "$file" ] && break
            post_num=$((post_num + 1))
        done
        
        title=$(head -1 "$file" | sed 's/^# *//' | tr -d '<>&"')
        excerpt=$(sed -n '3p' "$file" | tr -d '<>&"')
        date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
        
        echo "<div class=\"post\" data-id=\"$post_num\"><small>$date</small><h2><a href=\"../p/$post_num.html\">$title</a></h2><p>$excerpt</p></div>"
    done
    
    echo '</div>'
    
    # Same search functionality as main page
    echo "<script>const posts=$SEARCH_DATA;</script>"
    cat << 'EOF'
<script>
const search = document.getElementById('search');
const results = document.getElementById('results');
const postsContainer = document.getElementById('posts');

function highlight(text, term) {
    if (!term) return text;
    const re = new RegExp(term, 'gi');
    return text.replace(re, match => `<span class="search-result">${match}</span>`);
}

function performSearch(term) {
    term = term.toLowerCase().trim();
    
    if (!term) {
        results.innerHTML = '';
        postsContainer.style.display = 'block';
        return;
    }
    
    postsContainer.style.display = 'none';
    results.innerHTML = '<h2>Search Results</h2>';
    
    const matches = posts.filter(post => 
        post.title.toLowerCase().includes(term) ||
        post.excerpt.toLowerCase().includes(term) ||
        post.content.toLowerCase().includes(term)
    );
    
    if (matches.length === 0) {
        results.innerHTML = '<p>No matching posts found.</p>';
        return;
    }
    
    matches.forEach(post => {
        results.innerHTML += `
            <div class="post">
                <small>${post.date}</small>
                <h2><a href="../p/${post.num}.html">${highlight(post.title, term)}</a></h2>
                <p>${highlight(post.excerpt, term)}</p>
            </div>
        `;
    });
}

search.addEventListener('input', (e) => {
    performSearch(e.target.value);
});
</script>
EOF
} > public/archive/index.html

echo "✅ Blog built successfully!"
echo "📊 Generated $total posts"
echo "🔍 Search index contains $total entries"
echo "🏠 Main page: $(wc -c < public/index.html) bytes"
echo "📚 Archive: $(wc -c < public/archive/index.html) bytes"
