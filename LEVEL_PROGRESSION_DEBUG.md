# Level Progression Bug - Debug Version

## Issue Reported
After defeating all enemy ships, the game doesn't continue to the next level.

## Changes Made
Added debug print() statements to track where the signal flow breaks.

## How to Test in Godot

1. Open Godot and press F5 to run
2. Watch the Output console (bottom panel)
3. Destroy all enemies in level 1
4. Check which messages appear

## Expected Console Output
```
Enemy destroyed! Remaining enemies: 39
Enemy destroyed! Remaining enemies: 38
...
Enemy destroyed! Remaining enemies: 0
All enemies destroyed! Emitting signal...
Main: All enemies destroyed signal received!
GameManager: complete_level() called
GameManager: Moving to level 2
Main: Level complete signal received!
```

If messages stop at any point, that's where the bug is!

Ready to test in Godot!
