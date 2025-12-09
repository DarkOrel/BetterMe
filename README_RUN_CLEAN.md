# Flutter Run with Clean Logs

This project includes scripts to filter out Samsung system message spam from Flutter run logs.

## Quick Start

### Option 1: Use the Batch Script (Recommended for Windows)

Simply double-click or run in terminal:
```bash
run_clean.bat
```

Or from PowerShell:
```powershell
.\run_clean.bat
```

This will start Flutter and automatically filter out:
- `MSHandlerLifeCycle`
- `isMultiSplitHandlerRequested`

### Option 2: Use PowerShell Script

If you prefer PowerShell:
```powershell
.\run_clean.ps1
```

### Option 3: Manual Filtering

You can also manually filter logs using:
```bash
flutter run 2>&1 | findstr /V /C:"MSHandlerLifeCycle" | findstr /V /C:"isMultiSplitHandlerRequested"
```

## VS Code Integration

### Using the Task

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type "Tasks: Run Task"
3. Select "Flutter: Run (Clean Logs)"
4. The filtered output will appear in the terminal

### Using the Terminal Directly

1. Open the integrated terminal in VS Code (`Ctrl+`` ` or View → Terminal)
2. Run: `.\run_clean.bat`
3. The filtered logs will appear in the terminal

## What Gets Filtered

✅ **Filtered (Hidden):**
- Samsung system messages (`MSHandlerLifeCycle`)
- Samsung system messages (`isMultiSplitHandlerRequested`)

❌ **NOT Filtered (Still Visible):**
- Flutter errors and exceptions
- Dart errors and warnings
- Stack traces
- All other Flutter/Dart logs
- Build output
- Hot reload messages

## How It Works

The scripts use Windows `findstr` command to filter log lines in real-time:
- `findstr /V` excludes lines matching the pattern
- `/C:"pattern"` matches the exact string
- `2>&1` redirects stderr to stdout so both are filtered

## Troubleshooting

**If the script doesn't work:**
1. Make sure you're in the project root directory
2. Ensure Flutter is installed and in your PATH
3. Try running `flutter run` first to verify Flutter works

**If you want to add more filters:**
Edit `run_clean.bat` and add more `findstr /V /C:"pattern"` filters:
```batch
flutter run 2>&1 | findstr /V /C:"MSHandlerLifeCycle" | findstr /V /C:"isMultiSplitHandlerRequested" | findstr /V /C:"AnotherSpamMessage"
```

## Notes

- The filtering happens in real-time as you run the app
- All Flutter errors and exceptions remain fully visible
- Only the specified Samsung spam messages are hidden
- The script works with hot reload and hot restart

