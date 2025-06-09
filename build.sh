#!/bin/bash
set -e

echo "🔧 DEBUG BUILD - Simple Blog Generator"

# Clean and create directories
rm -rf public
mkdir -p public

# Check for content
if [ ! -d "content" ]; then
    echo "❌ No content directory found!"
    echo "📁 Creating sample content for testing..."
    mkdir -p content
    cat > content/2023-01-01-welcome-1.md << 'EOF'
# Welcome Post

This is a test post to verify the build system.

The build is working correctly!
EOF
fi

# Count posts
POST_COUNT=$(find content -name "*.md" | wc -l)
echo "📊 Found $POST_COUNT markdown files"

# Generate simple index
cat > public/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Debug Blog - dee-blogger</title>
    <style>
        body { 
            max-width: 40em; 
            margin: 2em auto; 
            padding: 0 1em; 
            font-family: system-ui, sans-serif; 
            line-height: 1.5; 
        }
        .post { 
            background: #f5f5f5; 
            padding: 1em; 
            margin: 1em 0; 
            border-radius: 4px; 
        }
        .debug { 
            background: #e8f4fd; 
            padding: 1em; 
            border-left: 4px solid #0366d6; 
            margin: 1em 0; 
        }
    </style>
</head>
<body>
    <h1>🔧 Debug Blog - dee-blogger</h1>
    <div class="debug">
        <h2>✅ Build Status: SUCCESS</h2>
        <p><strong>Posts found:</strong> $POST_COUNT</p>
        <p><strong>Build time:</strong> $(date)</p>
        <p><strong>Repository:</strong> vdeemann/dee-blogger.github.io</p>
    </div>
    
    <h2>📝 Recent Posts</h2>
EOF

# Process markdown files (simple version)
find content -name "*.md" | sort -r | head -10 | while read -r file; do
    if [ -f "$file" ]; then
        # Extract title and date
        title=$(head -n1 "$file" | sed 's/^# *//')
        date=$(basename "$file" | cut -d- -f1-3 | tr - /)
        
        cat >> public/index.html << EOF
    <div class="post">
        <h3>$title</h3>
        <small>$date</small>
        <p>Post content from: $(basename "$file")</p>
    </div>
EOF
    fi
done

# Close HTML
cat >> public/index.html << 'EOF'
    
    <div class="debug">
        <h3>🔧 Debug Information</h3>
        <p>If you see this page, the build system is working correctly!</p>
        <p>Next steps:</p>
        <ul>
            <li>Add your markdown files to the <code>content/</code> directory</li>
            <li>Use the format: <code>YYYY-MM-DD-title-number.md</code></li>
            <li>Replace this debug build with your production build script</li>
        </ul>
    </div>
</body>
</html>
EOF

echo "✅ Debug build completed successfully!"
echo "📊 Generated files:"
find public -type f | while read -r f; do
    echo "  - $f ($(wc -c < "$f") bytes)"
done
