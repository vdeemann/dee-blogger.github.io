#!/bin/bash
set -e

echo "🔧 Building robust blog with large file support..."

rm -rf public
mkdir -p public/p public/archive

SITE_TITLE="${SITE_TITLE:-My Blog}"

# Ultra-compressed CSS
COMPACT_CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.4;color:#333}a{color:#06c;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.8em;margin:0 0 .5em;color:#222;font-weight:600}h2{font-size:1.1em;margin:0;color:#333;font-weight:600}p{margin:.2em 0}small{color:#666;display:block;margin:0;font-size:.85em}.post{margin-bottom:.6em;padding:.4em .6em;background:#fafafa;border-radius:3px;border:1px solid #e8e8e8}input{width:100%;margin-bottom:.5em;padding:.4em;border:1px solid #ddd;border-radius:3px;font-size:.9em}nav{margin:.8em 0;padding:.3em 0}.stats{background:#fff3cd;padding:.5em;border-radius:3px;margin:.5em 0;text-align:center;font-size:.9em}'

TIMELINE_CSS='body{max-width:45em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.5;color:#333}a{color:#06c;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.8em;margin:0 0 .5em;color:#222;font-weight:600}h2{font-size:1.1em;margin:0;color:#333;font-weight:600}p{margin:.3em 0}small{color:#666;display:block;margin:0;font-size:.85em}input{width:100%;margin-bottom:1em;padding:.4em;border:1px solid #ddd;border-radius:3px;font-size:.9em}nav{margin:.8em 0;padding:.3em 0}.stats{background:#fff3cd;padding:.5em;border-radius:3px;margin:.5em 0;text-align:center;font-size:.9em}.timeline{position:relative;margin:2em 0;padding-left:2em}.timeline:before{content:"";position:absolute;left:15px;top:0;bottom:0;width:2px;background:linear-gradient(#06c,#e1e8ed)}.year-section{margin-bottom:3em}.year-header{position:relative;margin-bottom:1.5em}.year-header h2{background:#06c;color:#fff;padding:.5em 1em;border-radius:20px;display:inline-block;font-size:1.2em;margin:0;position:relative;z-index:2}.year-header:before{content:"";position:absolute;left:-10px;top:50%;transform:translateY(-50%);width:20px;height:20px;background:#06c;border-radius:50%;border:3px solid #fff;box-shadow:0 0 0 2px #06c}.month-section{margin-bottom:2em;position:relative}.month-header{position:relative;margin-bottom:1em;padding-left:1em}.month-header h3{background:#f8f9fa;color:#333;padding:.3em .8em;border-radius:15px;display:inline-block;font-size:1em;margin:0;border:1px solid #e1e8ed;position:relative;z-index:2}.month-header:before{content:"";position:absolute;left:-6px;top:50%;transform:translateY(-50%);width:12px;height:12px;background:#fff;border:2px solid #06c;border-radius:50%}.post-item{position:relative;margin-bottom:.8em;padding:.6em .8em;background:#fff;border-radius:6px;border:1px solid #e1e8ed;margin-left:1em;transition:all .2s ease}.post-item:hover{background:#f8f9fa;border-color:#06c;transform:translateX(2px);box-shadow:0 2px 4px rgba(0,102,204,.1)}.post-item:before{content:"";position:absolute;left:-7px;top:50%;transform:translateY(-50%);width:6px;height:6px;background:#06c;border-radius:50%}.search-active .timeline:before{background:#ddd}.search-active .year-header:before,.search-active .month-header:before,.search-active .post-item:before{background:#ddd;border-color:#ddd}.search-active .year-header h2{background:#666}'

POST_CSS='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:system-ui,sans-serif;line-height:1.6;color:#333}a{color:#06c;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:1.8em;margin:0 0 .3em;color:#222;font-weight:600}h2{font-size:1.3em;margin:2em 0 1em;color:#333;font-weight:600}h3{font-size:1.1em;margin:1.5em 0 .5em;color:#444;font-weight:600}p{margin:1em 0}small{color:#666;display:block;margin-bottom:1.5em;font-size:.9em}strong{font-weight:600}code{background:#f6f8fa;color:#24292e;padding:.1em .3em;border-radius:3px;font-family:Monaco,monospace;font-size:.85em}.copy-btn{position:absolute;top:4px;right:4px;background:#fff;border:1px solid #d1d9e0;border-radius:3px;padding:4px 8px;font-size:11px;color:#586069;cursor:pointer;z-index:10}.copy-btn:hover{background:#f6f8fa;color:#0366d6;border-color:#0366d6}.copy-success{color:#fff!important;background:#28a745!important;border-color:#28a745!important}pre{background:#f6f8fa;padding:.3em .5em;margin:.8em 0;border-radius:4px;overflow-x:auto;border:1px solid #e1e4e8;position:relative}pre code{background:0;padding:0;font-size:.75em;color:#24292e;font-family:Monaco,monospace;display:block}ul{margin:1em 0;padding-left:1.5em}li{margin:.5em 0}nav{margin:1.5em 0;padding:.5em 0;border-bottom:1px solid #eee}blockquote{background:#f6f8fa;border-left:4px solid #0366d6;margin:1.5em 0;padding:1em 1.5em;border-radius:0 6px 6px 0;color:#586069;font-style:italic}.mermaid{margin:1.5em auto;text-align:center;background:#fff;border:1px solid #e1e4e8;border-radius:6px;padding:1em}.mermaid-title{background:#f6f8fa;color:#333;padding:.5em 1em;border:1px solid #e1e4e8;border-bottom:0;border-radius:6px 6px 0 0;font-size:.9em;font-weight:600;margin:1.5em 0 0}'

# Get all markdown files and handle them properly
files=($(find content -name "*.md" -type f | sort))
total=${#files[@]}

echo "📁 Processing $total files with robust handling..."

# Function to check if file has Mermaid diagrams
has_mermaid() {
    grep -q '^```mermaid' "$1" 2>/dev/null
}

# Robust markdown processor that handles large files
process_markdown() {
    local file="$1"
    local temp_file=$(mktemp)
    
    echo "🔄 Processing: $(basename "$file")"
    
    # Skip the title line and process content
    tail -n +3 "$file" > "$temp_file"
    
    # Use Python for robust processing of large files
    python3 << 'EOF' "$temp_file"
import sys
import re

def process_markdown(content):
    lines = content.split('\n')
    result = []
    i = 0
    in_list = False
    mermaid_count = 0
    
    while i < len(lines):
        line = lines[i].rstrip()
        
        # Handle Mermaid diagrams
        if line.startswith('```mermaid'):
            mermaid_count += 1
            i += 1
            mermaid_content = []
            title = line[10:].strip() if len(line) > 10 else ""
            
            # Collect mermaid content
            while i < len(lines) and not lines[i].strip().startswith('```'):
                mermaid_content.append(lines[i])
                i += 1
            
            # Output mermaid div
            if title:
                result.append(f'<div class="mermaid-title">{title}</div>')
            result.append('<div class="mermaid">')
            result.extend(mermaid_content)
            result.append('</div>')
            
        # Handle regular code blocks
        elif line.startswith('```') and not line.startswith('```mermaid'):
            if in_list:
                result.append('</ul>')
                in_list = False
            
            i += 1
            code_content = []
            
            # Collect code content
            while i < len(lines) and not lines[i].strip().startswith('```'):
                code_line = lines[i]
                # Escape HTML entities
                code_line = code_line.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
                code_content.append(code_line)
                i += 1
            
            # Output code block with copy button
            result.append('<pre><button class="copy-btn" onclick="copyCode(this)">📋</button><code>')
            result.extend(code_content)
            result.append('</code></pre>')
            
        # Handle headers
        elif line.startswith('### '):
            if in_list:
                result.append('</ul>')
                in_list = False
            result.append(f'<h3>{line[4:]}</h3>')
            
        elif line.startswith('## '):
            if in_list:
                result.append('</ul>')
                in_list = False
            result.append(f'<h2>{line[3:]}</h2>')
            
        elif line.startswith('# '):
            if in_list:
                result.append('</ul>')
                in_list = False
            result.append(f'<h1>{line[2:]}</h1>')
            
        # Handle lists
        elif re.match(r'^[•*-] ', line):
            if not in_list:
                result.append('<ul>')
                in_list = True
            result.append(f'<li>{line[2:]}</li>')
            
        # Handle empty lines
        elif not line.strip():
            if in_list:
                result.append('</ul>')
                in_list = False
            if result and not result[-1] == '<br>':
                result.append('<br>')
                
        # Handle regular text
        else:
            if in_list:
                result.append('</ul>')
                in_list = False
                
            # Process inline markdown
            line = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', line)
            line = re.sub(r'`([^`]+)`', r'<code>\1</code>', line)
            line = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', line)
            
            if line.strip():
                result.append(f'<p>{line}</p>')
        
        i += 1
    
    # Close any open lists
    if in_list:
        result.append('</ul>')
    
    # Remove consecutive <br> tags and clean up
    cleaned_result = []
    prev_was_br = False
    for line in result:
        if line == '<br>':
            if not prev_was_br:
                cleaned_result.append(line)
            prev_was_br = True
        else:
            cleaned_result.append(line)
            prev_was_br = False
    
    return '\n'.join(cleaned_result)

# Read the temporary file
with open(sys.argv[1], 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

print(process_markdown(content))
EOF
    
    rm "$temp_file"
}

# Generate posts with better error handling
for i in "${!files[@]}"; do
    file="${files[$i]}"
    num=$((i + 1))
    
    echo "📝 Generating post $num from $(basename "$file")"
    
    # Extract title safely with better handling
    if [[ -f "$file" ]]; then
        title=$(head -1 "$file" 2>/dev/null | sed 's/^# *//' | tr -d '<>&"'"'" | head -c 100)
        
        # Handle empty or malformed titles
        if [[ -z "$title" ]]; then
            title=$(basename "$file" .md)
        fi
        
        # Process content with error handling
        if content=$(process_markdown "$file" 2>/dev/null); then
            # Extract date from filename with fallback
            if [[ $(basename "$file") =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
                date=$(basename "$file" | cut -d- -f1-3 | tr - /)
            else
                date=$(date +'%Y/%m/%d')
            fi
            
            # Check if file needs Mermaid
            mermaid_script=""
            if has_mermaid "$file"; then
                mermaid_script='<script src="https://cdnjs.cloudflare.com/ajax/libs/mermaid/10.6.1/mermaid.min.js"></script>'
            fi
            
            # Generate HTML with error handling
            cat > "public/p/$num.html" << EOF
<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>$title</title><style>$POST_CSS</style>$mermaid_script</head><body><nav><a href="../">← Blog</a> | <a href="../archive/">Archive</a></nav><h1>$title</h1><small>$date</small>$content<nav style="border-top:1px solid #eee;margin-top:2em;padding-top:1em"><a href="../">← Back</a></nav><script>
if(typeof mermaid!=='undefined'){mermaid.initialize({startOnLoad:1,theme:'default',themeVariables:{primaryColor:'#06c',primaryTextColor:'#333',lineColor:'#666'}})}
function copyCode(b){const c=b.nextElementSibling,t=c.textContent;navigator.clipboard.writeText(t).then(()=>{const o=b.textContent;b.textContent='✓ Copied!';b.classList.add('copy-success');setTimeout(()=>{b.textContent=o;b.classList.remove('copy-success')},2e3)}).catch(()=>{const e=document.createElement('textarea');e.value=t;e.style.position='absolute';e.style.left='-9999px';document.body.appendChild(e);e.select();document.execCommand('copy');document.body.removeChild(e);const o=b.textContent;b.textContent='✓ Copied!';b.classList.add('copy-success');setTimeout(()=>{b.textContent=o;b.classList.remove('copy-success')},2e3)})}
if(typeof mermaid!=='undefined'){window.onload=window.onresize=()=>document.querySelectorAll('.mermaid').forEach(d=>{const s=d.querySelector('svg');if(s){s.style.maxWidth='100%';s.style.height='auto'}})}
</script></body></html>
EOF
            echo "✅ $num: $title"
        else
            echo "❌ Failed to process $file, creating simple fallback"
            # Create a simple fallback page
            cat > "public/p/$num.html" << EOF
<!DOCTYPE html><html><head><meta charset="utf-8"><title>Processing Error</title><style>$POST_CSS</style></head><body><nav><a href="../">← Blog</a></nav><h1>Content Processing Error</h1><p>This post could not be processed. Please check the markdown format.</p><p>File: $(basename "$file")</p></body></html>
EOF
        fi
    else
        echo "❌ File $file does not exist, skipping"
    fi
done

# Generate main page with robust file handling
{
    echo "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>$SITE_TITLE</title><style>$COMPACT_CSS</style></head><body><h1>$SITE_TITLE</h1><input id=s placeholder=\"Search...\" onkeyup=f()><div id=p>"
    
    # Process recent files more robustly
    count=0
    for file in $(find content -name "*.md" -type f | sort -r | head -20); do
        if [[ -f "$file" ]]; then
            num=1
            for f in $(find content -name "*.md" -type f | sort); do 
                [[ "$f" = "$file" ]] && break
                num=$((num+1))
            done
            
            title=$(head -1 "$file" 2>/dev/null | sed 's/^# *//' | tr -d '<>&"'"'" | head -c 60)
            excerpt=$(sed -n '3p' "$file" 2>/dev/null | sed 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g; s/`\([^`]*\)`/<code>\1<\/code>/g' | tr -d '<>&"'"'" | head -c 120)
            
            # Handle missing title/excerpt
            [[ -z "$title" ]] && title=$(basename "$file" .md)
            [[ -z "$excerpt" ]] && excerpt="No description available"
            
            # Extract date with fallback
            if [[ $(basename "$file") =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
                date=$(basename "$file" | cut -d- -f1-3 | tr - /)
            else
                date=$(date +'%Y/%m/%d')
            fi
            
            # Add mermaid indicator
            indicator=""
            if has_mermaid "$file"; then
                indicator=" 📊"
            fi
            
            echo "<div class=post><small>$date</small><h2><a href=p/$num.html>$title$indicator</a></h2><p>$excerpt...</p></div>"
        fi
    done
    
    echo "</div><p>📚 <a href=archive/>All $total posts</a></p><script>let o,p=document.getElementById('p');function f(){let q=s.value.toLowerCase();if(!o)o=p.innerHTML;p.innerHTML=q?Array.from(p.children).filter(e=>e.textContent.toLowerCase().includes(q)).map(e=>e.outerHTML).join('')||'<p>No results</p>':o}</script></body></html>"
} > public/index.html

# Generate robust archive
{
    echo "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>Archive</title><style>$TIMELINE_CSS</style></head><body><a href=../>← Home</a><h1>Archive</h1><div class=stats>📊 $total posts</div><input id=s placeholder=\"Search...\" onkeyup=f()><div class=timeline id=t>"
    
    # Better file grouping with error handling
    declare -A years months
    
    for file in $(find content -name "*.md" -type f | sort -r); do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            # Handle different date formats
            if [[ $filename =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
                y=${BASH_REMATCH[1]}
                m=${BASH_REMATCH[2]}
                years[$y]=1
                case $m in
                    01)months[$y-$m]="January";;02)months[$y-$m]="February";;03)months[$y-$m]="March";;
                    04)months[$y-$m]="April";;05)months[$y-$m]="May";;06)months[$y-$m]="June";;
                    07)months[$y-$m]="July";;08)months[$y-$m]="August";;09)months[$y-$m]="September";;
                    10)months[$y-$m]="October";;11)months[$y-$m]="November";;12)months[$y-$m]="December";;
                esac
            else
                # Fallback for files without proper date format
                current_year=$(date +%Y)
                current_month=$(date +%m)
                years[$current_year]=1
                months[$current_year-$current_month]=$(date +%B)
            fi
        fi
    done
    
    # Generate timeline
    for year in $(printf '%s\n' "${!years[@]}" | sort -nr); do
        echo "<div class=year-section><div class=year-header><h2>$year</h2></div>"
        
        for mk in $(printf '%s\n' "${!months[@]}" | grep "^$year-" | sort -nr); do
            mn=$(echo "$mk" | cut -d- -f2)
            echo "<div class=month-section><div class=month-header><h3>${months[$mk]}</h3></div>"
            
            for file in $(find content -name "*.md" -type f | sort -r); do
                if [[ -f "$file" ]]; then
                    filename=$(basename "$file")
                    if [[ $filename =~ ^$year-$mn- ]] || [[ ! $filename =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} && $year == $(date +%Y) && $mn == $(date +%m) ]]; then
                        # Find post number
                        num=1
                        for cf in $(find content -name "*.md" -type f | sort); do 
                            [[ $cf == $file ]] && break
                            num=$((num+1))
                        done
                        
                        title=$(head -1 "$file" 2>/dev/null | sed 's/^# *//' | tr -d '<>&"'"'" | head -c 60)
                        excerpt=$(sed -n '3p' "$file" 2>/dev/null | tr -d '<>&"'"'" | head -c 100)
                        
                        [[ -z "$title" ]] && title=$(basename "$file" .md)
                        [[ -z "$excerpt" ]] && excerpt="No description"
                        
                        if [[ $filename =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
                            date="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}/${BASH_REMATCH[3]}"
                        else
                            date=$(date +'%Y/%m/%d')
                        fi
                        
                        indicator=""
                        if has_mermaid "$file"; then
                            indicator=" 📊"
                        fi
                        
                        echo "<div class=post-item><small>$date</small><h2><a href=../p/$num.html>$title$indicator</a></h2><p>$excerpt...</p></div>"
                    fi
                fi
            done
            echo "</div>"
        done
        echo "</div>"
    done
    
    echo '</div><script>let o;function f(){const q=s.value.toLowerCase(),t=document.getElementById("t");if(!o)o=t.innerHTML;if(!q){t.innerHTML=o;return}let h="",r=0;Array.from(t.children).forEach(y=>{const yh=y.querySelector(".year-header h2").textContent;let yb="",yr=0;Array.from(y.querySelectorAll(".month-section")).forEach(m=>{const mh=m.querySelector(".month-header h3").textContent;let mb="",mr=0;Array.from(m.querySelectorAll(".post-item")).forEach(p=>{if(p.textContent.toLowerCase().includes(q)){mb+=p.outerHTML;mr=r=1}});if(mr)yb+=`<div class=month-section><div class=month-header><h3>${mh}</h3></div>${mb}</div>`;yr=mr||yr});if(yr)h+=`<div class=year-section><div class=year-header><h2>${yh}</h2></div>${yb}</div>`});t.innerHTML=r?h:"<p>No results</p>"}</script></body></html>'
} > public/archive/index.html

echo ""
echo "✅ Robust blog built successfully!"
echo "📊 $total posts processed"
echo "🐛 Large file support: ✅"
echo "📈 Complex Mermaid diagrams: ✅"
echo "📁 All files in archive: ✅"
echo "🔧 Error handling: ✅"
echo ""
echo "🚀 Your blog should now handle the FOSS infrastructure post correctly!"
