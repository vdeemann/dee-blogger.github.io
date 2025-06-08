#!/bin/bash
set -e

echo "🔧 Building optimized blog..."

# Clean up
rm -rf public
mkdir -p public/p public/archive

# Config
SITE_TITLE="${SITE_TITLE:-My Blog}"

# Optimized CSS (with visual separation)
CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:sans-serif;line-height:1.6}
a{color:#06c;text-decoration:none}
h1{font-size:1.8em;margin-bottom:.5em}
.post{margin-bottom:2em;padding:1em;background:#fafafa;border-radius:4px}
.date{color:#666;display:block;margin-bottom:.5em}
input{width:100%;margin-bottom:1em;padding:.5em;border:1px solid #ddd;border-radius:4px}
.highlight{background:#ff0}'

# Get files
files=($(ls content/*.md 2>/dev/null | sort))
total=${#files[@]}

# Build search data
SEARCH_DATA="["
for i in "${!files[@]}"; do
    file="${files[$i]}"
    num=$((i+1))
    title=$(head -1 "$file" | sed 's/^# *//;s/"/\\"/g')
    excerpt=$(sed -n '3p' "$file" | sed 's/"/\\"/g')
    content=$(tail -n +3 "$file" | tr -d '\n' | sed 's/"/\\"/g')
    date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
    
    SEARCH_DATA+="{\"n\":$num,\"t\":\"$title\",\"d\":\"$date\",\"e\":\"$excerpt\",\"c\":\"$content\"}"
    [ $i -lt $((total-1)) ] && SEARCH_DATA+=","
done
SEARCH_DATA+="]"

# Generate posts
for i in "${!files[@]}"; do
    file="${files[$i]}"
    num=$((i+1))
    title=$(head -1 "$file" | sed 's/^# *//')
    content=$(tail -n +3 "$file" | sed 's/^$/<p>/;s/^[^<]/<p>&/')
    date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
    
    cat > "public/p/$num.html" << EOF
<!DOCTYPE html><meta charset=utf-8>
<title>$title</title>
<style>$CSS</style>
<a href=../>← Blog</a>
<div class=post>
<h1>$title</h1>
<small class=date>$date</small>
$content
</div>
EOF
done

# Generate index.html
{
    echo "<!DOCTYPE html><meta charset=utf-8>"
    echo "<title>$SITE_TITLE</title>"
    echo "<style>$CSS</style>"
    echo "<h1>$SITE_TITLE</h1>"
    echo '<input id=search placeholder="Search...">'
    echo '<div id=results></div>'
    echo '<div id=posts>'
    
    # Recent 20 posts with visual separation
    ls content/*.md | sort -r | head -20 | while read file; do
        num=1
        for f in $(ls content/*.md | sort); do [ "$f" = "$file" ] && break; num=$((num+1)); done
        title=$(head -1 "$file" | sed 's/^# *//')
        date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
        
        echo "<div class=post data-id=$num>"
        echo "<h2><a href=p/$num.html>$title</a></h2>"
        echo "<small class=date>$date</small>"
        echo "</div>"
    done
    
    echo "</div>"
    echo "<script>const data=$SEARCH_DATA;"
    cat << 'EOF'
document.getElementById('search').oninput=function(){
    const term=this.value.toLowerCase();
    const results=document.getElementById('results');
    const posts=document.getElementById('posts');
    
    if(!term){
        results.innerHTML='';
        posts.style.display='block';
        return;
    }
    
    posts.style.display='none';
    results.innerHTML='';
    
    const matches=data.filter(post=>
        post.t.toLowerCase().includes(term)||
        post.c.toLowerCase().includes(term)
    );
    
    matches.forEach(post=>{
        const highlighted=post.t.replace(
            new RegExp(term,'gi'),
            '<span class=highlight>$&</span>'
        );
        results.innerHTML+=`
            <div class=post>
                <h2><a href=p/${post.n}.html>${highlighted}</a></h2>
                <small class=date>${post.d}</small>
            </div>
        `;
    });
}
EOF
} > public/index.html

# Generate archive (similar structure)
{
    echo "<!DOCTYPE html><meta charset=utf-8>"
    echo "<title>Archive - $SITE_TITLE</title>"
    echo "<style>$CSS</style>"
    echo '<a href=../>← Home</a>'
    echo "<h1>Archive ($total posts)</h1>"
    echo '<input id=search placeholder="Search...">'
    echo '<div id=results></div>'
    echo '<div id=posts>'
    
    ls content/*.md | sort -r | while read file; do
        num=1
        for f in $(ls content/*.md | sort); do [ "$f" = "$file" ] && break; num=$((num+1)); done
        title=$(head -1 "$file" | sed 's/^# *//')
        date=$(basename "$file" | cut -d- -f1-3 | sed 's/-/\//g')
        
        echo "<div class=post data-id=$num>"
        echo "<h2><a href=p/$num.html>$title</a></h2>"
        echo "<small class=date>$date</small>"
        echo "</div>"
    done
    
    echo "</div>"
    echo "<script>const data=$SEARCH_DATA;</script>"
    echo "<script src=../index.html></script>"
} > public/archive/index.html

echo "✅ Build complete! ($total posts)"
