#!/bin/bash
set -e
set -o pipefail

# 🚀 EXTREME PERFORMANCE BUILD SCRIPT - Push GitHub's Limits
# Designed to handle 50,000+ posts while staying within GitHub constraints

# Global configuration
SITE_TITLE="${SITE_TITLE:-Ultra High Performance Blog}"
BASE_URL="${BASE_URL:-https://vdeemann.github.io/dee-blogger.github.io}"
CHUNK_SIZE="${CHUNK_SIZE:-400}"
PARALLEL_JOBS="${PARALLEL_JOBS:-$(nproc)}"

# Ultra-compressed CSS - optimized for maximum compression
read -r -d '' MAIN_CSS << 'EOF' || true
body{max-width:42em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.5;color:#333;background:#fff}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.9em;margin:0 0 .4em;color:#1a1a1a;font-weight:700}h2{font-size:1.2em;margin:0;color:#333;font-weight:600}p{margin:.3em 0}small{color:#666;display:block;margin:0;font-size:.9em}.post{margin:0 0 .7em;padding:.5em .7em;background:#fafafa;border-radius:4px;border:1px solid #e8e8e8;transition:all .2s}.post:hover{background:#f5f5f5;border-color:#ddd}input{width:100%;margin:0 0 .6em;padding:.5em;border:1px solid #ddd;border-radius:4px;font-size:.95em;background:#fff}nav{margin:.9em 0;padding:.4em 0;border-bottom:1px solid #eee}.stats{background:#fff3cd;padding:.6em;border-radius:4px;margin:.6em 0;text-align:center;font-size:.95em;border:1px solid #ffeaa7}.search-highlight{background:#ffeb3b;padding:0 .2em;border-radius:2px}
EOF

read -r -d '' POST_CSS << 'EOF' || true
body{max-width:42em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.6;color:#333}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.9em;margin:0 0 .4em;color:#1a1a1a;font-weight:700}h2{font-size:1.4em;margin:2em 0 1em;color:#333;font-weight:600}h3{font-size:1.2em;margin:1.5em 0 .6em;color:#444;font-weight:600}p{margin:1em 0}small{color:#666;display:block;margin:0 0 1.5em;font-size:.95em}strong{font-weight:600}code{background:#f6f8fa;color:#24292e;padding:.15em .4em;border-radius:3px;font-family:Monaco,Consolas,monospace;font-size:.9em}pre{background:#f6f8fa;padding:.4em .6em;margin:.9em 0;border-radius:5px;overflow-x:auto;border:1px solid #e1e4e8;position:relative}pre code{background:0;padding:0;font-size:.8em;color:#24292e;font-family:Monaco,Consolas,monospace;display:block}ul,ol{margin:1em 0;padding-left:1.8em}li{margin:.4em 0}nav{margin:1.6em 0;padding:.6em 0;border-bottom:1px solid #eee}blockquote{background:#f6f8fa;border-left:4px solid #0066cc;margin:1.6em 0;padding:1em 1.6em;border-radius:0 6px 6px 0;color:#586069;font-style:italic}.copy-btn{position:absolute;top:5px;right:5px;background:#fff;border:1px solid #d1d9e0;border-radius:3px;padding:5px 9px;font-size:11px;color:#586069;cursor:pointer;z-index:10;transition:all .2s}.copy-btn:hover{background:#f6f8fa;color:#0366d6;border-color:#0366d6}.copy-success{color:#fff!important;background:#28a745!important;border-color:#28a745!important}
EOF

read -r -d '' ARCHIVE_CSS << 'EOF' || true
body{max-width:48em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.5;color:#333}a{color:#0066cc;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.9em;margin:0 0 .5em;color:#1a1a1a;font-weight:700}h2,h3{font-weight:600;margin:0}h2{font-size:1.2em;color:#333}p{margin:.4em 0}small{color:#666;display:block;margin:0;font-size:.9em}input{width:100%;margin:0 0 1em;padding:.5em;border:1px solid #ddd;border-radius:4px;font-size:.95em;background:#fff}nav{margin:.9em 0;padding:.4em 0}.stats{background:#fff3cd;padding:.6em;border-radius:4px;margin:.6em 0;text-align:center;font-size:.95em;border:1px solid #ffeaa7}.timeline{position:relative;margin:2em 0;padding-left:2.2em}.timeline:before{content:"";position:absolute;left:16px;top:0;bottom:0;width:2px;background:linear-gradient(180deg,#0066cc,#e1e8ed)}.year-section{margin:0 0 3.5em}.year-header{position:relative;margin:0 0 1.8em}.year-header h2{background:#0066cc;color:#fff;padding:.6em 1.2em;border-radius:25px;display:inline-block;font-size:1.3em;margin:0;position:relative;z-index:2;box-shadow:0 2px 8px rgba(0,102,204,.2)}.year-header:before{content:"";position:absolute;left:-11px;top:50%;transform:translateY(-50%);width:22px;height:22px;background:#0066cc;border:4px solid #fff;border-radius:50%;box-shadow:0 0 0 2px #0066cc}.month-section{margin:0 0 2.2em;position:relative}.month-header{position:relative;margin:0 0 1.2em;padding-left:1.2em}.month-header h3{background:#f8f9fa;color:#333;padding:.4em .9em;border-radius:18px;display:inline-block;font-size:1.05em;margin:0;border:1px solid #e1e8ed;position:relative;z-index:2}.month-header:before{content:"";position:absolute;left:-7px;top:50%;transform:translateY(-50%);width:14px;height:14px;background:#fff;border:3px solid #0066cc;border-radius:50%}.post-item{position:relative;margin:0 0 .9em 1.2em;padding:.7em .9em;background:#fff;border-radius:6px;border:1px solid #e1e8ed;transition:all .25s;cursor:pointer}.post-item:hover{background:#f8f9fa;border-color:#0066cc;transform:translateX(3px);box-shadow:0 3px 8px rgba(0,102,204,.12)}.post-item:before{content:"";position:absolute;left:-8px;top:50%;transform:translateY(-50%);width:8px;height:8px;background:#0066cc;border-radius:50%}.search-active .timeline:before{background:#ddd}.search-active .year-header:before,.search-active .month-header:before,.search-active .post-item:before{background:#ddd;border-color:#ddd}.search-active .year-header h2{background:#666}.pagination{text-align:center;margin:2em 0;padding:1em 0;border-top:1px solid #eee}.pagination a,.pagination span{display:inline-block;padding:.5em .8em;margin:0 .3em;border:1px solid #ddd;border-radius:4px;text-decoration:none}.pagination a:hover{background:#f0f0f0;border-color:#999}.pagination .current{background:#0066cc;color:#fff;border-color:#0066cc}
EOF

# Optimized markdown processor using sed for maximum speed
process_markdown_fast() {
    local file="$1"
    
    # Skip frontmatter (first 3 lines) and process content
    tail -n +4 "$file" | sed -E '
        # Headers
        s/^### (.+)/<h3>\1<\/h3>/
        s/^## (.+)/<h2>\1<\/h2>/
        s/^# (.+)/<h1>\1<\/h1>/
        
        # Code blocks (simple approach for speed)
        s/^```.*$/<pre><code>/
        /^```$/s/.*/<\/code><\/pre>/
        
        # Inline formatting
        s/\*\*([^*]+)\*\*/<strong>\1<\/strong>/g
        s/`([^`]+)`/<code>\1<\/code>/g
        s/\[([^\]]+)\]\(([^)]+)\)/<a href="\2">\1<\/a>/g
        
        # Lists
        s/^[•*-] (.+)/<li>\1<\/li>/
        
        # Paragraphs (anything that doesn'\''t start with <)
        /^[^<].*$/s/.*/<p>&<\/p>/
        
        # Clean up empty lines
        /^$/d
    '
}

# Extract metadata efficiently
extract_metadata() {
    local file="$1"
    local title=$(head -n1 "$file" | sed 's/^# *//')
    local date=$(basename "$file" | grep -o '^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' | tr - /)
    local excerpt=$(sed -n '3p' "$file" | sed 's/[<>&"'\'']/./g' | cut -c1-120)
    local slug=$(basename "$file" .md)
    
    echo "$title|$date|$excerpt|$slug"
}

# Process a single post file
process_single_post() {
    local file="$1"
    local metadata=$(extract_metadata "$file")
    local title=$(echo "$metadata" | cut -d'|' -f1)
    local date=$(echo "$metadata" | cut -d'|' -f2)
    local slug=$(echo "$metadata" | cut -d'|' -f4)
    
    # Extract post number from filename
    local num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "1")
    
    # Process markdown content
    local content=$(process_markdown_fast "$file")
    
    # Generate ultra-minified HTML
    cat > "public/p/${num}.html" << EOF
<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${title} - ${SITE_TITLE}</title><meta name="description" content="$(echo "$metadata" | cut -d'|' -f3)"><style>${POST_CSS}</style></head><body><nav><a href="../">← Home</a> | <a href="../archive/">Archive</a></nav><h1>${title}</h1><small>${date}</small>${content}<nav style="border-top:1px solid #eee;margin-top:2em;padding-top:1em"><a href="../">← Back to Home</a></nav><script>function copyCode(b){let c=b.nextElementSibling,t=c.textContent;navigator.clipboard.writeText(t).then(()=>{let o=b.textContent;b.textContent='✓';b.classList.add('copy-success');setTimeout(()=>{b.textContent=o;b.classList.remove('copy-success')},2e3)}).catch(()=>{let e=document.createElement('textarea');e.value=t;e.style.position='fixed';e.style.left='-9999px';document.body.appendChild(e);e.select();document.execCommand('copy');document.body.removeChild(e);let o=b.textContent;b.textContent='✓';b.classList.add('copy-success');setTimeout(()=>{b.textContent=o;b.classList.remove('copy-success')},2e3)})}</script></body></html>
EOF
    
    echo "✅ Processed: $num - $title"
}

# Process a chunk of files in parallel
process_chunk() {
    if [ ! -f "$CHUNK_FILE" ]; then
        echo "❌ Chunk file not found: $CHUNK_FILE"
        exit 1
    fi
    
    local files_count=$(wc -l < "$CHUNK_FILE")
    echo "🚀 Processing chunk $CHUNK_ID with $files_count files using $PARALLEL_JOBS parallel jobs"
    
    # Process files in parallel within this chunk
    export -f process_single_post process_markdown_fast extract_metadata
    export SITE_TITLE POST_CSS
    
    # Use parallel to process files
    cat "$CHUNK_FILE" | parallel -j "$PARALLEL_JOBS" --will-cite process_single_post {}
    
    echo "✅ Chunk $CHUNK_ID completed: $files_count posts processed"
}

# Generate optimized main index page
generate_index() {
    echo "🏠 Generating main index page..."
    
    # Get recent posts (last 25) sorted by date
    local recent_posts=($(find content -name "*.md" | sort -t- -k2,2nr -k3,3nr -k4,4nr | head -25))
    local total_posts=${TOTAL_POSTS:-$(find content -name "*.md" | wc -l)}
    
    {
        cat << EOF
<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${SITE_TITLE}</title><meta name="description" content="A high-performance blog with ${total_posts} posts"><style>${MAIN_CSS}</style></head><body><h1>${SITE_TITLE}</h1><div class="stats">📊 ${total_posts} posts published</div><input id="s" placeholder="🔍 Search posts..." onkeyup="searchPosts()" autocomplete="off"><div id="posts">
EOF
        
        # Generate recent posts
        for file in "${recent_posts[@]}"; do
            if [ -f "$file" ]; then
                local metadata=$(extract_metadata "$file")
                local title=$(echo "$metadata" | cut -d'|' -f1)
                local date=$(echo "$metadata" | cut -d'|' -f2)
                local excerpt=$(echo "$metadata" | cut -d'|' -f3)
                local slug=$(echo "$metadata" | cut -d'|' -f4)
                local num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "1")
                
                cat << EOF
<div class="post" data-search="${title,,} ${excerpt,,}"><small>${date}</small><h2><a href="p/${num}.html">${title}</a></h2><p>${excerpt}...</p></div>
EOF
            fi
        done
        
        cat << EOF
</div><nav><p>📚 <a href="archive/">View all ${total_posts} posts in Archive</a></p></nav><script>let originalPosts;function searchPosts(){const query=s.value.toLowerCase();const postsContainer=document.getElementById('posts');if(!originalPosts)originalPosts=postsContainer.innerHTML;if(!query){postsContainer.innerHTML=originalPosts;return}const posts=Array.from(postsContainer.children);const filtered=posts.filter(post=>post.dataset.search&&post.dataset.search.includes(query));postsContainer.innerHTML=filtered.length?filtered.map(p=>p.outerHTML).join(''):'<p>No posts found matching your search.</p>'}</script></body></html>
EOF
    } > public/index.html
    
    echo "✅ Main index generated with $total_posts posts"
}

# Generate streaming archive with pagination for large datasets
generate_archive() {
    echo "📚 Generating archive..."
    
    local all_files=($(find content -name "*.md" | sort -t- -k2,2nr -k3,3nr -k4,4nr))
    local total_posts=${#all_files[@]}
    local posts_per_page=100
    local total_pages=$(( (total_posts + posts_per_page - 1) / posts_per_page ))
    
    echo "📊 Archive: $total_posts posts across $total_pages pages"
    
    # Generate main archive page (page 1)
    generate_archive_page 1 "$total_pages" "${all_files[@]:0:$posts_per_page}"
    cp "public/archive/index.html" "public/archive/page1.html"
    
    # Generate additional pages if needed
    if [ "$total_pages" -gt 1 ]; then
        for ((page=2; page<=total_pages && page<=10; page++)); do
            local start=$(( (page - 1) * posts_per_page ))
            generate_archive_page "$page" "$total_pages" "${all_files[@]:$start:$posts_per_page}"
        done
    fi
    
    echo "✅ Archive generated: $total_pages pages"
}

# Generate a single archive page
generate_archive_page() {
    local page_num="$1"
    local total_pages="$2"
    shift 2
    local files=("$@")
    
    local output_file="public/archive/page${page_num}.html"
    [ "$page_num" -eq 1 ] && output_file="public/archive/index.html"
    
    {
        cat << EOF
<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Archive - Page ${page_num} - ${SITE_TITLE}</title><style>${ARCHIVE_CSS}</style></head><body><nav><a href="../">← Home</a></nav><h1>Archive</h1><div class="stats">📊 ${TOTAL_POSTS:-0} total posts</div><input id="s" placeholder="🔍 Search archive..." onkeyup="searchArchive()"><div class="timeline" id="timeline">
EOF
        
        # Group posts by year and month
        declare -A year_months
        for file in "${files[@]}"; do
            if [ -f "$file" ]; then
                local basename=$(basename "$file")
                local year_month="${basename:0:7}"  # YYYY-MM
                year_months["$year_month"]+="$file "
            fi
        done
        
        # Generate timeline
        local current_year=""
        for ym in $(printf '%s\n' "${!year_months[@]}" | sort -nr); do
            local year="${ym:0:4}"
            local month="${ym:5:2}"
            local month_name=$(date -d "${year}-${month}-01" +%B 2>/dev/null || echo "Month")
            
            # Year header
            if [ "$year" != "$current_year" ]; then
                [ -n "$current_year" ] && echo "</div></div>"
                echo "<div class=\"year-section\"><div class=\"year-header\"><h2>$year</h2></div>"
                current_year="$year"
            fi
            
            # Month section
            echo "<div class=\"month-section\"><div class=\"month-header\"><h3>$month_name</h3></div>"
            
            # Posts in this month
            for file in ${year_months[$ym]}; do
                if [ -f "$file" ]; then
                    local metadata=$(extract_metadata "$file")
                    local title=$(echo "$metadata" | cut -d'|' -f1)
                    local date=$(echo "$metadata" | cut -d'|' -f2)
                    local excerpt=$(echo "$metadata" | cut -d'|' -f3)
                    local slug=$(echo "$metadata" | cut -d'|' -f4)
                    local num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "1")
                    
                    cat << EOF
<div class="post-item" data-search="${title,,} ${excerpt,,}" onclick="window.location.href='../p/${num}.html'"><small>${date}</small><h2><a href="../p/${num}.html">${title}</a></h2><p>${excerpt}...</p></div>
EOF
                fi
            done
            echo "</div>"
        done
        
        [ -n "$current_year" ] && echo "</div>"
        
        # Pagination
        if [ "$total_pages" -gt 1 ]; then
            echo "<div class=\"pagination\">"
            for ((p=1; p<=total_pages && p<=10; p++)); do
                if [ "$p" -eq "$page_num" ]; then
                    echo "<span class=\"current\">$p</span>"
                else
                    local link="page${p}.html"
                    [ "$p" -eq 1 ] && link="index.html"
                    echo "<a href=\"$link\">$p</a>"
                fi
            done
            [ "$total_pages" -gt 10 ] && echo "<span>...</span>"
            echo "</div>"
        fi
        
        cat << 'EOF'
</div><script>let originalTimeline;function searchArchive(){const query=s.value.toLowerCase();const timeline=document.getElementById('timeline');if(!originalTimeline)originalTimeline=timeline.innerHTML;if(!query){timeline.innerHTML=originalTimeline;return}const posts=Array.from(timeline.querySelectorAll('.post-item'));const filtered=posts.filter(post=>post.dataset.search&&post.dataset.search.includes(query));timeline.innerHTML=filtered.length?'<div class="year-section"><div class="year-header"><h2>Search Results</h2></div><div class="month-section">'+filtered.map(p=>p.outerHTML).join('')+'</div></div>':'<p>No posts found matching your search.</p>'}</script></body></html>
EOF
    } > "$output_file"
}

# Generate XML sitemap
generate_sitemap() {
    echo "🗺️ Generating sitemap..."
    
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
        
        # Main pages
        echo "<url><loc>${BASE_URL}/</loc><changefreq>daily</changefreq><priority>1.0</priority></url>"
        echo "<url><loc>${BASE_URL}/archive/</loc><changefreq>weekly</changefreq><priority>0.8</priority></url>"
        
        # Post pages
        find content -name "*.md" | sort | while read -r file; do
            local slug=$(basename "$file" .md)
            local num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "1")
            local date=$(echo "$slug" | grep -o '^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}')
            echo "<url><loc>${BASE_URL}/p/${num}.html</loc><lastmod>${date}</lastmod><changefreq>monthly</changefreq><priority>0.7</priority></url>"
        done
        
        echo '</urlset>'
    } > public/sitemap.xml
    
    echo "✅ Sitemap generated"
}

# Generate RSS feed
generate_rss() {
    echo "📡 Generating RSS feed..."
    
    local recent_posts=($(find content -name "*.md" | sort -t- -k2,2nr -k3,3nr -k4,4nr | head -20))
    local build_date=$(date -R)
    
    {
        cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
<title>${SITE_TITLE}</title>
<link>${BASE_URL}</link>
<description>High-performance blog with ${TOTAL_POSTS:-0} posts</description>
<lastBuildDate>${build_date}</lastBuildDate>
<atom:link href="${BASE_URL}/rss.xml" rel="self" type="application/rss+xml"/>
EOF
        
        for file in "${recent_posts[@]}"; do
            if [ -f "$file" ]; then
                local metadata=$(extract_metadata "$file")
                local title=$(echo "$metadata" | cut -d'|' -f1)
                local date=$(echo "$metadata" | cut -d'|' -f2)
                local excerpt=$(echo "$metadata" | cut -d'|' -f3)
                local slug=$(echo "$metadata" | cut -d'|' -f4)
                local num=$(echo "$slug" | grep -o '[0-9]\+$' || echo "1")
                local pub_date=$(date -d "$(echo "$date" | tr / -)" -R 2>/dev/null || echo "$build_date")
                
                cat << EOF
<item>
<title>${title}</title>
<link>${BASE_URL}/p/${num}.html</link>
<description>${excerpt}...</description>
<pubDate>${pub_date}</pubDate>
<guid>${BASE_URL}/p/${num}.html</guid>
</item>
EOF
            fi
        done
        
        echo '</channel></rss>'
    } > public/rss.xml
    
    echo "✅ RSS feed generated"
}

# Main execution
main() {
    local command="${1:-build}"
    
    case "$command" in
        "process_chunk")
            process_chunk
            ;;
        "generate_index")
            generate_index
            ;;
        "generate_archive")
            generate_archive
            ;;
        "generate_sitemap")
            generate_sitemap
            ;;
        "generate_rss")
            generate_rss
            ;;
        "build"|*)
            echo "🚀 Starting full build..."
            rm -rf public
            mkdir -p public/p public/archive
            
            # Process all posts
            local all_files=($(find content -name "*.md" | sort))
            export TOTAL_POSTS=${#all_files[@]}
            
            echo "📊 Processing ${TOTAL_POSTS} posts..."
            
            # Process posts in parallel
            printf '%s\n' "${all_files[@]}" | parallel -j "$PARALLEL_JOBS" --will-cite process_single_post {}
            
            # Generate pages
            generate_index
            generate_archive
            generate_sitemap
            generate_rss
            
            echo "✅ Build completed: ${TOTAL_POSTS} posts processed"
            ;;
    esac
}

# Export functions for parallel execution
export -f process_single_post process_markdown_fast extract_metadata
export SITE_TITLE BASE_URL POST_CSS MAIN_CSS ARCHIVE_CSS

# Run main function
main "$@"
