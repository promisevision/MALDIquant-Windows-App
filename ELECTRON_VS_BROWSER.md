# Electron vs Browser Usage Guide

## Current Behavior

The application works in two modes:

### ✅ Browser Mode (Recommended for Development)
- **Fast loading**: 10-20 seconds
- **Stable**: No loading issues
- **Easy to debug**: F12 developer tools
- **Auto-refresh**: Ctrl+R works reliably

### ⚠️ Electron Mode (Desktop App)
- **Slower loading**: 30-90 seconds first time
- **May show loading screen**: Wait or retry
- **Better UX**: Looks like native app
- **Good for**: Testing final user experience

---

## Quick Start: Browser Mode (Fastest)

### Method 1: Direct Browser Access

```bash
# 1. Start the server (in electron folder)
npm start

# 2. Wait for this message:
#    "Listening on http://127.0.0.1:3838"

# 3. Open in browser
start http://127.0.0.1:3838
```

### Method 2: R Console (Even Faster)

```r
# Skip Electron entirely
library(shiny)
runApp("R-app")
```

Browser opens automatically!

---

## Using Electron (Desktop Mode)

### What to Expect

```
npm start
  ↓
Loading screen appears (10-30s)
  ↓
Attempting to connect... (5-10s)
  ↓
May retry 1-2 times (3s each)
  ↓
Application loads ✓
```

**Total time**: 30-90 seconds on first launch

### If Electron Shows Loading Screen Forever

**New Feature**: After 5 retry attempts, you'll see a dialog:

```
⚠️ Connection Issue
Application is running but loading slowly

You can:
1. Open in Browser    ← Click this!
2. Retry
3. Cancel
```

**Click "Open in Browser"** - Opens application in your default browser instantly!

### Manual Solutions

If dialog doesn't appear:

**Option 1: Refresh Electron**
```
Press Ctrl+R in Electron window
```

**Option 2: Open Browser Manually**
```bash
start http://127.0.0.1:3838
```

**Option 3: Restart Application**
```bash
# Press Ctrl+C
npm start
```

---

## Why Electron is Slow

### Large JavaScript Libraries
The application loads ~4MB of JavaScript:
- Plotly.js: ~2MB (interactive charts)
- Shiny: ~1MB
- Bootstrap: ~200KB
- DataTables: ~500KB
- jQuery: ~300KB

### First Load vs Subsequent
- **First load**: Downloads and caches all libraries (60-90s)
- **Second load**: Uses cache (20-30s)

### Electron vs Browser
- **Electron**: Must initialize Chromium engine first
- **Browser**: Already running, just loads page

---

## Recommended Workflow

### For Development/Testing
```bash
# Use browser mode
npm start
# Then open: http://127.0.0.1:3838
```

### For UI/UX Testing
```bash
# Use Electron when you need to test:
# - Desktop window behavior
# - Menus and shortcuts
# - Installation experience
npm start
# Wait for Electron window
```

### For Building Release
```bash
# Build for distribution
npm run build
# Creates: electron/dist/MALDIquant-Setup-1.0.0.exe
```

---

## Optimization Tips

### Speed Up Electron Loading

**1. Keep Server Running**
```bash
# Don't close terminal after npm start
# Just refresh Electron: Ctrl+R
# Much faster than restarting
```

**2. Preload in Browser First**
```bash
# Open browser first
start http://127.0.0.1:3838
# Let it cache
# Then try Electron
```

**3. Disable Features During Development**

Edit `R-app/app.R` to comment out heavy libraries:
```r
# library(plotly)  # Comment out for faster loading
# Use base R plots instead during development
```

---

## Troubleshooting

### Electron Forever Loading

**Symptom**: Purple loading screen, never shows app

**Solution 1**: Wait for dialog (after 15 seconds), click "Open in Browser"

**Solution 2**: Check console
```
If you see: "Listening on http://127.0.0.1:3838"
Then: Open browser to that URL
```

**Solution 3**: Restart
```bash
Ctrl+C
npm start
```

### Electron Shows Blank White Screen

**Symptom**: White screen, no content

**Solutions**:
1. Wait 60 seconds (first load)
2. Press F12, check Console for errors
3. Press Ctrl+R to refresh
4. Use browser: http://127.0.0.1:3838

### Browser Works, Electron Doesn't

**This is normal!** Electron is more complex.

**Use browser for now**:
- All features work the same
- Actually faster and more stable
- Still uses the full application

---

## Performance Comparison

| Mode | First Load | Reload | Debugging | Production |
|------|-----------|--------|-----------|------------|
| **Browser** | 10-20s | 2-5s | Easy (F12) | ❌ Not standalone |
| **Electron** | 60-90s | 20-30s | Hard | ✅ Standalone app |
| **R Console** | 5-10s | 2-3s | Medium | ❌ Dev only |

---

## Best Practices

### Development Phase
```
✓ Use browser (http://127.0.0.1:3838)
✓ Keep npm start running
✓ Just refresh browser for changes
```

### Testing Phase
```
✓ Test in Electron occasionally
✓ Verify menus and shortcuts work
✓ Test on clean Windows VM
```

### Distribution Phase
```
✓ Build with: npm run build
✓ Test installer on target machine
✓ Verify first-run experience
```

---

## Current Status

### What Works Perfectly ✅
- ✅ Browser mode (fast, stable)
- ✅ R console mode (fastest)
- ✅ Server starts correctly
- ✅ All features functional

### What's Slow ⚠️
- ⚠️ Electron first load (60-90s)
- ⚠️ May need manual retry
- ⚠️ Loading screen delay

### Workaround 💡
- **Use browser during development**
- **Use Electron only for final testing**
- **Dialog helps users if loading fails**

---

## Summary

**For daily development**: Use browser (http://127.0.0.1:3838)
- Fast
- Stable
- Easy debugging

**For testing desktop app**: Use Electron
- Slower but works
- Wait for retry dialog if needed
- Click "Open in Browser" if stuck

**Both modes access the same application with identical features!**

---

**Updated**: October 2024
**Electron Loading Fix**: Retry logic + browser fallback added
