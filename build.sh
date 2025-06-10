#!/bin/bash
set -e

echo "🚀 Building dee-blogger with modern features..."

# Configuration
SITE_TITLE="dee-blogger"
CONTENT_DIR="content"
MAX_POSTS_MAIN=20

# Clean and create directories
echo "ℹ️ Setting up directories..."
rm -rf public
mkdir -p public/p public/archive public/assets/js public/assets/css

# Create enhanced CSS with proper spacing and code formatting
echo "ℹ️ Creating enhanced CSS..."
cat > public/assets/css/style.css << 'EOF'
:root {
  --bg-primary: #ffffff;
  --bg-secondary: #f8f9fa;
  --bg-code: #f6f8fa;
  --text-primary: #24292f;
  --text-secondary: #656d76;
  --text-muted: #8b949e;
  --border-color: #d0d7de;
  --border-muted: #e8e8e8;
  --accent-color: #0969da;
  --accent-hover: #0550ae;
  --success-color: #28a745;
  --warning-color: #ffc107;
  --danger-color: #dc3545;
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.12);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 15px rgba(0,0,0,0.1);
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
}

[data-theme="dark"] {
  --bg-primary: #0d1117;
  --bg-secondary: #161b22;
  --bg-code: #21262d;
  --text-primary: #f0f6fc;
  --text-secondary: #8b949e;
  --text-muted: #6e7681;
  --border-color: #30363d;
  --border-muted: #21262d;
}

* {
  box-sizing: border-box;
}

body {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans", Helvetica, Arial, sans-serif;
  line-height: 1.6;
  color: var(--text-primary);
  background: var(--bg-primary);
  font-size: 16px;
}

/* Typography */
h1, h2, h3, h4, h5, h6 {
  margin: 2em 0 1em 0;
  font-weight: 600;
  line-height: 1.25;
  color: var(--text-primary);
}

h1 { font-size: 2.5em; margin-top: 0; }
h2 { font-size: 2em; border-bottom: 1px solid var(--border-muted); padding-bottom: 0.3em; }
h3 { font-size: 1.5em; }
h4 { font-size: 1.25em; }
h5 { font-size: 1.1em; }
h6 { font-size: 1em; }

p {
  margin: 1em 0;
  line-height: 1.7;
}

a {
  color: var(--accent-color);
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
  color: var(--accent-hover);
}

/* Header */
.site-header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: var(--bg-primary);
  border-bottom: 1px solid var(--border-color);
  padding: 1rem 0;
  margin: 0 -2rem 2rem -2rem;
  padding-left: 2rem;
  padding-right: 2rem;
  backdrop-filter: blur(10px);
}

.site-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.theme-toggle {
  background: none;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  padding: 0.5rem;
  cursor: pointer;
  color: var(--text-primary);
  font-size: 1.2rem;
}

.theme-toggle:hover {
  background: var(--bg-secondary);
}

/* Stats */
.stats {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 1.5rem 2rem;
  border-radius: var(--radius-lg);
  margin: 2rem 0;
  text-align: center;
  font-weight: 600;
  font-size: 1.1rem;
  box-shadow: var(--shadow-md);
}

/* Search */
.search-container {
  position: relative;
  margin: 2rem 0;
}

input[type="search"] {
  width: 100%;
  padding: 1rem 3rem 1rem 1rem;
  border: 2px solid var(--border-color);
  border-radius: var(--radius-md);
  font-size: 1rem;
  background: var(--bg-secondary);
  color: var(--text-primary);
  transition: all 0.2s ease;
}

input[type="search"]:focus {
  outline: none;
  border-color: var(--accent-color);
  box-shadow: 0 0 0 3px rgba(9, 105, 218, 0.1);
}

.search-icon {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-muted);
}

.search-results {
  background: var(--bg-secondary);
  padding: 1rem 1.5rem;
  border-radius: var(--radius-md);
  margin: 1rem 0;
  border-left: 4px solid var(--accent-color);
  font-weight: 500;
}

.search-highlight {
  background: #ffeb3b;
  padding: 0 0.3em;
  border-radius: var(--radius-sm);
  color: #000;
}

/* Posts */
.post {
  margin: 0 0 2rem;
  padding: 2rem;
  background: var(--bg-secondary);
  border-radius: var(--radius-lg);
  border: 1px solid var(--border-color);
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.post::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 100%;
  background: var(--accent-color);
  transform: scaleY(0);
  transition: transform 0.3s ease;
}

.post:hover {
  background: var(--bg-primary);
  border-color: var(--accent-color);
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}

.post:hover::before {
  transform: scaleY(1);
}

.post-meta {
  color: var(--text-muted);
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

.post-title {
  font-size: 1.5rem;
  margin: 0.5rem 0;
  font-weight: 600;
  color: var(--text-primary);
}

.post-excerpt {
  color: var(--text-secondary);
  margin: 1rem 0 0;
  line-height: 1.6;
}

/* Code blocks */
pre {
  position: relative;
  background: var(--bg-code);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 1.5rem;
  margin: 2rem 0;
  overflow-x: auto;
  font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
  font-size: 0.9rem;
  line-height: 1.5;
}

code {
  background: var(--bg-code);
  color: #e36209;
  padding: 0.2em 0.4em;
  border-radius: var(--radius-sm);
  font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
  font-size: 0.9em;
  border: 1px solid var(--border-color);
}

pre code {
  background: none;
  border: none;
  padding: 0;
  color: var(--text-primary);
}

.code-header {
  display: flex;
  justify-content: between;
  align-items: center;
  padding: 0.5rem 1rem;
  background: var(--border-color);
  border-radius: var(--radius-md) var(--radius-md) 0 0;
  font-size: 0.8rem;
  color: var(--text-muted);
  margin: 0;
}

.copy-button {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  padding: 0.5rem;
  cursor: pointer;
  opacity: 0;
  transition: all 0.2s ease;
  font-size: 0.8rem;
}

pre:hover .copy-button {
  opacity: 1;
}

.copy-button:hover {
  background: var(--accent-color);
  color: white;
  border-color: var(--accent-color);
}

.copy-button.copied {
  background: var(--success-color);
  color: white;
  border-color: var(--success-color);
}

/* Blockquotes */
blockquote {
  margin: 2rem 0;
  padding: 1rem 1.5rem;
  background: var(--bg-code);
  border-left: 4px solid var(--accent-color);
  border-radius: 0 var(--radius-md) var(--radius-md) 0;
  color: var(--text-secondary);
  font-style: italic;
}

/* Lists */
ul, ol {
  margin: 1.5rem 0;
  padding-left: 2rem;
}

li {
  margin: 0.5rem 0;
  line-height: 1.6;
}

/* Tables */
table {
  width: 100%;
  border-collapse: collapse;
  margin: 2rem 0;
  background: var(--bg-secondary);
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

th, td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid var(--border-color);
}

th {
  background: var(--bg-code);
  font-weight: 600;
  color: var(--text-primary);
}

tr:hover {
  background: var(--bg-primary);
}

/* Archive */
.year-section {
  margin: 0 0 3rem;
}

.month-section {
  margin: 0 0 2rem;
}

.year-header h2 {
  color: var(--accent-color);
  border-bottom: 2px solid var(--accent-color);
  padding-bottom: 0.5rem;
}

.month-header h3 {
  color: var(--text-secondary);
  margin: 0 0 1rem;
  font-size: 1.2rem;
}

/* Navigation */
nav {
  margin: 2rem 0;
  padding: 1rem 0;
  border-top: 1px solid var(--border-color);
  border-bottom: 1px solid var(--border-color);
}

nav a {
  display: inline-block;
  padding: 0.5rem 1rem;
  margin: 0 0.5rem 0 0;
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  text-decoration: none;
  transition: all 0.2s ease;
}

nav a:hover {
  background: var(--accent-color);
  color: white;
  border-color: var(--accent-color);
  text-decoration: none;
}

/* Utilities */
.no-results {
  text-align: center;
  color: var(--text-muted);
  padding: 4rem 2rem;
  font-style: italic;
  font-size: 1.1rem;
}

.loading {
  text-align: center;
  padding: 2rem;
  color: var(--text-muted);
}

/* Responsive */
@media (max-width: 768px) {
  body {
    padding: 0 1rem;
  }
  
  .site-header {
    margin: 0 -1rem 1rem -1rem;
    padding-left: 1rem;
    padding-right: 1rem;
  }
  
  .post {
    padding: 1.5rem;
  }
  
  h1 { font-size: 2rem; }
  h2 { font-size: 1.5rem; }
  h3 { font-size: 1.25rem; }
  
  pre {
    padding: 1rem;
    font-size: 0.8rem;
  }
}

/* Mermaid diagrams */
.mermaid {
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 2rem;
  margin: 2rem 0;
  text-align: center;
}

/* Print styles */
@media print {
  .site-header,
  .search-container,
  .copy-button,
  .theme-toggle {
    display: none;
  }
  
  body {
    font-size: 12pt;
    line-height: 1.4;
  }
  
  .post {
    break-inside: avoid;
    box-shadow: none;
    border: 1px solid #ccc;
  }
}
EOF

# Create enhanced JavaScript with modern features
echo "ℹ️ Creating enhanced JavaScript..."
cat > public/assets/js/app.js << 'EOF'
// Search functionality
let originalPosts = null;
let searchTimeout = null;

function initializeSearch() {
    const searchInput = document.getElementById('search');
    const postsContainer = document.getElementById('posts');
    const searchInfo = document.getElementById('search-info');
    const searchCount = document.getElementById('search-count');
    
    if (!searchInput) return;
    
    // Store original content
    if (originalPosts === null) {
        originalPosts = postsContainer.innerHTML;
    }
    
    searchInput.addEventListener('input', function(e) {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => searchPosts(), 300);
    });
    
    searchInput.addEventListener('keyup', function(e) {
        if (e.key === 'Escape') {
            searchInput.value = '';
            searchPosts();
            searchInput.blur();
        }
    });
}

function searchPosts() {
    const searchInput = document.getElementById('search');
    const postsContainer = document.getElementById('posts');
    const searchInfo = document.getElementById('search-info');
    const searchCount = document.getElementById('search-count');
    
    const query = searchInput.value.toLowerCase().trim();
    
    if (query === '' || query.length === 0) {
        postsContainer.innerHTML = originalPosts;
        if (searchInfo) searchInfo.style.display = 'none';
        return;
    }
    
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = originalPosts;
    const allPosts = Array.from(tempDiv.children);
    
    const filtered = allPosts.filter(post => {
        const searchable = post.dataset.searchable || '';
        return searchable.includes(query);
    });
    
    if (filtered.length > 0) {
        const highlightedResults = filtered.map(post => {
            let html = post.outerHTML;
            const escapedQuery = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            const regex = new RegExp('(' + escapedQuery + ')', 'gi');
            html = html.replace(regex, '<span class="search-highlight">$1</span>');
            return html;
        }).join('');
        
        postsContainer.innerHTML = highlightedResults;
        
        // Reattach event listeners to new posts
        attachPostClickHandlers();
    } else {
        postsContainer.innerHTML = '<div class="no-results">No posts found matching "' + escapeHtml(query) + '"</div>';
    }
    
    if (searchCount) searchCount.textContent = filtered.length;
    if (searchInfo) searchInfo.style.display = 'block';
}

// Theme toggle functionality
function initializeThemeToggle() {
    const themeToggle = document.getElementById('theme-toggle');
    if (!themeToggle) return;
    
    // Check for saved theme or default to light
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
    updateThemeToggleIcon(savedTheme);
    
    themeToggle.addEventListener('click', function() {
        const currentTheme = document.documentElement.getAttribute('data-theme');
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        
        document.documentElement.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
        updateThemeToggleIcon(newTheme);
    });
}

function updateThemeToggleIcon(theme) {
    const themeToggle = document.getElementById('theme-toggle');
    if (!themeToggle) return;
    
    themeToggle.innerHTML = theme === 'dark' ? '☀️' : '🌙';
    themeToggle.title = `Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`;
}

// Copy to clipboard functionality
function initializeCopyButtons() {
    document.querySelectorAll('pre').forEach(pre => {
        const button = document.createElement('button');
        button.className = 'copy-button';
        button.innerHTML = '📋 Copy';
        button.setAttribute('aria-label', 'Copy code to clipboard');
        
        button.addEventListener('click', async function() {
            const code = pre.querySelector('code');
            const text = code ? code.textContent : pre.textContent;
            
            try {
                await navigator.clipboard.writeText(text);
                button.innerHTML = '✓ Copied';
                button.classList.add('copied');
                
                setTimeout(() => {
                    button.innerHTML = '📋 Copy';
                    button.classList.remove('copied');
                }, 2000);
            } catch (err) {
                // Fallback for older browsers
                const textArea = document.createElement('textarea');
                textArea.value = text;
                document.body.appendChild(textArea);
                textArea.select();
                try {
                    document.execCommand('copy');
                    button.innerHTML = '✓ Copied';
                    button.classList.add('copied');
                    setTimeout(() => {
                        button.innerHTML = '📋 Copy';
                        button.classList.remove('copied');
                    }, 2000);
                } catch (err) {
                    button.innerHTML = '❌ Failed';
                    setTimeout(() => {
                        button.innerHTML = '📋 Copy';
                    }, 2000);
                }
                document.body.removeChild(textArea);
            }
        });
        
        pre.style.position = 'relative';
        pre.appendChild(button);
    });
}

// Post click handlers
function attachPostClickHandlers() {
    document.querySelectorAll('.post[onclick]').forEach(post => {
        post.addEventListener('click', function(e) {
            // Don't navigate if clicking on links or buttons
            if (e.target.tagName === 'A' || e.target.tagName === 'BUTTON') {
                return;
            }
            
            const onclick = this.getAttribute('onclick');
            if (onclick) {
                eval(onclick);
            }
        });
        
        // Remove inline onclick to avoid double handling
        post.removeAttribute('onclick');
    });
}

// Smooth scrolling for anchor links
function initializeSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// Progress indicator
function initializeProgressIndicator() {
    if (document.querySelector('article')) {
        const progressBar = document.createElement('div');
        progressBar.id = 'progress-bar';
        progressBar.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 0%;
            height: 3px;
            background: var(--accent-color);
            z-index: 1000;
            transition: width 0.2s ease;
        `;
        document.body.appendChild(progressBar);
        
        window.addEventListener('scroll', function() {
            const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
            const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
            const scrolled = (winScroll / height) * 100;
            progressBar.style.width = scrolled + '%';
        });
    }
}

// Utility functions
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeSearch();
    initializeThemeToggle();
    initializeCopyButtons();
    attachPostClickHandlers();
    initializeSmoothScrolling();
    initializeProgressIndicator();
    
    // Initialize Mermaid if available
    if (typeof mermaid !== 'undefined') {
        mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            securityLevel: 'loose'
        });
    }
    
    // Initialize Prism if available
    if (typeof Prism !== 'undefined') {
        Prism.highlightAll();
    }
});

// Service Worker for offline support
if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
        navigator.serviceWorker.register('/sw.js')
            .then(function(registration) {
                console.log('SW registered: ', registration);
            })
            .catch(function(registrationError) {
                console.log('SW registration failed: ', registrationError);
            });
    });
}
EOF

# Create Service Worker for offline support
cat > public/sw.js << 'EOF'
const CACHE_NAME = 'dee-blogger-v1';
const urlsToCache = [
  '/',
  '/assets/css/style.css',
  '/assets/js/app.js',
  '/archive/'
];

self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function(cache) {
        return cache.addAll(urlsToCache);
      })
  );
});

self.addEventListener('fetch', function(event) {
  event.respondWith(
    caches.match(event.request)
      .then(function(response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
    )
  );
});
EOF

# Helper functions for processing
extract_title_from_file() {
    local file="$1"
    local first_line=$(head -n1 "$file")
    local title=$(echo "$first_line" | sed 's/^# *//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    
    if [ -z "$title" ] || [ "$title" = "#" ]; then
        local filename=$(basename "$file" .md)
        if echo "$filename" | grep -q "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-"; then
            title=$(echo "$filename" | sed 's/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-//' | sed 's/-/ /g')
        else
            title=$(echo "$filename" | sed 's/-/ /g')
        fi
        title=$(echo "$title" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    fi
    
    echo "$title"
}

extract_post_number() {
    local file="$1"
    local filename=$(basename "$file" .md)
    echo "$filename" | cksum | cut -d' ' -f1
}

extract_date_from_filename() {
    local file="$1"
    local filename=$(basename "$file" .md)
    
    if echo "$filename" | grep -q "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-"; then
        local year=$(echo "$filename" | cut -d- -f1)
        local month=$(echo "$filename" | cut -d- -f2)
        local day=$(echo "$filename" | cut -d- -f3)
        echo "$year/$month/$day"
    else
        date '+%Y/%m/%d'
    fi
}

extract_sort_date() {
    local file="$1"
    local filename=$(basename "$file" .md)
    
    if echo "$filename" | grep -q "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-"; then
        local year=$(echo "$filename" | cut -d- -f1)
        local month=$(echo "$filename" | cut -d- -f2)
        local day=$(echo "$filename" | cut -d- -f3)
        echo "$year$month$day"
    else
        date '+%Y%m%d'
    fi
}

extract_excerpt() {
    local file="$1"
    local body_content=$(tail -n +2 "$file")
    local excerpt=$(echo "$body_content" | grep -v '^#' | grep -v '^$' | head -2 | tr '\n' ' ' | sed 's/[*`#\[\]()]/ /g' | sed 's/  */ /g' | cut -c1-150 | sed 's/[[:space:]]*$/.../')
    
    if [ -z "$excerpt" ]; then
        excerpt="Read more..."
    fi
    
    echo "$excerpt"
}

# Enhanced markdown processing with syntax highlighting and mermaid support
process_markdown_enhanced() {
    local file="$1"
    local content=$(tail -n +2 "$file")
    
    # Process the markdown with enhanced features
    echo "$content" | sed '
        # Handle code fences with language detection
        /^```/{
            s/^```\([a-zA-Z]*\).*/<pre><code class="language-\1">/
            :loop
            n
            /^```$/{
                s/.*/\<\/code\>\<\/pre\>/
                b
            }
            s/&/\&amp;/g
            s/</\&lt;/g
            s/>/\&gt;/g
            b loop
        }
        
        # Handle mermaid diagrams
        /^```mermaid/{
            s/.*/\<div class="mermaid"\>/
            :mermaid_loop
            n
            /^```$/{
                s/.*/\<\/div\>/
                b
            }
            b mermaid_loop
        }
        
        # Headers with anchor links
        s/^#### \(.*\)/<h4 id="\L\1\E">\1<\/h4>/
        s/^### \(.*\)/<h3 id="\L\1\E">\1<\/h3>/
        s/^## \(.*\)/<h2 id="\L\1\E">\1<\/h2>/
        s/^# \(.*\)/<h1 id="\L\1\E">\1<\/h1>/
        
        # Blockquotes
        s/^> \(.*\)/<blockquote><p>\1<\/p><\/blockquote>/
        
        # Bold and italic
        s/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g
        s/\*\([^*]*\)\*/<em>\1<\/em>/g
        
        # Inline code
        s/`\([^`]*\)`/<code>\1<\/code>/g
        
        # Links
        s/\[\([^]]*\)\](\([^)]*\))/<a href="\2">\1<\/a>/g
        
        # Remove empty lines
        /^[[:space:]]*$/d
        
        # Wrap non-HTML lines in paragraphs
        /^[^<]/s/^/<p>/
        /^<p>/s/$/<\/p>/
    '
}

get_month_name() {
    case "$1" in
        01) echo "January" ;;
        02) echo "February" ;;
        03) echo "March" ;;
        04) echo "April" ;;
        05) echo "May" ;;
        06) echo "June" ;;
        07) echo "July" ;;
        08) echo "August" ;;
        09) echo "September" ;;
        10) echo "October" ;;
        11) echo "November" ;;
        12) echo "December" ;;
        *) echo "Month" ;;
    esac
}

# Main processing
echo "ℹ️ Finding markdown files..."

if [ ! -d "$CONTENT_DIR" ]; then
    echo "❌ Content directory not found: $CONTENT_DIR"
    exit 1
fi

files=$(find "$CONTENT_DIR" -name "*.md" -type f | sort)
total=$(echo "$files" | wc -l)

if [ $total -eq 0 ]; then
    echo "❌ No markdown files found"
    exit 1
fi

echo "✅ Found $total markdown files"

# Process files
echo "ℹ️ Processing files..."

post_list_file="/tmp/post_list.txt"
post_data_file="/tmp/post_data.txt"

> "$post_list_file"
> "$post_data_file"

count=0
for file in $files; do
    count=$((count + 1))
    printf "\r🔄 Processing: %d/%d (%s)" "$count" "$total" "$(basename "$file")"
    
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        continue
    fi
    
    title=$(extract_title_from_file "$file")
    post_num=$(extract_post_number "$file")
    date_str=$(extract_date_from_filename "$file")
    sort_date=$(extract_sort_date "$file")
    excerpt=$(extract_excerpt "$file")
    
    if [ -z "$title" ]; then
        continue
    fi
    
    # Count words for reading time
    word_count=$(tail -n +2 "$file" | wc -w)
    reading_time=$(echo "$word_count / 200 + 1" | bc 2>/dev/null || echo "1")
    
    # Store data
    echo "$post_num|$title|$date_str|$sort_date|$excerpt|$file|$word_count|$reading_time" >> "$post_data_file"
    echo "$sort_date $post_num" >> "$post_list_file"
    
    # Generate individual post page with enhanced features
    content=$(process_markdown_enhanced "$file")
    
    cat > "public/p/${post_num}.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${title} - ${SITE_TITLE}</title>
    <meta name="description" content="${excerpt}">
    <meta name="author" content="${SITE_TITLE}">
    <meta property="og:title" content="${title}">
    <meta property="og:description" content="${excerpt}">
    <meta property="og:type" content="article">
    
    <!-- Stylesheets -->
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism.min.css">
    
    <!-- Favicon -->
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📝</text></svg>">
</head>
<body>
    <header class="site-header">
        <div class="site-title">
            <a href="../">${SITE_TITLE}</a>
            <button id="theme-toggle" class="theme-toggle" aria-label="Toggle theme">🌙</button>
        </div>
    </header>
    
    <nav>
        <a href="../">← Blog</a>
        <a href="../archive/">📚 Archive</a>
    </nav>
    
    <article>
        <header>
            <h1>${title}</h1>
            <div class="post-meta">
                <time datetime="${date_str}">${date_str}</time> • 
                ~${reading_time} min read • 
                ${word_count} words
            </div>
        </header>
        
        <div class="post-content">
            ${content}
        </div>
    </article>
    
    <nav style="border-top: 2px solid var(--border-color); margin-top: 4rem; padding-top: 2rem;">
        <a href="../">← Back to Blog</a>
        <a href="../archive/">📚 Archive</a>
    </nav>
    
    <!-- Scripts -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-core.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/plugins/autoloader/prism-autoloader.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mermaid/10.6.1/mermaid.min.js"></script>
    <script src="../assets/js/app.js"></script>
</body>
</html>
EOF
done

echo

processed=$(wc -l < "$post_data_file")
echo "✅ Processed $processed files"

if [ $processed -eq 0 ]; then
    echo "❌ No posts were processed successfully"
    exit 1
fi

# Generate enhanced main page
echo "ℹ️ Generating main page..."

recent_posts=$(sort -rn "$post_list_file" | head -$MAX_POSTS_MAIN | cut -d' ' -f2)

cat > public/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${SITE_TITLE}</title>
    <meta name="description" content="A modern blog with ${processed} posts about technology, programming, and more">
    <meta name="author" content="${SITE_TITLE}">
    <meta property="og:title" content="${SITE_TITLE}">
    <meta property="og:description" content="A modern blog with ${processed} posts">
    <meta property="og:type" content="website">
    
    <!-- Stylesheets -->
    <link rel="stylesheet" href="assets/css/style.css">
    
    <!-- Favicon -->
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📝</text></svg>">
</head>
<body>
    <header class="site-header">
        <div class="site-title">
            <span>${SITE_TITLE}</span>
            <button id="theme-toggle" class="theme-toggle" aria-label="Toggle theme">🌙</button>
        </div>
    </header>
    
    <main>
        <div class="stats">
            📊 ${processed} posts published
        </div>
        
        <div class="search-container">
            <input 
                type="search" 
                id="search" 
                placeholder="Search posts..." 
                autocomplete="off"
                aria-label="Search posts"
            >
            <span class="search-icon">🔍</span>
        </div>
        
        <div id="search-info" class="search-results" style="display:none">
            Found <span id="search-count">0</span> posts
        </div>
        
        <div id="posts">
EOF

for post_num in $recent_posts; do
    post_data=$(grep "^$post_num|" "$post_data_file")
    if [ -n "$post_data" ]; then
        title=$(echo "$post_data" | cut -d'|' -f2)
        date_str=$(echo "$post_data" | cut -d'|' -f3)
        excerpt=$(echo "$post_data" | cut -d'|' -f5)
        reading_time=$(echo "$post_data" | cut -d'|' -f8)
        
        cat >> public/index.html << EOF
            <article class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}" onclick="window.location.href='p/${post_num}.html'">
                <div class="post-meta">${date_str} • ~${reading_time} min read</div>
                <h2 class="post-title"><a href="p/${post_num}.html">${title}</a></h2>
                <div class="post-excerpt">${excerpt}</div>
            </article>
EOF
    fi
done

cat >> public/index.html << EOF
        </div>
        
        <nav style="margin-top: 3rem;">
            <a href="archive/">📚 View all ${processed} posts in Archive →</a>
        </nav>
    </main>
    
    <!-- Scripts -->
    <script src="assets/js/app.js"></script>
</body>
</html>
EOF

# Generate enhanced archive page
echo "ℹ️ Generating archive..."

all_posts=$(sort -rn "$post_list_file" | cut -d' ' -f2)

cat > public/archive/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Archive - ${SITE_TITLE}</title>
    <meta name="description" content="Archive of all ${processed} posts">
    <meta name="author" content="${SITE_TITLE}">
    
    <!-- Stylesheets -->
    <link rel="stylesheet" href="../assets/css/style.css">
    
    <!-- Favicon -->
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📚</text></svg>">
</head>
<body>
    <header class="site-header">
        <div class="site-title">
            <a href="../">${SITE_TITLE}</a>
            <button id="theme-toggle" class="theme-toggle" aria-label="Toggle theme">🌙</button>
        </div>
    </header>
    
    <nav>
        <a href="../">← Home</a>
    </nav>
    
    <main>
        <h1>Archive</h1>
        <div class="stats">📚 ${processed} posts chronologically ordered</div>
        
        <div class="search-container">
            <input 
                type="search" 
                id="search" 
                placeholder="Search all posts..." 
                autocomplete="off"
                aria-label="Search all posts"
            >
            <span class="search-icon">🔍</span>
        </div>
        
        <div id="search-info" class="search-results" style="display:none">
            Found <span id="search-count">0</span> of ${processed} posts
        </div>
        
        <div id="posts">
EOF

current_year=""
current_month=""

for post_num in $all_posts; do
    post_data=$(grep "^$post_num|" "$post_data_file")
    if [ -n "$post_data" ]; then
        title=$(echo "$post_data" | cut -d'|' -f2)
        date_str=$(echo "$post_data" | cut -d'|' -f3)
        excerpt=$(echo "$post_data" | cut -d'|' -f5)
        reading_time=$(echo "$post_data" | cut -d'|' -f8)
        
        year=$(echo "$date_str" | cut -d'/' -f1)
        month=$(echo "$date_str" | cut -d'/' -f2)
        month_name=$(get_month_name "$month")
        
        if [ "$year" != "$current_year" ]; then
            if [ -n "$current_year" ]; then
                echo "                </div>" >> public/archive/index.html
                echo "            </div>" >> public/archive/index.html
            fi
            echo "            <div class=\"year-section\">" >> public/archive/index.html
            echo "                <div class=\"year-header\"><h2>$year</h2></div>" >> public/archive/index.html
            current_year="$year"
            current_month=""
        fi
        
        if [ "$month" != "$current_month" ]; then
            if [ -n "$current_month" ]; then
                echo "                </div>" >> public/archive/index.html
            fi
            echo "                <div class=\"month-section\">" >> public/archive/index.html
            echo "                    <div class=\"month-header\"><h3>$month_name</h3></div>" >> public/archive/index.html
            current_month="$month"
        fi
        
        cat >> public/archive/index.html << EOF
                    <article class="post" data-title="${title,,}" data-excerpt="${excerpt,,}" data-searchable="${title,,} ${excerpt,,}" onclick="window.location.href='../p/${post_num}.html'">
                        <div class="post-meta">${date_str} • ~${reading_time} min read</div>
                        <h3 class="post-title"><a href="../p/${post_num}.html">${title}</a></h3>
                        <div class="post-excerpt">${excerpt}</div>
                    </article>
EOF
    fi
done

if [ -n "$current_month" ]; then
    echo "                </div>" >> public/archive/index.html
fi
if [ -n "$current_year" ]; then
    echo "            </div>" >> public/archive/index.html
fi

cat >> public/archive/index.html << EOF
        </div>
    </main>
    
    <!-- Scripts -->
    <script src="../assets/js/app.js"></script>
</body>
</html>
EOF

# Create manifest.json for PWA support
cat > public/manifest.json << EOF
{
  "name": "${SITE_TITLE}",
  "short_name": "${SITE_TITLE}",
  "description": "A modern blog with ${processed} posts",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#0969da",
  "icons": [
    {
      "src": "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📝</text></svg>",
      "sizes": "192x192",
      "type": "image/svg+xml"
    }
  ]
}
EOF

# Cleanup
rm -f "$post_list_file" "$post_data_file"

echo "✅ Build completed successfully!"
echo
echo "📊 STATISTICS:"
echo "  ✅ Total files processed: $processed"
echo "  ✅ Enhanced features added:"
echo "    - 🎨 Modern responsive design with dark/light themes"
echo "    - 🔍 Advanced search with highlighting"
echo "    - 📋 Copy-to-clipboard for code blocks"
echo "    - 🎯 Syntax highlighting with Prism.js"
echo "    - 📊 Mermaid diagram support"
echo "    - 📱 Progressive Web App features"
echo "    - 📈 Reading progress indicator"
echo "    - 🔄 Offline support via Service Worker"
echo "    - ♿ Accessibility improvements"
echo "    - 🚀 Performance optimizations"
echo
echo "🌐 Your enhanced blog is ready!"
