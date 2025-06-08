#!/bin/bash
set -e

echo "🔧 Building ultra-mini blog..."

# Clean up
rm -rf public
mkdir -p public/p

# Config
SITE_TITLE="${SITE_TITLE:-Mini Blog}"

# Nuclear CSS (199 bytes)
CSS='body{max-width:40em;margin:1em auto;padding:0 .5em;font:1em/1.5 sans-serif}a{color:#36c}.p{margin:1em 0;padding:.3em;background:#f8f8f8}input{width:100%;margin:.5em 0;padding:.3em;border:1px solid #ccc}.h{background:#ff0}'

# Get files
files=($(ls content/*.md 2>/dev/null | sort))
total=${#files[@]}

# Build search data (single-letter keys)
SD="["
for i in "${!files[@]}"; do
    file="${files[$i]}"
    n=$((i+1))
    t=$(head -1 "$file" | sed 's/^# *//;s/"/\\"/g')
    e=$(sed -n '3p' "$file" | sed 's/"/\\"/g')
    c=$(tail -n +3 "$file" | tr -d '\n' | sed 's/"/\\"/g')
    SD+="{\"n\":$n,\"t\":\"$t\",\"e\":\"$e\",\"c\":\"$c\"}"
    [ $i -lt $((total-1)) ] && SD+=","
done
SD+="]"

# Generate posts
for i in "${!files[@]}"; do
    file="${files[$i]}"
    n=$((i+1))
    t=$(head -1 "$file" | sed 's/^# *//')
    c=$(tail -n +3 "$file" | sed 's/^$/<p>/;s/^[^<]/<p>&/')
    echo -n '<!doctype html><meta charset=utf-8><title>'$t'</title><style>'$CSS'</style><a href=../>←</a><h1>'$t'</h1>'$c > "public/p/$n.html"
done

# Generate index.html
echo -n '<!doctype html><meta charset=utf-8><title>'$SITE_TITLE'</title><style>'$CSS'</style><h1>'$SITE_TITLE'</h1><input id=s><div id=r></div><div id=p>' > public/index.html

# Generate posts list
ls content/*.md | sort -r | head -20 | while read f; do
    n=1
    for x in $(ls content/*.md | sort); do [ "$x" = "$f" ] && break; n=$((n+1)); done
    t=$(head -1 "$f" | sed 's/^# *//;s/<[^>]*>//g')
    echo -n "<div class=p data-id=$n><h2><a href=p/$n.html>$t</a>" >> public/index.html
done

# Add JS (428 bytes)
echo -n '</div><script>d='$SD';s=function(){let e=document.getElementById("s").value.toLowerCase(),n=document.getElementById("r"),t=document.getElementById("p");if(!e){n.innerHTML="";t.style.display="block";return}t.style.display="none";n.innerHTML="";for(o of d)if(o.t.toLowerCase().includes(e)||o.c.toLowerCase().includes(e))n.innerHTML+="<div class=p><h2><a href=p/"+o.n+".html>"+o.t.replace(new RegExp(e,"gi"),"<span class=h>$&</span>")+"</a>"};document.getElementById("s").oninput=s</script>' >> public/index.html

# Generate archive
mkdir -p public/archive
echo -n '<!doctype html><meta charset=utf-8><title>Archive</title><style>'$CSS'</style><a href=../>←</a><h1>Archive</h1><input id=s><div id=r></div><div id=p>' > public/archive/index.html
ls content/*.md | sort -r | while read f; do
    n=1
    for x in $(ls content/*.md | sort); do [ "$x" = "$f" ] && break; n=$((n+1)); done
    t=$(head -1 "$f" | sed 's/^# *//;s/<[^>]*>//g')
    echo -n "<div class=p data-id=$n><h2><a href=../p/$n.html>$t</a>" >> public/archive/index.html
done
echo -n '</div><script>d='$SD';s=function(){let e=document.getElementById("s").value.toLowerCase(),n=document.getElementById("r"),t=document.getElementById("p");if(!e){n.innerHTML="";t.style.display="block";return}t.style.display="none";n.innerHTML="";for(o of d)if(o.t.toLowerCase().includes(e)||o.c.toLowerCase().includes(e))n.innerHTML+="<div class=p><h2><a href=../p/"+o.n+".html>"+o.t.replace(new RegExp(e,"gi"),"<span class=h>$&</span>")+"</a>"};document.getElementById("s").oninput=s</script>' >> public/archive/index.html

# Stats
size=$(wc -c < public/index.html)
echo "✅ Build complete! ($total posts)"
echo "📦 Homepage size: $size bytes ($(echo "scale=2; $size/1024" | bc) KB)"
