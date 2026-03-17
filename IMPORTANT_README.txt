================================================================================
⚠️  IMPORTANT: HOW TO SEE THE EVA MECHA (NOT GREEN TRIANGLE) ⚠️
================================================================================

THE PROBLEM:
- The SVG file contains the EVA mecha (verified 3.3KB) ✅
- Godot is using an old cached version (green triangle) ❌

THE SOLUTION (FOLLOW THESE STEPS):

STEP 1: Close Godot Completely
--------------------------------
- If Godot is currently running, close it 100%
- On Mac: Press Cmd+Q
- On Windows/Linux: File → Quit
- IMPORTANT: Don't just close the window, quit the entire application!

STEP 2: Delete the Cache Folder
--------------------------------
Open Terminal and run this command:

cd /Users/simonepiccirilli/Desktop/godot-arcane-game
rm -rf .godot

This deletes all cached imports. Godot will rebuild them fresh.

STEP 3: Reopen Godot
---------------------
- Launch Godot 4.6
- Open the project again
- Wait for it to reimport all assets (30 seconds)
- You'll see "Importing..." in the bottom right

STEP 4: Run the Game
---------------------
- Press F5
- Press SPACE on start screen  
- You should now see: Purple and green EVA-01 style mecha! 🤖

================================================================================

ALTERNATIVE (If Step 2 doesn't work):

In Godot:
1. Go to Project → Tools → Orphan Resource Explorer
2. Click "Scan"
3. Delete orphaned resources
4. Project → Reimport Assets

================================================================================

TO VERIFY THE SVG IS CORRECT:

Open this file in a web browser:
/Users/simonepiccirilli/Desktop/godot-arcane-game/sprites/player_ship.svg

You should see a purple and green humanoid robot (not a triangle).
If you see the robot in the browser, the file is correct!

================================================================================

WHY THIS HAPPENS:

Godot caches imported textures in the .godot/imported/ folder for performance.
When we edit files outside of Godot (via command line), Godot doesn't always
detect the change and keeps using the old cache.

Deleting .godot forces a complete fresh reimport.

================================================================================
