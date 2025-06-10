# Ultra-Minimal Blog

**🌐 Live Blog**: https://vdeemann.github.io/dee-blogger.github.io

A sub-3KB blog system that respects your readers' bandwidth and time.

## Live Statistics

- **Total repository size**: ~24 KB (complete source code)
- **Generated site size**: ~12 KB (deployed files)
- **Average page size**: ~1.1 KB per post
- **Main page size**: ~2.8 KB (including search)
- **Posts**: 6 complete articles
- **Build time**: < 5 seconds
- **Load time**: < 100ms
- **Dependencies**: 0 external libraries
- **Technologies**: Python build script + HTML/CSS/JS

## Features

- **Sub-3KB pages** - Entire blog posts under 3KB
- **Real-time search** - Find posts instantly
- **Individual post pages** - Clean, readable layouts
- **Mobile responsive** - Works on all devices
- **No tracking** - Respects privacy
- **No external dependencies** - Completely self-contained
- **Auto-deployment** - Updates on every git push

## Size Breakdown

### Complete Project Structure
```
dee-blogger.github.io/
├── .github/
│   └── workflows/
│       └── build.yml               1.2 KB  # GitHub Actions workflow
├── .gitignore                      0.1 KB  # Git ignore rules
├── README.md                       8.5 KB  # This documentation
├── build.py                        2.4 KB  # Static site generator
├── build.sh                        0.8 KB  # Build shell script
├── template.html                   1.8 KB  # HTML template
├── style.css                       1.2 KB  # Stylesheet
├── script.js                       0.8 KB  # Search functionality
├── content/
│   ├── 2025-06-08-phoenix-liveview-vs-javascript.md  1.4 KB
│   ├── 2025-06-07-guix-blog.md     1.5 KB
│   ├── 2025-06-05-libreboot.md     1.3 KB
│   ├── 2025-06-01-guix-packages.md 1.5 KB
│   ├── 2025-05-28-256gb-ram.md     1.4 KB
│   └── 2025-05-25-static-vs...md   1.5 KB
└── _site/ (generated)
    ├── index.html                  2.8 KB  # Main page
    ├── posts/
    │   ├── phoenix-liveview-vs-javascript.html  1.2 KB
    │   ├── guix-blog.html          1.1 KB
    │   ├── libreboot.html          1.0 KB
    │   ├── guix-packages.html      1.1 KB
    │   ├── 256gb-ram.html          1.0 KB
    │   └── static-vs.html          1.1 KB
    └── assets/
        ├── style.min.css           0.4 KB  # Minified CSS
        └── search.min.js           0.3 KB  # Minified JS
                                   -------
Total Repository:                   ~24 KB
Total Generated Site:               ~12 KB
```

## Size Verification

### Quick Browser Check

Want to verify a page is under 3KB? Open any page, press **F12** → **Console**, and paste:

```javascript
// Quick size check in browser
let size = new Blob([document.documentElement.outerHTML]).size;
console.log(`Page size: ${size} bytes`);
console.log(`3KB budget: ${size <= 3072 ? '✅ PASS' : '❌ FAIL'}`);
if (size <= 3072) {
    console.log(`Remaining: ${3072 - size} bytes`);
} else {
    console.log(`Over by: ${size - 3072} bytes`);
}
```

**Expected output**:
```
Page size: 2847 bytes
3KB budget: ✅ PASS
Remaining: 225 bytes
```

## Local Development

### Prerequisites

**Install Python** (if not already installed):

**Linux:**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install python3

# Fedora/RHEL
sudo dnf install python3

# Arch Linux
sudo pacman -S python
```

**BSD:**
```bash
# FreeBSD
sudo pkg install python3

# OpenBSD
sudo pkg_add python3
```

**macOS:**
```bash
# Using Homebrew (recommended)
brew install python

# Or download from python.org
```

**Windows:**
- Download from https://python.org
- Add to PATH during installation

### Testing Locally

**Linux/BSD/macOS:**
```bash
python3 -m http.server 8000
```

**Windows:**
```cmd
python -m http.server 8000
```

**Visit:** http://localhost:8000

## Adding New Posts (Future)

### Method 1: Using File Manager + Git

**Linux/BSD/macOS:**
1. **Create new file** in `content/` folder:
   ```bash
   # Using terminal
   nano content/2025-06-08-my-new-post.md
   # Or use your preferred editor: vim, gedit, kate, etc.
   ```

2. **Deploy**:
   ```bash
   git add .
   git commit -m "Add new post"
   git push
   ```

**Windows:**
1. **Create new file** in `content\` folder:
   - File name: `2025-06-08-my-new-post.md`
   - Content: See example below

2. **Deploy**:
   ```cmd
   git add .
   git commit -m "Add new post"
   git push
   ```

### Method 2: Create Directly on GitHub

1. **Go to your repository** on GitHub
2. **Navigate to `content/` folder**
3. **Click "Add file" → "Create new file"**
4. **File name**: `2025-06-08-my-new-post.md`
5. **Add content** (see example below)
6. **Click "Commit changes"**

### Method 3: Using Automation Scripts (Optional)

**Linux/BSD/macOS Shell Script:**

Create `new-post.sh` in your project folder:

```bash
#!/bin/bash
read -p "Enter post title: " title
mydate=$(date +%Y-%m-%d)
filename="$mydate-$(echo "$title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"

cat > "content/$filename.md" << EOF
# $title

Short description here.

Full content goes here with more details about your topic.

You can write multiple paragraphs and the build script will automatically convert them to proper HTML paragraphs.

Each post becomes a separate page accessible via the main blog's search functionality.
EOF

echo "Created: content/$filename.md"
```

Make executable and run:
```bash
chmod +x new-post.sh
./new-post.sh
```

Then commit and push as usual.

**Windows Batch File:**

Create `new-post.bat` in your project folder:

```batch
@echo off
set /p title="Enter post title: "
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
set filename=%mydate%-%title: =-%
echo # %title% > content\%filename%.md
echo. >> content\%filename%.md
echo Short description here. >> content\%filename%.md
echo. >> content\%filename%.md
echo Full content goes here... >> content\%filename%.md
echo Created: content\%filename%.md
pause
```

Double-click to run, then commit and push as usual.

### Post Content Example

Create `content\2025-06-08-my-new-post.md`:
```markdown
# My New Post

Short description here.

Full content goes here with more details about your topic.

You can write multiple paragraphs and the build script will automatically convert them to proper HTML paragraphs.

Each post becomes a separate page accessible via the main blog's search functionality.
```

### File Naming Convention

Always use this format for post filenames:
```
YYYY-MM-DD-post-slug.md
```

Examples:
- `2025-06-08-my-first-post.md`
- `2025-06-15-review-of-minimal-computing.md`
- `2025-07-01-summer-updates.md`

## Performance Comparison

| Metric | This Blog | Average Blog | Difference |
|--------|-----------|--------------|------------|
| **Page size** | 1.1 KB | 2.3 MB | **99.95% smaller** |
| **Load time** | < 100ms | 3-8 seconds | **30x faster** |
| **Dependencies** | 0 | 50+ | **Zero bloat** |
| **JavaScript** | 180 bytes | 1+ MB | **99.98% less** |
| **Carbon footprint** | Minimal | High | **Sustainable** |

## Philosophy

This blog embodies the principles of:

- **Minimal computing** - Maximum efficiency, minimum bloat
- **Reader respect** - Fast loading, no tracking, accessible design
- **Environmental responsibility** - Tiny carbon footprint per pageview
- **Digital sovereignty** - Self-hosted, no external dependencies
- **Unix philosophy** - Do one thing well (serve content efficiently)

## Inspiration

Built for the [512KB Club](https://512kb.club/) and inspired by sites like [The Jolly Teapot](https://thejollyteapot.com/) (3.6KB with 346 posts).
