# Mecha Invaders - Godot 4.6

A classic arcade-style Space Invaders game with a mecha twist, built with Godot Engine 4.6 as an educational project.

![Space Invaders](https://img.shields.io/badge/Godot-4.6-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 🎮 Features

- **Start Screen** - Title screen with animated instructions
- **Mecha Player** - Detailed mecha sprite with weapons and thrusters
- **10 Progressive Levels** - Increasing difficulty with more enemies and faster movement
- **Level Transitions** - "Get Ready!" screens between levels
- **Classic Gameplay** - Space Invaders mechanics with modern polish
- **Lives & Scoring System** - 3 lives with level completion bonuses
- **Clean Code** - Fully commented and educational
- **Comprehensive Documentation** - Beginner-friendly guide included

## 🚀 Quick Start

### Prerequisites

- Godot Engine 4.6 or later ([Download here](https://godotengine.org/download))

### How to Run

1. **Download or clone** this repository
2. **Open Godot Engine**
3. Click **Import** and select the `project.godot` file in this directory
4. Click **Import & Edit**
5. Press **F5** or click the ▶️ Play button to run the game

## 🕹️ How to Play

### Controls

- **A** or **Left Arrow** - Move left
- **D** or **Right Arrow** - Move right
- **Space** - Shoot / Start Game
- **R** - Restart (when game over)

### Objective

- **Destroy all aliens** in each level to progress
- **Complete 10 levels** of increasing difficulty
- **Avoid enemy bullets** and don't let aliens reach the bottom
- **Survive with 3 lives** across all levels
- **Earn bonus points** for completing each level (level × 100)

### Level Progression

Each level gets progressively harder:
- **Level 1**: 40 enemies, slow movement (easy)
- **Level 5**: 66 enemies, medium speed
- **Level 10**: 96 enemies, fast movement (challenging!)

### Scoring
- **10 points** per enemy destroyed
- **Level bonus**: level number × 100 (e.g., Level 5 = +500 points)
- **Total possible score**: 15,500+ points

## 📁 Project Structure

```
godot-arcane-game/
├── scenes/
│   ├── main.tscn           # Main game scene
│   ├── player.tscn         # Mecha player
│   ├── enemy.tscn          # Enemy alien
│   ├── bullet.tscn         # Bullet projectile
│   └── ui/
│       ├── start_screen.tscn    # Title/start screen
│       ├── level_transition.tscn # Level transition screen
│       └── hud.tscn        # User interface (score, lives, level)
├── scripts/
│   ├── main.gd             # Main scene coordinator and game flow
│   ├── player.gd           # Player movement and shooting
│   ├── enemy.gd            # Enemy behavior
│   ├── bullet.gd           # Bullet movement
│   ├── enemy_spawner.gd    # Enemy formation manager
│   ├── game_manager.gd     # Game state, scoring, and levels
│   ├── hud.gd              # UI updates
│   ├── start_screen.gd     # Start screen logic
│   └── level_transition.gd # Level transition logic
├── sprites/
│   ├── mecha_player.svg    # Detailed mecha sprite
│   ├── enemy_alien.svg     # Enemy sprite
│   └── bullet.svg          # Bullet sprite
├── BEGINNER_GUIDE.md       # Comprehensive tutorial
└── project.godot           # Godot project file
```

## 📚 Learning Resources

This project includes a **comprehensive beginner's guide** that explains:

- How Godot Engine works
- Node system and scene hierarchy
- GDScript programming basics
- Collision detection system
- Signal-based communication
- Step-by-step code walkthroughs
- How to modify and extend the game

**📖 [Read the Beginner's Guide](BEGINNER_GUIDE.md)**

Perfect for:
- Complete beginners to game development
- Developers new to Godot
- Anyone wanting to understand 2D game architecture

## 🎓 What You'll Learn

By studying this project, you'll understand:

1. **Godot Fundamentals**
   - Node-based architecture
   - Scene system
   - GDScript syntax

2. **Game Development Concepts**
   - Game loop (_process, _ready)
   - Input handling
   - Collision detection
   - State management

3. **Software Design Patterns**
   - Signal-driven architecture
   - Component-based design
   - Separation of concerns

4. **2D Game Mechanics**
   - Player movement
   - Projectile physics
   - Enemy AI (formation movement)
   - UI updates

## 🛠️ Customization

### Easy Modifications

**Change difficulty:**
```gdscript
# In game_manager.gd
var lives: int = 5  # Give more lives

# In player.gd
@export var speed: float = 600.0  # Make player faster

# In enemy_spawner.gd
@export var rows: int = 6  # Add more enemies
```

**Adjust gameplay:**
```gdscript
# In player.gd
@export var fire_rate: float = 0.3  # Shoot faster

# In enemy.gd
@export var points: int = 20  # Higher score per enemy
```

See [BEGINNER_GUIDE.md](BEGINNER_GUIDE.md) for detailed modification instructions.

## 🐛 Troubleshooting

### Common Issues

**Game won't start:**
- Ensure you're using Godot 4.6 or later
- Check the Output console for error messages

**No enemies appear:**
- Verify `enemy_scene` is assigned in EnemySpawner (Inspector panel)

**Player can't shoot:**
- Check `bullet_scene` is assigned in Player (Inspector panel)
- Verify input mappings in Project → Project Settings → Input Map

**More help:** See the [Troubleshooting section](BEGINNER_GUIDE.md#troubleshooting) in the Beginner's Guide

## 🤝 Contributing

This is an educational project. Feel free to:
- Fork and modify for your own learning
- Submit issues for bugs or improvements
- Share your modifications or extensions

## 📜 License

MIT License - feel free to use this project for learning, teaching, or as a base for your own games.

## 🙏 Acknowledgments

- Built with [Godot Engine](https://godotengine.org/)
- Inspired by the classic Space Invaders arcade game (Taito, 1978)
- Created as an educational resource for game development beginners

## 📬 Feedback

Learning Godot? Have questions about the code? Found the guide helpful?

- Open an issue for questions or bugs
- Share what you learned!
- Show us your modifications

---

**Happy coding! 🚀👾**

*Made with Godot 4.6*
