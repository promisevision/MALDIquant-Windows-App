# Application Status Check

## Is the Application Running?

If you ran `npm start` and saw this message:
```
Listening on http://127.0.0.1:3838
```

Then **YES**, the application is running! ✅

## What You Should See

### 1. Electron Window
An Electron window should have opened automatically showing the MALDIquant Analyzer interface.

**If you don't see the window:**
- Check your taskbar - the window might be minimized
- Look for "MALDIquant Analyzer" in Alt+Tab
- The window takes 5-10 seconds to load after "Listening on..." message

### 2. Application Interface
You should see:
- **Title**: "MALDIquant Analyzer"
- **Left sidebar**: Data import and processing controls
- **Main area**: Multiple tabs (Overview, Spectra, Peaks, Comparison, Settings)
- **Overview tab**: Welcome message and instructions

### 3. Console Messages (Normal)
These messages in the console are **NORMAL** (not errors):
```
R Error: This is MALDIquant version 1.22.3
R Error: Loading required package: ggplot2
R Error: Attaching package: 'plotly'
R Error: ...masked from...
R Error: Listening on http://127.0.0.1:3838
```

The "R Error:" prefix is misleading - these are actually informational messages sent to stderr.

## Startup Time

### Expected Startup Times:
- **First launch**: 30-60 seconds
  - Loading R packages
  - Initializing Shiny server
  - Starting Electron

- **Subsequent launches**: 20-30 seconds
  - R packages cached
  - Faster initialization

### What Happens During Startup:

1. **0-5s**: Electron starts
2. **5-10s**: R process spawns
3. **10-30s**: R packages load (MALDIquant, Shiny, plotly, etc.)
4. **30-40s**: Shiny server starts
5. **40-50s**: Electron loads Shiny UI
6. **50-60s**: Application ready

## Troubleshooting

### Application Won't Start

**Symptom**: Process exits immediately or shows error dialog

**Check:**
```bash
# 1. Is R installed?
R --version

# 2. Are R packages installed?
R
> library(shiny)
> library(MALDIquant)

# 3. Is Electron installed?
cd electron
npm list electron
```

### Window Doesn't Appear

**Symptom**: Console shows "Listening on..." but no window

**Solutions:**
1. **Check taskbar** - window might be behind other windows
2. **Manually open**: http://127.0.0.1:3838 in browser
3. **Restart**: Press Ctrl+C and run `npm start` again

### Stuck on Loading Screen

**Symptom**: Shows loading animation but never loads

**Solutions:**
1. Wait 60 seconds (first load is slow)
2. Check console for error messages
3. Restart application

### Port Already in Use

**Symptom**: Error about port 3838 already in use

**Solutions:**
```bash
# Windows: Kill process on port 3838
netstat -ano | findstr :3838
taskkill /PID <PID> /F

# Or change port in electron/main.js:
# let shinyPort = 3838;  // Change to 3839
```

## Quick Test

### Verify Application is Working:

1. **Check Window**: Should show MALDIquant interface
2. **Check Tabs**: Click each tab - should switch views
3. **Check File Input**: Click "Select Spectra Files" - file dialog should open
4. **Check Console**: Should show "Listening on http://127.0.0.1:3838"

### Test with Sample Data:

See: `data/sample-data/test_data_summary.txt` for test files

## Performance Expectations

### File Import:
- Small files (<10MB): < 5 seconds
- Medium files (10-50MB): 10-30 seconds
- Large files (>50MB): 30-60 seconds

### Processing:
- 1 spectrum: 5-10 seconds
- 5 spectra: 20-30 seconds
- 10 spectra: 40-60 seconds

### Export:
- CSV: < 5 seconds
- PNG: < 5 seconds

## Stopping the Application

### Normal Stop:
- Close the Electron window
- OR press Ctrl+C in the terminal

### Force Stop:
```bash
# Windows
taskkill /IM electron.exe /F
taskkill /IM Rscript.exe /F
```

## Checking Logs

### Console Output:
All logs are printed to the terminal where you ran `npm start`

### Important Log Messages:
```
✅ GOOD: "Listening on http://127.0.0.1:3838"
✅ GOOD: "Found Rscript at: ..."
✅ GOOD: "All required packages found"

❌ BAD: "R process exited with code 3221225477"
❌ BAD: "could not find function"
❌ BAD: "Package 'xxx' is not installed"
```

## Next Steps

If application is running successfully:
1. ✅ Generate test data: Run `generate_test_data.R`
2. ✅ Test file import
3. ✅ Test preprocessing
4. ✅ Test peak detection
5. ✅ Test export

If having issues:
1. See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Check console for error messages
3. Verify R and packages are installed

---

**Current Status**: Application should be running at http://127.0.0.1:3838

**Startup Time**: ~30-60 seconds (first launch)

**Ready When**: You see "Listening on http://127.0.0.1:3838" in console
