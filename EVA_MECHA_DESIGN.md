# Evangelion-Style Mecha Design

## Overview
Created a detailed 2D humanoid mecha inspired by Neon Genesis Evangelion's EVA units.

---

## Design Specifications

### Style
- **Type**: Humanoid bipedal mecha
- **View**: 2D front-facing
- **Inspiration**: Evangelion Unit-01
- **Size**: 64×64 pixels

### Color Scheme (EVA-01)
- **Primary**: Purple (#7B2D87) - Body armor
- **Secondary**: Green (#45B849) - Accents and details  
- **Dark**: Near-black (#2A1F3D) - Shoulders, neck, feet
- **Eyes**: Bright green (#0FFF00) - Iconic EVA glow
- **Accents**: Gold (#FFD700) - Energy core and horn
- **Weapon**: Silver/Gray with red tip

---

## Mecha Components

### Head
- Elliptical shape (purple)
- Two vertical green panels on sides (EVA characteristic)
- **Glowing green eyes** with black pupils (iconic EVA look)
- Mouth vent at bottom (black with green accent)
- Gold horn/antenna on top

### Torso
- Purple chest armor with black outlines
- Green triangular chest plate
- Orange/red energy core window in center
- Green horizontal vent lines on sides
- Gold energy core at waist

### Arms
- Purple upper arms
- Green accent bands
- Left arm holding weapon (progressive knife/gun)
- Black shoulder armor with green accents

### Legs
- Purple thigh sections
- Green knee accents
- Dark purple/black feet
- Stable standing pose

### Weapon
- Silver/gray rectangular blade/gun
- Red energy tip
- Held in left hand

### Energy Effects
- Glowing eyes (green with opacity)
- Core glow at waist (gold with opacity)
- Suggests active/powered state

---

## Technical Details

### File Information
- **Path**: `sprites/player_ship.svg`
- **Format**: SVG (Scalable Vector Graphics)
- **Size**: 3.3KB
- **Dimensions**: 64×64 pixels

### SVG Structure
- Uses basic shapes (rect, ellipse, polygon, circle, line)
- Black strokes for definition (0.5px width)
- Layered for proper depth
- Opacity effects for glowing elements

### Godot Integration
- Uses existing import file (player_ship.svg.import)
- Will auto-reload in Godot editor
- No additional configuration needed
- References in scenes/player.tscn

---

## Why This Design Works

### Recognizable
- Clearly a humanoid mecha
- EVA-01 inspired color scheme is iconic
- Distinctive head shape and glowing eyes

### 2D Game Friendly
- Clear silhouette at small scale
- High contrast colors
- Readable details even when scaled down
- Front-facing for space shooter gameplay

### Thematic
- Sci-fi/anime aesthetic
- Fits "Mecha Invaders" theme
- More interesting than generic triangle
- Appeals to EVA fans

---

## Viewing in Godot

### Steps
1. Open Godot 4.6
2. Import the project
3. If Godot was already open, reimport assets:
   - Right-click on `sprites/player_ship.svg` in FileSystem
   - Select "Reimport"
4. Press F5 to run game
5. Press SPACE on start screen

### Expected Result
You should see a purple and green humanoid mecha at the bottom center of the screen, standing in a ready pose with glowing green eyes and holding a weapon.

---

## Customization

### To Change Colors
Edit `sprites/player_ship.svg` and modify the `fill` attributes:

```svg
<!-- Current EVA-01 colors -->
fill="#7B2D87"  <!-- Purple body -->
fill="#45B849"  <!-- Green accents -->
fill="#0FFF00"  <!-- Bright green eyes -->

<!-- Example EVA-00 colors -->
fill="#4A90E2"  <!-- Blue body -->
fill="#FFFFFF"  <!-- White accents -->
fill="#FFD700"  <!-- Gold eyes -->
```

### To Add Details
You can add more SVG elements like:
- More armor plating
- Additional weapons
- Thruster effects
- Battle damage
- Unit markings

---

## Design Comparison

### Before (Triangle)
```
Simple green triangle
3 vertices, solid color
~100 bytes
```

### After (EVA Mecha)
```
Detailed humanoid mecha
70+ SVG elements
Multiple colors and effects
~3,300 bytes (3.3KB)
```

---

**Status**: ✅ Evangelion-style mecha complete and ready to view in Godot!

**Next**: Open in Godot to see the updated sprite in action!
