# Space Invaders - Beginner's Guide to Godot Game Development

Welcome! This guide will walk you through how this Space Invaders game was built using Godot Engine 4.6. Whether you're completely new to game development or just new to Godot, this document will explain everything step-by-step.

---

## Table of Contents

1. [What is Godot Engine?](#what-is-godot-engine)
2. [Project Structure Overview](#project-structure-overview)
3. [Understanding Godot's Node System](#understanding-godots-node-system)
4. [GDScript Basics](#gdscript-basics)
5. [Scene Breakdown](#scene-breakdown)
6. [Script Walkthroughs](#script-walkthroughs)
7. [How the Game Loop Works](#how-the-game-loop-works)
8. [Collision System](#collision-system)
9. [Signals and Communication](#signals-and-communication)
10. [How to Modify and Extend](#how-to-modify-and-extend)
11. [Troubleshooting](#troubleshooting)

---

## What is Godot Engine?

**Godot Engine** is a free, open-source game engine that lets you create 2D and 3D games. It's:

- **Free and Open Source**: No licensing fees, ever
- **Lightweight**: Small download size (~50MB)
- **Node-based**: Everything in Godot is a "node" (like building blocks)
- **Scene System**: You build reusable scenes (like Lego sets)
- **GDScript**: Easy-to-learn Python-like programming language
- **Cross-platform**: Make games for Windows, Mac, Linux, mobile, web, and consoles

### Why Godot for this Project?

Godot is perfect for 2D arcade games like Space Invaders because:
- Built-in 2D physics and collision detection
- Visual scene editor
- Simple scripting with GDScript
- Fast iteration (test your game in seconds)

---

## Project Structure Overview

Here's how our game is organized:

```
godot-arcane-game/
├── project.godot          # Main project configuration file
├── scenes/                # All game scenes (.tscn files)
│   ├── main.tscn         # Main game scene (container for everything)
│   ├── player.tscn       # Player spaceship
│   ├── enemy.tscn        # Single enemy alien
│   ├── bullet.tscn       # Bullet (used by both player and enemies)
│   └── ui/
│       └── hud.tscn      # Heads-Up Display (score, lives, game over)
├── scripts/               # All game logic (.gd files)
│   ├── main.gd           # Connects all components together
│   ├── player.gd         # Player movement and shooting
│   ├── enemy.gd          # Enemy behavior
│   ├── bullet.gd         # Bullet movement
│   ├── enemy_spawner.gd  # Spawns and manages enemy formation
│   ├── game_manager.gd   # Tracks score, lives, game state
│   └── hud.gd            # Updates UI display
└── sprites/               # Visual assets (SVG images)
    ├── player_ship.svg   # Green triangle spaceship
    ├── enemy_alien.svg   # Red square alien
    └── bullet.svg        # Yellow bullet
```

### File Types Explained

- **`.tscn`** = Scene file (contains node hierarchy and properties)
- **`.gd`** = GDScript file (contains code/logic)
- **`.svg`** = Vector image (scalable graphics)
- **`project.godot`** = Configuration file (settings, input mappings, window size)

---

## Understanding Godot's Node System

### What is a Node?

A **node** is a basic building block in Godot. Everything is a node!

- `Node2D` - Has a 2D position (x, y)
- `Sprite2D` - Displays an image
- `Area2D` - Detects collisions
- `CollisionShape2D` - Defines collision boundaries
- `Label` - Shows text
- `Timer` - Counts down time

### Node Hierarchy (Tree Structure)

Nodes are organized in a **tree**:

```
Main (Node2D)
├── ColorRect (background)
├── Player (Area2D)
│   ├── Sprite2D
│   └── CollisionShape2D
├── EnemySpawner (Node2D)
│   └── [Spawns enemies here]
├── HUD (CanvasLayer)
│   └── [UI elements]
└── GameManager (Node)
```

**Parent-Child Relationships:**
- Child nodes move with their parent
- Children inherit parent transformations
- Children can access parent with `get_parent()`

---

## GDScript Basics

GDScript is Godot's programming language. It's similar to Python!

### Basic Syntax

```gdscript
# This is a comment

# Variables
var speed: float = 400.0
var lives: int = 3
var is_alive: bool = true

# Functions
func move_player(delta: float) -> void:
	position.x += speed * delta

# Conditions
if Input.is_action_pressed("move_left"):
	velocity.x -= 1

# Loops
for enemy in enemies:
	enemy.move()
```

### Key Concepts Used in This Game

#### 1. **Export Variables** (Inspector-Editable)
```gdscript
@export var speed: float = 400.0
```
The `@export` makes this variable editable in Godot's Inspector panel.

#### 2. **Signals** (Event System)
```gdscript
signal player_hit
# ...
player_hit.emit()  # Send signal
# ...
player.player_hit.connect(_on_player_hit)  # Receive signal
```

#### 3. **Process Functions** (Game Loop)
```gdscript
func _ready() -> void:
    # Called once when node enters the scene
    
func _process(delta: float) -> void:
    # Called every frame (60 times per second)
    # delta = time since last frame (usually 0.016s)
```

#### 4. **Type Hints**
```gdscript
var position: Vector2 = Vector2(0, 0)
func shoot() -> void:  # Returns nothing
```

---

## Scene Breakdown

### 🎮 Main Scene (`main.tscn`)

**Purpose**: Container that holds all game components

**Node Structure**:
```
Main (Node2D)
├── ColorRect (dark blue background)
├── Player (instanced scene)
├── EnemySpawner (manages all enemies)
├── HUD (user interface)
└── GameManager (game logic)
```

**What it does**:
- Connects all components via signals
- Starts the game
- Coordinates communication between player, enemies, and UI

---

### 🚀 Player Scene (`player.tscn`)

**Purpose**: The player's spaceship

**Node Structure**:
```
Player (Area2D)
├── Sprite2D (shows green triangle)
└── CollisionShape2D (detects hits)
```

**Properties**:
- **Collision Layer**: 1 (Player layer)
- **Collision Mask**: 8 (Can be hit by enemy bullets)

**What it does**:
- Moves left/right with keyboard
- Shoots bullets upward
- Detects when hit by enemy bullets

[🖼️ Screenshot placeholder: Player spaceship at bottom of screen]

---

### 👾 Enemy Scene (`enemy.tscn`)

**Purpose**: A single alien enemy

**Node Structure**:
```
Enemy (Area2D)
├── Sprite2D (shows red alien)
└── CollisionShape2D (detects hits)
```

**Properties**:
- **Collision Layer**: 2 (Enemy layer)
- **Collision Mask**: 4 (Can be hit by player bullets)

**What it does**:
- Moves in formation with other enemies
- Can be destroyed by player bullets
- Awards points when destroyed

[🖼️ Screenshot placeholder: Grid of enemy aliens]

---

### 💥 Bullet Scene (`bullet.tscn`)

**Purpose**: Projectile fired by player or enemies

**Node Structure**:
```
Bullet (Area2D)
├── Sprite2D (shows yellow bullet)
└── CollisionShape2D (for impact detection)
```

**Two Types**:
1. **Player Bullet**: Shoots up, collides with enemies
2. **Enemy Bullet**: Shoots down, collides with player

**What it does**:
- Moves in a straight line
- Destroys itself when hitting something or leaving screen

---

### 📊 HUD Scene (`hud.tscn`)

**Purpose**: Display score, lives, and game over screen

**Node Structure**:
```
HUD (CanvasLayer)
├── MarginContainer
│   └── VBoxContainer
│       ├── ScoreLabel ("Score: 0")
│       └── LivesLabel ("Lives: 3")
└── GameOverPanel
	└── VBoxContainer
		├── MessageLabel ("GAME OVER" or "YOU WIN!")
		├── ScoreLabel ("Final Score: X")
		└── RestartLabel ("Press R to Restart")
```

**What it does**:
- Shows current score and lives
- Displays game over screen when game ends
- Updates in real-time

[🖼️ Screenshot placeholder: HUD showing score and lives]

---

## Script Walkthroughs

### Player Script (`player.gd`)

Let's break down the player script line by line:

```gdscript
extends Area2D
```
**What it means**: This script controls an `Area2D` node (collision detection zone)

```gdscript
@export var speed: float = 400.0
```
**What it means**: Player movement speed (pixels per second). The `@export` lets you change this in the Godot editor without editing code.

```gdscript
@export var bullet_scene: PackedScene
```
**What it means**: Reference to the bullet scene file. We'll instantiate (create) bullets from this.

```gdscript
var can_shoot: bool = true
```
**What it means**: Prevents shooting too fast (fire rate limiter)

#### Movement Code

```gdscript
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		position += velocity * delta
```

**Line-by-line**:
1. `_process()` runs every frame
2. `delta` = time since last frame (keeps movement smooth at any FPS)
3. `Vector2.ZERO` = (0, 0)
4. Check if left/right keys are pressed
5. Normalize velocity (make it length 1) then multiply by speed
6. Update position: `position += velocity * delta`

**Why `* delta`?**
- Ensures consistent speed regardless of framerate
- If running at 60 FPS, delta ≈ 0.016 seconds
- If running at 30 FPS, delta ≈ 0.033 seconds
- Movement distance = speed × time

#### Boundary Checking

```gdscript
position.x = clamp(position.x, 32, screen_size.x - 32)
```

**What it does**: Keeps player on screen
- `clamp(value, min, max)` restricts value between min and max
- Player can't go past x=32 or x=1048 (screen width - 32)

#### Shooting Code

```gdscript
func shoot() -> void:
    can_shoot = false
    
    var bullet = bullet_scene.instantiate()
    bullet.position = position + Vector2(0, -20)
    bullet.direction = Vector2.UP
    bullet.collision_layer = 4
    bullet.collision_mask = 2
    bullet.add_to_group("player_bullet")
    
    get_parent().add_child(bullet)
    
    bullet_fired.emit()
    
    await get_tree().create_timer(fire_rate).timeout
    can_shoot = true
```

**Line-by-line**:
1. Prevent shooting again immediately
2. Create new bullet instance
3. Position bullet above player (y - 20)
4. Set direction to UP (negative y)
5. Set collision layers (explained in [Collision System](#collision-system))
6. Add to "player_bullet" group for identification
7. Add bullet to scene tree (makes it active)
8. Emit signal (for sound effects, etc.)
9. Wait for `fire_rate` seconds (cooldown)
10. Allow shooting again

---

### Enemy Script (`enemy.gd`)

```gdscript
extends Area2D

var direction: int = 1  # 1 = right, -1 = left
```

#### Movement

```gdscript
func move_horizontal(delta: float) -> void:
    position.x += direction * move_speed * delta
```

Simple left/right movement. Direction is controlled by the spawner.

#### Reversing Direction

```gdscript
func reverse_direction() -> void:
    direction *= -1         # Flip direction
    position.y += descent_amount  # Move down
    
    if position.y > get_viewport_rect().size.y - 100:
        enemy_reached_bottom.emit()
```

**What happens**:
1. When hitting screen edge, flip direction (right→left or left→right)
2. Move down by `descent_amount` pixels
3. If too far down, signal game over

#### Collision Detection

```gdscript
func _on_area_entered(area: Area2D) -> void:
    if area.is_in_group("player_bullet"):
        area.queue_free()  # Destroy bullet
        destroy()          # Destroy enemy
```

**How it works**:
- `area_entered` signal fires when something enters this enemy's collision zone
- Check if it's a player bullet (using groups)
- Destroy both bullet and enemy

---

### Enemy Spawner Script (`enemy_spawner.gd`)

#### Spawning Formation

```gdscript
func spawn_enemies() -> void:
    for row in range(rows):  # 4 rows
        for col in range(columns):  # 10 columns
            var enemy = enemy_scene.instantiate()
            var pos = start_position + Vector2(col * spacing.x, row * spacing.y)
            enemy.position = pos
            # ... connect signals, add to scene ...
            enemies.append(enemy)
```

**Creates a grid**:
- Nested loops: outer for rows, inner for columns
- Calculate position: start + (column × horizontal_spacing, row × vertical_spacing)
- Example: Enemy at row 2, col 3 = (100 + 3×80, 100 + 2×60) = (340, 220)

#### Group Movement

```gdscript
func _process(delta: float) -> void:
    edge_reached = false
    
    for enemy in enemies:
        if enemy and is_instance_valid(enemy):
            enemy.move_horizontal(delta)
            
            if (enemy.position.x <= 40 and move_direction == -1) or \
               (enemy.position.x >= screen_width - 40 and move_direction == 1):
                edge_reached = true
    
    if edge_reached:
        move_direction *= -1
        for enemy in enemies:
            if enemy and is_instance_valid(enemy):
                enemy.direction = move_direction
                enemy.reverse_direction()
```

**Logic flow**:
1. Move all enemies
2. Check if ANY enemy hit screen edge
3. If edge hit, reverse ALL enemies and move down

#### Random Shooting

```gdscript
func _on_shoot_timer_timeout() -> void:
    if enemies.size() > 0 and enemy_bullet_scene:
        var valid_enemies = enemies.filter(func(e): return e != null and is_instance_valid(e))
        if valid_enemies.size() > 0:
            var random_enemy = valid_enemies[randi() % valid_enemies.size()]
            shoot_from_enemy(random_enemy)
```

**How it works**:
1. Timer fires every `shoot_interval` seconds (default: 2s)
2. Filter out destroyed enemies
3. Pick random remaining enemy
4. Make that enemy shoot

---

### Game Manager Script (`game_manager.gd`)

#### Game States

```gdscript
enum GameState { MENU, PLAYING, GAME_OVER, WIN }
var current_state: GameState = GameState.MENU
```

**State Machine**:
- MENU: Before game starts
- PLAYING: Active gameplay
- GAME_OVER: Player lost
- WIN: All enemies destroyed

#### Score and Lives

```gdscript
func add_score(points: int) -> void:
    score += points
    score_changed.emit(score)

func lose_life() -> void:
    lives -= 1
    lives_changed.emit(lives)
    
    if lives <= 0:
        end_game(false)
```

**Signal pattern**:
1. Update internal value
2. Emit signal with new value
3. HUD listens to signal and updates display

---

## How the Game Loop Works

### Initialization (_ready)

1. **Main scene loads** → All child scenes instantiate
2. **Connections made** → Signals linked between components
3. **Game starts** → `game_manager.start_game()` called
4. **Enemies spawn** → Formation created
5. **Ready to play** → Waiting for input

### Every Frame (_process)

60 times per second (at 60 FPS):

```
1. Check player input
   ├── Move player left/right
   └── Shoot if space pressed
   
2. Move all bullets
   ├── Player bullets move up
   └── Enemy bullets move down
   
3. Move all enemies
   ├── Move horizontally
   ├── Check for edge collision
   └── Reverse if edge hit
   
4. Check collisions
   ├── Player bullets vs enemies
   ├── Enemy bullets vs player
   └── Trigger appropriate responses
   
5. Update UI
   └── HUD reflects current score/lives
```

### Event Flow Example

**Scenario: Player shoots and hits an enemy**

```
1. Player presses SPACE
   ↓
2. player.gd: shoot() function called
   ↓
3. Bullet instantiated at player position
   ↓
4. Bullet added to scene, moves upward
   ↓
5. Bullet enters enemy's Area2D
   ↓
6. enemy.gd: _on_area_entered() triggered
   ↓
7. Enemy checks if area is player_bullet
   ↓
8. Enemy emits enemy_destroyed signal with points
   ↓
9. main.gd receives signal, calls game_manager.add_score()
   ↓
10. game_manager.gd adds points, emits score_changed
	↓
11. hud.gd receives score_changed, updates label
	↓
12. Player sees updated score!
```

---

## Collision System

### Collision Layers Explained

Godot uses **layers** and **masks** for collision detection:

**4 Layers in our game:**
1. **Layer 1**: Player
2. **Layer 2**: Enemy
3. **Layer 3**: Player Bullets
4. **Layer 4**: Enemy Bullets

### How It Works

Each object has:
- **Collision Layer**: "I am on this layer"
- **Collision Mask**: "I can collide with these layers"

### Examples

**Player**:
- Layer: 1 (I am Player)
- Mask: 8 (I collide with layer 4 = Enemy Bullets)

**Player Bullet**:
- Layer: 4 (I am Player Bullet)
- Mask: 2 (I collide with layer 2 = Enemies)

**Enemy**:
- Layer: 2 (I am Enemy)
- Mask: 4 (I collide with layer 3 = Player Bullets)

### Visual Representation

```
┌─────────────┐         ┌─────────────┐
│   PLAYER    │ ←─X─X─→ │   ENEMY     │
│  (Layer 1)  │         │  (Layer 2)  │
└─────────────┘         └─────────────┘
	   ↑                       ↑
	   │                       │
	hits by                 hits by
	   │                       │
	   ↓                       ↓
┌─────────────┐         ┌─────────────┐
│ ENEMY BULLET│         │PLAYER BULLET│
│  (Layer 4)  │         │  (Layer 3)  │
└─────────────┘         └─────────────┘
```

**Why this matters**:
- Player bullets can't hit the player
- Enemy bullets can't hit enemies
- Enemies and player don't physically collide

---

## Signals and Communication

### What are Signals?

Signals are Godot's **event system** — they let nodes communicate without tight coupling.

### Signal Pattern

**Step 1: Define signal**
```gdscript
signal player_hit
```

**Step 2: Emit signal when event happens**
```gdscript
player_hit.emit()
```

**Step 3: Connect signal to function**
```gdscript
player.player_hit.connect(_on_player_hit)
```

**Step 4: Handle signal**
```gdscript
func _on_player_hit() -> void:
	game_manager.lose_life()
```

### Signals in Our Game

```
Player
├─ player_hit → main → game_manager.lose_life()
└─ bullet_fired → (could play sound effect)

Enemy
├─ enemy_destroyed(points) → main → game_manager.add_score(points)
└─ enemy_reached_bottom → main → game_manager.end_game(false)

EnemySpawner
├─ all_enemies_destroyed → main → game_manager.end_game(true)
└─ enemy_reached_player → main → game_manager.end_game(false)

GameManager
├─ score_changed(score) → hud.update_score(score)
├─ lives_changed(lives) → hud.update_lives(lives)
├─ game_over → main._on_game_over() → hud.show_game_over()
└─ game_won → main._on_game_won() → hud.show_game_over()
```

**Benefits**:
- Decoupled code (player doesn't need to know about game manager)
- Easy to add new listeners
- Clear event flow

---

## How to Modify and Extend

### Make the Game Easier/Harder

**Increase player lives:**
```gdscript
# In game_manager.gd
var lives: int = 5  # Change from 3 to 5
```

**Make player faster:**
```gdscript
# In player.gd or in Godot Inspector
@export var speed: float = 600.0  # Increased from 400
```

**Increase fire rate:**
```gdscript
# In player.gd
@export var fire_rate: float = 0.3  # Decreased from 0.5 (faster)
```

**Make enemies move faster:**
```gdscript
# In enemy.gd or Inspector
@export var move_speed: float = 100.0  # Increased from 50
```

**Add more enemies:**
```gdscript
# In enemy_spawner.gd or Inspector
@export var rows: int = 6  # Increased from 4
@export var columns: int = 12  # Increased from 10
```

---

### Add New Features

#### 1. Add a Power-Up

**Create power-up scene:**
```gdscript
# powerup.gd
extends Area2D

signal powerup_collected(type: String)

func _on_area_entered(area: Area2D) -> void:
    if area.is_in_group("player"):
        powerup_collected.emit("rapid_fire")
        queue_free()
```

**Modify player to handle power-up:**
```gdscript
# In player.gd
var has_rapid_fire: bool = false

func activate_rapid_fire() -> void:
    has_rapid_fire = true
    fire_rate = 0.1  # Much faster
    await get_tree().create_timer(10.0).timeout
    has_rapid_fire = false
    fire_rate = 0.5  # Back to normal
```

#### 2. Add Sound Effects

**In player.gd:**
```gdscript
@export var shoot_sound: AudioStream

func shoot() -> void:
    # ... existing code ...
    $AudioStreamPlayer.stream = shoot_sound
    $AudioStreamPlayer.play()
```

#### 3. Add Explosion Animation

**In enemy.gd:**
```gdscript
func destroy() -> void:
    # Create explosion effect
    var explosion = preload("res://scenes/explosion.tscn").instantiate()
    explosion.position = position
    get_parent().add_child(explosion)
    
    enemy_destroyed.emit(points)
    queue_free()
```

#### 4. Add Multiple Enemy Types

Different colored enemies with different points:

```gdscript
# In enemy.gd
@export var enemy_type: String = "basic"

func _ready() -> void:
    match enemy_type:
        "basic":
            points = 10
            $Sprite2D.modulate = Color.RED
        "advanced":
            points = 20
            $Sprite2D.modulate = Color.PURPLE
        "boss":
            points = 50
            $Sprite2D.modulate = Color.ORANGE
            move_speed = 30.0
```

---

## Troubleshooting

### Common Issues

#### 1. "Node not found" error

**Problem**: Script can't find a node reference
```gdscript
@onready var hud = $HUD  # Error: Invalid get index 'HUD'
```

**Solution**: Check node names match exactly (case-sensitive)
```gdscript
@onready var hud = $HUD  # Node must be named exactly "HUD"
```

#### 2. Bullets not colliding

**Problem**: Bullets pass through enemies

**Solutions**:
- Check collision layers/masks are set correctly
- Ensure CollisionShape2D is added to bullet scene
- Verify `area_entered` signal is connected

#### 3. Player can't shoot

**Problem**: Pressing space does nothing

**Solutions**:
- Check `bullet_scene` is assigned in Inspector
- Verify "shoot" action is mapped in Project Settings → Input Map
- Check `can_shoot` variable isn't stuck as `false`

#### 4. Enemies not spawning

**Problem**: Game starts but no enemies appear

**Solutions**:
- Check `enemy_scene` is assigned to EnemySpawner in Inspector
- Look for errors in Output console
- Verify `spawn_enemies()` is called in `_ready()`

#### 5. Game won't restart

**Problem**: Pressing R doesn't restart

**Solutions**:
- Check "restart" action is mapped in Input Map
- Verify `_input()` function in game_manager.gd is working
- Check current_state allows restart

---

### Debugging Tips

#### Use Print Statements

```gdscript
print("Player position:", position)
print("Enemies remaining:", enemies.size())
print("Current state:", current_state)
```

#### Use the Debugger

1. Click play icon at top-right in Godot
2. Set breakpoints (click left of line numbers)
3. Inspect variables when paused

#### Check the Output Console

- Godot shows errors in red at bottom
- Warning in yellow
- Your print() statements appear here

---

## Next Steps

Congratulations! You now understand how this Space Invaders game works. Here are some challenges:

### Beginner Challenges
- [ ] Change the colors of sprites
- [ ] Adjust game difficulty (speed, lives, enemy count)
- [ ] Add a "Start Game" screen before playing
- [ ] Display high score

### Intermediate Challenges
- [ ] Add sound effects and background music
- [ ] Create particle effects for explosions
- [ ] Add enemy formations that move in patterns
- [ ] Implement multiple levels with increasing difficulty
- [ ] Add different enemy types with different behaviors

### Advanced Challenges
- [ ] Add boss enemies with health bars
- [ ] Create power-ups (shields, rapid fire, spread shot)
- [ ] Add obstacle barriers like classic Space Invaders
- [ ] Implement enemy AI that aims at player
- [ ] Add online leaderboards

---

## Additional Resources

### Official Godot Documentation
- [Godot 4 Documentation](https://docs.godotengine.org/en/stable/)
- [GDScript Basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
- [2D Movement Tutorial](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)

### Tutorials
- [Godot Your First 2D Game](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html)
- [GDQuest Free Godot Tutorials](https://www.gdquest.com/)
- [HeartBeast YouTube Channel](https://www.youtube.com/@uheartbeast)

### Community
- [Godot Discord](https://discord.gg/godotengine)
- [Godot Reddit](https://www.reddit.com/r/godot/)
- [Godot Forums](https://godotengine.org/community/forums/)

---

## Glossary

**Area2D**: A node that detects when other areas or bodies enter/exit its collision shape

**CollisionShape2D**: Defines the shape used for collision detection

**delta**: Time elapsed since the previous frame (in seconds)

**emit**: Send a signal to all connected listeners

**instantiate**: Create a new instance of a scene or object

**Node**: Basic building block in Godot; everything inherits from Node

**PackedScene**: A saved scene that can be instantiated multiple times

**Signal**: Event notification system in Godot

**Sprite2D**: Node that displays a 2D texture/image

**Vector2**: 2D vector (x, y coordinates)

---

**Made with ❤️ using Godot 4.6**

*Happy game development!* 🎮
