#!/bin/sh
set -e
d=public
rm -rf $d; mkdir -p $d/p $d/a
c='body{max-width:40em;margin:2em auto;padding:0 1em;font-family:sans-serif;line-height:1.5;color:#333}a{color:#06c;text-decoration:none}a:hover{text-decoration:underline}h1{font-size:2em}h2{font-size:1.4em;margin:1.5em 0 .5em}pre,code{background:#f6f8fa}input{width:100%%;box-sizing:border-box;padding:.4em;margin:1em 0}'
j='let o,p=document.getElementById("p");function f(){let q=s.value.toLowerCase();p.innerHTML=q?(o||(o=p.innerHTML),Array.from(p.children).filter(c=>c.textContent.toLowerCase().includes(q)).map(c=>c.outerHTML).join("")):o}'

ls content/*.md | sort >files.txt
n=$(wc -l < files.txt)

postlist=""
archivelist=""

i=0
while IFS= read -r f; do
  i=$((i+1))
  s=$(basename "$f" .md)
  IFS='
' read t _ x < "$f"
  t=${t#\# }
  dte="${s%%-*}/${s#*-}"; dte="${dte%-*}/${dte##*-}"
  x=${x//[<>&\"\']}
  # Markdown to HTML
  body=$(tail -n +3 "$f" | awk '
    BEGIN{il=0}
    /^#{1,3} /{n=index($0," ");h=n-1;print"<h"h">"substr($0,n+1)"</h"h">";next}
    /^[*-] /{if(!il){print"<ul>";il=1}print"<li>"substr($0,3)"</li>";next}
    /^$/ {if(il){print"</ul>";il=0}next}
    /./{
      gsub(/\*\*([^*]+)\*\*/,"<strong>\\1</strong>")
      gsub(/`([^`]+)`/,"<code>\\1</code>")
      gsub(/\[([^\]]+)\]\(([^)]+)\)/,"<a href=\"\\2\">\\1</a>")
      print"<p>"$0"</p>"
    }
    END{if(il)print"</ul>"}
  ')
  # Write post page
  printf '<!DOCTYPE html><html><head><meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1"><title>%s</title><style>%s</style></head><body><a href=../>←</a><h1>%s</h1><small>%s</small><div>%s</div></body></html>' "$t" "$c" "$t" "$dte" "$body" > $d/p/$s.html
  # Save to post list for index and archive (recent 20 only for index)
  [ $i -gt $((n-20)) ] && postlist="$postlist<div><small>$dte</small><h2><a href=p/$s.html>$t</a></h2><p>${x}...</p></div>"
  archivelist="<div><small>$dte</small><a href=../p/$s.html>$t</a></div>$archivelist"
done < files.txt

# Index
printf '<!DOCTYPE html><html><head><meta charset=utf-8><title>My Blog</title><style>%s</style></head><body><h1>My Blog</h1><input id=s placeholder=Search... onkeyup=f()><div id=p>%s</div><p><a href=a/>All posts</a></p><script>%s</script></body></html>' "$c" "$postlist" "$j" > $d/index.html

# Archive
printf '<!DOCTYPE html><html><head><meta charset=utf-8><title>Archive</title><style>%s</style></head><body><a href=../>←</a><h1>Archive</h1><div>%s</div></body></html>' "$c" "$archivelist" > $d/a/index.html

rm files.txt
