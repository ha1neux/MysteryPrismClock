# Orphan Instance Detection Fix

## Problem

The logs revealed that macOS was creating **two ScreenSaver instances** on a single-screen MacBook Pro:

1. **ScreenSaver[1]**: Created first but immediately abandoned
   - Never received `stopAnimation()` call
   - Never received `viewDidMoveToWindow(nil)` call
   - Never deallocated (`deinit` never called)
   - Its scheduled cleanup checks fired immediately after creation
   - **Likely stuck in memory forever** 🚨

2. **ScreenSaver[2]**: The actual working instance
   - Ran normally for ~7 seconds
   - Properly detected dismissal and cleaned up
   - Successfully deallocated

## Root Cause

The system creates instance [1], then immediately decides to create instance [2] instead, but:
- Never calls proper lifecycle methods on [1] to shut it down
- [1] remains in memory with its SwiftUI hosting view and view model
- This is a **memory leak** that happens every time the screen saver activates

## Solution

Added **orphan detection** to automatically clean up abandoned instances:

### 1. New Property
```swift
private var orphanDetectionTimer: Timer?  // Timer to detect if we're orphaned
```

### 2. Detection Logic
When `startAnimation()` is called, we start a 2-second timer:
- If the instance receives `animateOneFrame()` calls, it's marked as active and the timer is cancelled
- If 2 seconds pass with no `animateOneFrame()` calls, the instance is orphaned
- Orphaned instances automatically clean themselves up

### 3. Key Methods

#### `startOrphanDetection()`
- Called from `startAnimation()`
- Starts a 2-second timer
- If timer fires and `hasBeenVisible == false`, triggers cleanup

#### `cancelOrphanDetection()`
- Called when the instance is confirmed active (received `animateOneFrame()`)
- Called when cleanup happens through normal lifecycle
- Invalidates the timer to prevent false positives

#### Updated `animateOneFrame()`
- Now sets `hasBeenVisible = true` on first call
- Immediately cancels orphan detection when confirmed active

## What You'll See in Logs

### Before (Orphaned Instance):
```
[07:27:42.731] [main] [INFO] LIFECYCLE: ScreenSaver[1]: startAnimation
[07:27:42.853] [main] [INFO] === POST-DISMISSAL CHECK (5s) ===  // Too early!
[07:27:48.272] [main] [INFO] === POST-DISMISSAL CHECK (10s) === // No cleanup happened
// ... instance [1] never deallocates
```

### After (With Fix):
```
[HH:MM:SS] [main] [INFO] ScreenSaver[1]: Starting orphan detection timer (2 seconds)
[HH:MM:SS] [main] [WARNING] === ORPHANED INSTANCE DETECTED ===
[HH:MM:SS] [main] [WARNING] 🚨 ScreenSaver[1]: Instance was created but never received animateOneFrame calls
[HH:MM:SS] [main] [WARNING] ScreenSaver[1]: Forcing cleanup to prevent memory leak...
[HH:MM:SS] [main] [INFO] === CLEANUP STARTED ===
[HH:MM:SS] [main] [INFO] === CLEANUP COMPLETE ===
[HH:MM:SS] [main] [INFO] LIFECYCLE: ScreenSaver[1]: deinit - hasBeenVisible=false
```

## Benefits

✅ **Prevents memory leaks** from orphaned instances
✅ **Self-healing** - no manual intervention needed
✅ **Detailed logging** - you'll see exactly when and why instances are cleaned up
✅ **No impact on normal operation** - active instances immediately cancel the orphan timer

## Testing

To verify the fix is working:

1. Run the screen saver with Caps Lock enabled
2. Look for "Starting orphan detection timer" messages
3. Check if instance [1] now gets cleaned up and deallocated
4. Verify instance [2] runs normally without orphan detection triggering
5. Check Activity Monitor after dismissal - CPU should drop to 0%

## Technical Notes

- The 2-second timeout was chosen because:
  - Normal startup creates the SwiftUI view in ~0.2s
  - First `animateOneFrame()` call happens within 0.5s
  - 2 seconds provides ample margin while still being fast enough to prevent waste
  
- The timer runs on the main thread (via `scheduledTimer`) since all ScreenSaver methods run on main

- We track `hasBeenVisible` rather than just checking if `animateOneFrame()` was called because that's the true indicator of an active instance

- Timer is automatically invalidated in `deinit` as a safety measure
