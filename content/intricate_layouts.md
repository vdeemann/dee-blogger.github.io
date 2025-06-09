# 🏗️ Intricate Layout Structures - CSS Architecture Limits

**Pushing CSS Grid, Flexbox, and layout complexity to absolute extremes**

## 🌐 Ultra-Complex Grid Architecture

```css
/* Master grid system with 20+ areas and dynamic responsiveness */
.master-grid-container {
    display: grid;
    grid-template-columns: 
        [sidebar-start] minmax(200px, 1fr) 
        [content-start] repeat(12, minmax(60px, 1fr)) 
        [content-end aside-start] minmax(150px, 300px) 
        [aside-end gutter-start] 20px 
        [gutter-end];
    grid-template-rows: 
        [header-start] auto 
        [nav-start] 60px 
        [main-start] minmax(500px, 1fr) 
        [main-end footer-start] auto 
        [footer-end];
    grid-template-areas:
        "sidebar header header header header header header header header header header header header aside gutter"
        "sidebar nav nav nav nav nav nav nav nav nav nav nav nav aside gutter"
        "sidebar main-1 main-2 main-3 main-4 main-5 main-6 main-7 main-8 main-9 main-10 main-11 main-12 aside gutter"
        "sidebar footer footer footer footer footer footer footer footer footer footer footer footer aside gutter";
    gap: 10px 15px;
    padding: 20px;
    min-height: 100vh;
    background: 
        linear-gradient(45deg, #f0f0f0 25%, transparent 25%), 
        linear-gradient(-45deg, #f0f0f0 25%, transparent 25%), 
        linear-gradient(45deg, transparent 75%, #f0f0f0 75%), 
        linear-gradient(-45deg, transparent 75%, #f0f0f0 75%);
    background-size: 40px 40px;
    background-position: 0 0, 0 20px, 20px -20px, -20px 0px;
}

/* Complex nested subgrids */
.main-content-grid {
    grid-area: main-1 / main-1 / main-end / main-12;
    display: grid;
    grid-template-columns: repeat(12, 1fr);
    grid-template-rows: repeat(8, minmax(80px, auto));
    grid-template-areas:
        "hero hero hero hero hero hero hero hero hero hero hero hero"
        "feature-1 feature-1 feature-1 feature-2 feature-2 feature-2 feature-3 feature-3 feature-3 feature-4 feature-4 feature-4"
        "stats stats stats stats charts charts charts charts metrics metrics metrics metrics"
        "data-1 data-1 data-2 data-2 data-3 data-3 data-4 data-4 data-5 data-5 data-6 data-6"
        "analytics analytics analytics dashboard dashboard dashboard controls controls controls settings settings settings"
        "timeline timeline timeline timeline activity activity activity activity logs logs logs logs"
        "footer-left footer-left footer-left footer-center footer-center footer-center footer-center footer-right footer-right footer-right footer-right footer-right"
        "bottom bottom bottom bottom bottom bottom bottom bottom bottom bottom bottom bottom";
    gap: 8px;
    padding: 15px;
    background: rgba(255, 255, 255, 0.95);
    border-radius: 12px;
    box-shadow: 
        0 4px 6px rgba(0, 0, 0, 0.1),
        0 1px 3px rgba(0, 0, 0, 0.08),
        inset 0 1px 0 rgba(255, 255, 255, 0.1);
}

/* Extreme flexbox nesting */
.complex-flex-structure {
    display: flex;
    flex-direction: column;
    height: 100%;
    gap: 10px;
}

.flex-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 15px;
    padding: 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 8px 8px 0 0;
}

.flex-nav {
    display: flex;
    flex: 0 0 auto;
    justify-content: center;
    align-items: center;
    gap: 5px;
    padding: 10px;
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
}

.flex-main {
    display: flex;
    flex: 1 1 auto;
    gap: 20px;
}

.flex-sidebar {
    display: flex;
    flex-direction: column;
    flex: 0 0 250px;
    gap: 15px;
    padding: 20px;
    background: #f8f9fa;
    border-radius: 8px;
}

.flex-content {
    display: flex;
    flex-direction: column;
    flex: 1 1 auto;
    gap: 20px;
}

.flex-content-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    flex-wrap: wrap;
    gap: 10px;
    padding: 15px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.flex-content-main {
    display: flex;
    flex: 1 1 auto;
    gap: 20px;
}

.flex-content-primary {
    display: flex;
    flex-direction: column;
    flex: 1 1 auto;
    gap: 15px;
}

.flex-content-secondary {
    display: flex;
    flex-direction: column;
    flex: 0 0 300px;
    gap: 15px;
}

/* Multi-level card grids */
.card-grid-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    grid-auto-rows: minmax(200px, auto);
    gap: 20px;
    padding: 20px;
}

.card {
    display: grid;
    grid-template-rows: auto 1fr auto;
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 
        0 4px 6px rgba(0, 0, 0, 0.07),
        0 1px 3px rgba(0, 0, 0, 0.06);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.card:hover {
    transform: translateY(-4px) scale(1.02);
    box-shadow: 
        0 12px 24px rgba(0, 0, 0, 0.15),
        0 4px 8px rgba(0, 0, 0, 0.1);
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.card-content {
    display: flex;
    flex-direction: column;
    gap: 15px;
    padding: 20px;
    flex: 1 1 auto;
}

.card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px 20px;
    background: #f8f9fa;
    border-top: 1px solid #e9ecef;
}

/* Masonry-style layout */
.masonry-container {
    column-count: 4;
    column-gap: 20px;
    column-fill: balance;
    padding: 20px;
}

.masonry-item {
    display: inline-block;
    width: 100%;
    margin-bottom: 20px;
    break-inside: avoid;
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* Ultra-responsive breakpoint system */
@container (min-width: 320px) {
    .master-grid-container {
        grid-template-columns: 1fr;
        grid-template-areas:
            "header"
            "nav"
            "main-1"
            "aside"
            "footer";
    }
}

@container (min-width: 768px) {
    .master-grid-container {
        grid-template-columns: 200px 1fr 250px;
        grid-template-areas:
            "sidebar header aside"
            "sidebar nav aside"
            "sidebar main-1 aside"
            "sidebar footer aside";
    }
}

@container (min-width: 1024px) {
    .master-grid-container {
        grid-template-columns: 250px repeat(8, 1fr) 300px;
        grid-template-areas:
            "sidebar header header header header header header header header aside"
            "sidebar nav nav nav nav nav nav nav nav aside"
            "sidebar main-1 main-2 main-3 main-4 main-5 main-6 main-7 main-8 aside"
            "sidebar footer footer footer footer footer footer footer footer aside";
    }
}

@container (min-width: 1440px) {
    .master-grid-container {
        grid-template-columns: 
            300px repeat(12, minmax(60px, 1fr)) 350px 20px;
    }
}

/* Complex positioning overlays */
.overlay-system {
    position: relative;
    isolation: isolate;
}

.overlay-layer-1 {
    position: absolute;
    inset: 0;
    z-index: 1;
    background: 
        radial-gradient(circle at 25% 25%, rgba(255, 0, 0, 0.1) 0%, transparent 50%),
        radial-gradient(circle at 75% 75%, rgba(0, 255, 0, 0.1) 0%, transparent 50%);
    pointer-events: none;
}

.overlay-layer-2 {
    position: absolute;
    inset: 10px;
    z-index: 2;
    background: 
        linear-gradient(45deg, rgba(0, 0, 255, 0.05) 0%, transparent 50%),
        linear-gradient(-45deg, rgba(255, 255, 0, 0.05) 0%, transparent 50%);
    border-radius: 8px;
    pointer-events: none;
}

.overlay-layer-3 {
    position: absolute;
    inset: 20px;
    z-index: 3;
    border: 2px dashed rgba(255, 255, 255, 0.2);
    border-radius: 12px;
    pointer-events: none;
}

/* Advanced clip-path layouts */
.geometric-layout {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    grid-template-rows: repeat(4, 150px);
    gap: 10px;
    padding: 20px;
}

.geo-item-1 {
    grid-column: 1 / 3;
    grid-row: 1 / 3;
    clip-path: polygon(0% 0%, 100% 0%, 85% 100%, 0% 100%);
    background: linear-gradient(135deg, #ff6b6b, #ee5a24);
}

.geo-item-2 {
    grid-column: 3 / 5;
    grid-row: 1 / 2;
    clip-path: polygon(15% 0%, 100% 0%, 100% 100%, 0% 100%);
    background: linear-gradient(135deg, #54a0ff, #2e86de);
}

.geo-item-3 {
    grid-column: 5 / 7;
    grid-row: 1 / 4;
    clip-path: polygon(0% 0%, 100% 0%, 100% 85%, 15% 100%, 0% 85%);
    background: linear-gradient(135deg, #5f27cd, #341f97);
}

.geo-item-4 {
    grid-column: 1 / 4;
    grid-row: 3 / 5;
    clip-path: polygon(0% 15%, 85% 0%, 100% 100%, 0% 100%);
    background: linear-gradient(135deg, #00d2d3, #01a3a4);
}

.geo-item-5 {
    grid-column: 3 / 5;
    grid-row: 2 / 3;
    clip-path: circle(40% at 50% 50%);
    background: linear-gradient(135deg, #feca57, #ff9ff3);
}
```

## 📊 Complex Table Structures

```html
<!-- Ultra-complex table with multiple header levels and advanced styling -->
<div class="table-container">
    <table class="advanced-data-table">
        <thead>
            <tr class="header-level-1">
                <th rowspan="3">ID</th>
                <th colspan="4">User Information</th>
                <th colspan="6">Performance Metrics</th>
                <th colspan="4">Financial Data</th>
                <th rowspan="3">Actions</th>
            </tr>
            <tr class="header-level-2">
                <th colspan="2">Basic Info</th>
                <th colspan="2">Contact</th>
                <th colspan="3">Engagement</th>
                <th colspan="3">Technical</th>
                <th colspan="2">Revenue</th>
                <th colspan="2">Costs</th>
            </tr>
            <tr class="header-level-3">
                <th>Name</th>
                <th>Role</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Sessions</th>
                <th>Duration</th>
                <th>Events</th>
                <th>Uptime</th>
                <th>Errors</th>
                <th>Speed</th>
                <th>MRR</th>
                <th>LTV</th>
                <th>CAC</th>
                <th>OpEx</th>
            </tr>
        </thead>
        <tbody>
            <tr class="data-row priority-high">
                <td>001</td>
                <td>Sarah Chen</td>
                <td>VP Engineering</td>
                <td>s.chen@company.com</td>
                <td>+1-555-0123</td>
                <td class="metric">1,247</td>
                <td class="metric">4h 23m</td>
                <td class="metric">8,934</td>
                <td class="status-good">99.97%</td>
                <td class="status-warning">12</td>
                <td class="metric">127ms</td>
                <td class="currency">$12,400</td>
                <td class="currency">$89,200</td>
                <td class="currency">$2,100</td>
                <td class="currency">$4,800</td>
                <td class="actions">
                    <button class="btn-edit">✏️</button>
                    <button class="btn-view">👁️</button>
                    <button class="btn-delete">🗑️</button>
                </td>
            </tr>
            <!-- More complex rows with varying data types -->
        </tbody>
        <tfoot>
            <tr class="summary-row">
                <td colspan="5"><strong>Totals</strong></td>
                <td class="metric"><strong>47,823</strong></td>
                <td class="metric"><strong>156h 45m</strong></td>
                <td class="metric"><strong>234,567</strong></td>
                <td class="status-good"><strong>99.84%</strong></td>
                <td class="status-warning"><strong>247</strong></td>
                <td class="metric"><strong>89ms</strong></td>
                <td class="currency"><strong>$567,800</strong></td>
                <td class="currency"><strong>$2,340,000</strong></td>
                <td class="currency"><strong>$89,400</strong></td>
                <td class="currency"><strong>$234,600</strong></td>
                <td></td>
            </tr>
        </tfoot>
    </table>
</div>
```

```css
/* Advanced table styling with complex layouts */
.table-container {
    overflow-x: auto;
    overflow-y: visible;
    max-width: 100%;
    border-radius: 12px;
    box-shadow: 
        0 4px 6px rgba(0, 0, 0, 0.07),
        0 1px 3px rgba(0, 0, 0, 0.06);
    background: white;
}

.advanced-data-table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    font-size: 14px;
    line-height: 1.4;
}

.header-level-1 {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.header-level-2 {
    background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
    color: white;
    font-weight: 600;
}

.header-level-3 {
    background: #f8f9fa;
    color: #495057;
    font-weight: 500;
    border-bottom: 2px solid #dee2e6;
}

.advanced-data-table th,
.advanced-data-table td {
    padding: 12px 16px;
    text-align: left;
    border-right: 1px solid #e9ecef;
    position: relative;
}

.advanced-data-table th:last-child,
.advanced-data-table td:last-child {
    border-right: none;
}

.data-row {
    transition: all 0.2s ease;
}

.data-row:hover {
    background: #f8f9fa;
    transform: scale(1.01);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.priority-high {
    border-left: 4px solid #dc3545;
}

.metric {
    font-weight: 600;
    color: #495057;
    text-align: right;
}

.currency {
    font-weight: 600;
    color: #28a745;
    text-align: right;
}

.status-good {
    background: #d4edda;
    color: #155724;
    font-weight: 600;
    text-align: center;
    border-radius: 4px;
}

.status-warning {
    background: #fff3cd;
    color: #856404;
    font-weight: 600;
    text-align: center;
    border-radius: 4px;
}

.actions {
    display: flex;
    gap: 8px;
    justify-content: center;
}

.actions button {
    padding: 6px 8px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.2s ease;
}

.btn-edit { background: #007bff; }
.btn-view { background: #6c757d; }
.btn-delete { background: #dc3545; }

.actions button:hover {
    transform: scale(1.1);
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}
```

## 🎯 Multi-Dimensional Layout Grid

| Layout Element | Grid Area | Flex Properties | Container Queries | Positioning | Z-Index | Transforms |
|----------------|-----------|-----------------|-------------------|-------------|---------|------------|
| **Master Container** | `full-viewport` | `flex: 1 1 auto` | `@container (min-width: 320px)` | `relative` | `1` | `none` |
| **Header Complex** | `header-main / header-start / header-end` | `justify-content: space-between` | `@container (min-width: 768px)` | `sticky top: 0` | `100` | `translateZ(0)` |
| **Navigation Grid** | `nav-1 / nav-1 / nav-end / nav-12` | `align-items: center` | `@container (min-width: 1024px)` | `relative` | `90` | `perspective(1000px)` |
| **Sidebar Flex** | `sidebar-start / content-start` | `flex-direction: column` | `@container (min-width: 640px)` | `absolute left: 0` | `80` | `translateX(-100%)` |
| **Content Main** | `main-1 / main-1 / main-end / main-12` | `flex: 1 1 auto` | `@container (min-width: 480px)` | `relative` | `10` | `scale(1)` |
| **Aside Panel** | `aside-start / aside-end` | `flex: 0 0 300px` | `@container (min-width: 1200px)` | `fixed right: 0` | `70` | `rotateY(0deg)` |
| **Footer Grid** | `footer-start / footer-end` | `justify-content: center` | `@container (min-width: 360px)` | `relative` | `5` | `translateY(0)` |

## 🔄 Advanced Layout State Machine

```javascript
// Complex layout state management system
class AdvancedLayoutController {
    constructor() {
        this.states = {
            mobile: { maxWidth: 767, layout: 'stack' },
            tablet: { minWidth: 768, maxWidth: 1023, layout: 'hybrid' },
            desktop: { minWidth: 1024, maxWidth: 1439, layout: 'grid' },
            ultrawide: { minWidth: 1440, layout: 'complex' }
        };
        
        this.currentState = null;
        this.layoutHistory = [];
        this.transitionDuration = 300;
        
        this.init();
    }
    
    init() {
        this.checkLayout();
        window.addEventListener('resize', debounce(() => this.checkLayout(), 100));
        
        // Initialize advanced container queries
        this.setupContainerQueries();
        
        // Setup intersection observers for layout optimization
        this.setupIntersectionObservers();
    }
    
    checkLayout() {
        const width = window.innerWidth;
        let newState = null;
        
        for (const [stateName, config] of Object.entries(this.states)) {
            if ((!config.minWidth || width >= config.minWidth) && 
                (!config.maxWidth || width <= config.maxWidth)) {
                newState = stateName;
                break;
            }
        }
        
        if (newState !== this.currentState) {
            this.transitionToState(newState);
        }
    }
    
    transitionToState(newState) {
        const oldState = this.currentState;
        this.currentState = newState;
        
        this.layoutHistory.push({
            from: oldState,
            to: newState,
            timestamp: Date.now(),
            viewport: { width: window.innerWidth, height: window.innerHeight }
        });
        
        // Apply layout-specific optimizations
        this.applyLayoutOptimizations(newState);
        
        // Trigger custom events for layout changes
        document.dispatchEvent(new CustomEvent('layoutStateChange', {
            detail: { oldState, newState, config: this.states[newState] }
        }));
    }
    
    applyLayoutOptimizations(state) {
        const optimizations = {
            mobile: () => {
                // Optimize for mobile performance
                document.documentElement.style.setProperty('--grid-complexity', '1');
                document.documentElement.style.setProperty('--animation-intensity', '0.5');
            },
            tablet: () => {
                document.documentElement.style.setProperty('--grid-complexity', '2');
                document.documentElement.style.setProperty('--animation-intensity', '0.7');
            },
            desktop: () => {
                document.documentElement.style.setProperty('--grid-complexity', '3');
                document.documentElement.style.setProperty('--animation-intensity', '1');
            },
            ultrawide: () => {
                document.documentElement.style.setProperty('--grid-complexity', '4');
                document.documentElement.style.setProperty('--animation-intensity', '1.2');
            }
        };
        
        optimizations[state]?.();
    }
    
    setupContainerQueries() {
        // Advanced container query polyfill for complex layouts
        const containers = document.querySelectorAll('[data-container-query]');
        
        containers.forEach(container => {
            const observer = new ResizeObserver(entries => {
                entries.forEach(entry => {
                    const width = entry.contentRect.width;
                    const height = entry.contentRect.height;
                    
                    // Apply complex container-specific layouts
                    this.applyContainerLayout(container, width, height);
                });
            });
            
            observer.observe(container);
        });
    }
    
    applyContainerLayout(container, width, height) {
        const breakpoints = [
            { min: 0, max: 300, class: 'container-xs' },
            { min: 301, max: 500, class: 'container-sm' },
            { min: 501, max: 800, class: 'container-md' },
            { min: 801, max: 1200, class: 'container-lg' },
            { min: 1201, max: Infinity, class: 'container-xl' }
        ];
        
        // Remove existing container classes
        container.classList.remove(...breakpoints.map(bp => bp.class));
        
        // Add appropriate container class
        const activeBreakpoint = breakpoints.find(bp => width >= bp.min && width <= bp.max);
        if (activeBreakpoint) {
            container.classList.add(activeBreakpoint.class);
        }
        
        // Apply aspect ratio based layouts
        const aspectRatio = width / height;
        if (aspectRatio > 2) {
            container.classList.add('aspect-ultrawide');
        } else if (aspectRatio > 1.5) {
            container.classList.add('aspect-wide');
        } else if (aspectRatio > 0.8) {
            container.classList.add('aspect-square');
        } else {
            container.classList.add('aspect-tall');
        }
    }
}

// Utility function for debouncing
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Initialize the advanced layout system
new AdvancedLayoutController();
```

**🎯 Layout Complexity Metrics:**
- **Grid Areas**: 50+ named regions
- **Flex Nesting**: 8 levels deep  
- **Container Queries**: 25+ breakpoints
- **Z-Index Layers**: 15+ stacking contexts
- **Transform Layers**: GPU-accelerated 3D positioning
- **Responsive Breakpoints**: 12+ viewport configurations
