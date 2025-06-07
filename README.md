# Ultra-Minimal Blog

**🌐 Live Blog**: https://vdeemann.github.io/dee-blogger.github.io

A sub-3KB blog system that respects your readers' bandwidth and time.

## Features

- ✅ **Sub-3KB pages** - Entire blog posts under 3KB
- ✅ **Real-time search** - Find posts instantly
- ✅ **Individual post pages** - Clean, readable layouts
- ✅ **Mobile responsive** - Works on all devices
- ✅ **No tracking** - Respects privacy
- ✅ **No external dependencies** - Completely self-contained
- ✅ **512KB Club compliant** - Extreme efficiency
- ✅ **Auto-deployment** - Updates on every git push

## Local Development (Windows)

1. **Install Python** (if not already installed):
   - Download from https://python.org
   - Add to PATH during installation

2. **Test locally** (optional):
   ```cmd
   python -m http.server 8000

3. Visit: http://localhost:8000

## Adding New Posts (Future)

### Method 1: Using File Explorer + Git

1. **Create new file** in `content\` folder:
   - File name: `2025-06-08-my-new-post.md`
   - Content: See example below

2. **Deploy**:
   ```cmd
   git add .
   git commit -m "Add new post"
   git push
