extends Node

# MechaSelector - Autoload Singleton
# Stores mecha definitions and current player selection

# Mecha type enum
enum MechaType { SCOUT, TANK, SPEED, BALANCED, ARTILLERY }

# Current selected mecha (default: BALANCED)
var selected_mecha: MechaType = MechaType.BALANCED

# Mecha data definitions
var mecha_data = {
	MechaType.SCOUT: {
		"name": "Light Scout",
		"display_name": "SCOUT",
		"sprite_path": "res://sprites/mecha_light_scout.svg",
		"description": "Fast and agile reconnaissance unit",
		"color": Color(0.12, 0.53, 0.9),  # Blue
		"stats": {
			"speed": 500,
			"fire_rate": 0.4,
			"lives_modifier": 0
		},
		"bullet": {
			"color": Color(0.3, 0.7, 1.0),   # Bright blue
			"scale": Vector2(0.7, 1.1),
			"speed": 900.0
		},
		"special": {
			"name": "RAPID BURST",
			"description": "Fires 5 bullets in rapid succession",
			"charges_needed": 8
		},
		"ultimate": {
			"name": "Hyper Beam",
			"display_name": "HYPER BEAM",
			"description": "Sustained laser that vaporizes everything in its path",
			"cooldown": 15.0
		},
		"weapon": {
			"name": "Beam Rifle",
			"display_name": "BEAM RIFLE",
			"description": "Long-range energy rifle — precise and powerful"
		}
	},
	MechaType.TANK: {
		"name": "Heavy Tank",
		"display_name": "TANK",
		"sprite_path": "res://sprites/mecha_heavy_tank.svg",
		"description": "Armored juggernaut with extra durability",
		"color": Color(0.78, 0.17, 0.17),  # Red
		"stats": {
			"speed": 250,
			"fire_rate": 0.7,
			"lives_modifier": 1  # +1 extra life
		},
		"bullet": {
			"color": Color(1.0, 0.2, 0.2),   # Bright red
			"scale": Vector2(2.0, 1.6),
			"speed": 300.0
		},
		"special": {
			"name": "HEAVY SHELL",
			"description": "Massive piercing shell that passes through enemies",
			"charges_needed": 5
		},
		"ultimate": {
			"name": "Gatling Storm",
			"display_name": "GATLING STORM",
			"description": "Unleashes a devastating spread of gatling fire across the screen",
			"cooldown": 12.0
		},
		"weapon": {
			"name": "Hyper Gatling",
			"display_name": "HYPER GATLING",
			"description": "Dual arm-mounted gatling cannons — shreds through armor"
		}
	},
	MechaType.SPEED: {
		"name": "Speed Interceptor",
		"display_name": "SPEED",
		"sprite_path": "res://sprites/mecha_speed_interceptor.svg",
		"description": "Ultra-fast glass cannon",
		"color": Color(0.98, 0.44, 0.0),  # Orange
		"stats": {
			"speed": 600,
			"fire_rate": 0.35,
			"lives_modifier": -1  # -1 life (glass cannon)
		},
		"bullet": {
			"color": Color(1.0, 0.65, 0.0),  # Orange
			"scale": Vector2(0.55, 0.85),
			"speed": 1100.0
		},
		"special": {
			"name": "TRIPLE SHOT",
			"description": "Fires 3 bullets in a spread pattern",
			"charges_needed": 10
		},
		"ultimate": {
			"name": "Blade Rush",
			"display_name": "BLADE RUSH",
			"description": "Launches spinning beam sabers across the full screen width",
			"cooldown": 10.0
		},
		"weapon": {
			"name": "Twin Beam Sabers",
			"display_name": "TWIN SABERS",
			"description": "Dual energy blades — lightning-fast close-range attacks"
		}
	},
	MechaType.BALANCED: {
		"name": "Balanced Standard",
		"display_name": "BALANCED",
		"sprite_path": "res://sprites/mecha_balanced_standard.svg",
		"description": "Versatile all-rounder for any situation",
		"color": Color(0.3, 0.69, 0.31),  # Green
		"stats": {
			"speed": 400,
			"fire_rate": 0.5,
			"lives_modifier": 0
		},
		"bullet": {
			"color": Color(0.3, 1.0, 0.4),   # Bright green
			"scale": Vector2(1.0, 1.0),
			"speed": 600.0
		},
		"special": {
			"name": "PIERCING ROUND",
			"description": "A bullet that passes through multiple enemies",
			"charges_needed": 8
		},
		"ultimate": {
			"name": "Mega Buster",
			"display_name": "MEGA BUSTER",
			"description": "Fires a massive charged blast that obliterates everything in a wide column",
			"cooldown": 18.0
		},
		"weapon": {
			"name": "Buster Cannon",
			"display_name": "BUSTER CANNON",
			"description": "Heavy shoulder cannon — massive firepower at range"
		}
	},
	MechaType.ARTILLERY: {
		"name": "Artillery Support",
		"display_name": "ARTILLERY",
		"sprite_path": "res://sprites/mecha_artillery_support.svg",
		"description": "Heavy weapons platform with firepower",
		"color": Color(0.67, 0.12, 0.94),  # Purple
		"stats": {
			"speed": 300,
			"fire_rate": 0.8,
			"lives_modifier": 1  # +1 extra life
		},
		"bullet": {
			"color": Color(0.8, 0.25, 1.0),  # Purple
			"scale": Vector2(2.2, 1.8),
			"speed": 250.0
		},
		"special": {
			"name": "BARRAGE",
			"description": "Fires 3 shells spread across the screen simultaneously",
			"charges_needed": 4
		},
		"ultimate": {
			"name": "Missile Rain",
			"display_name": "MISSILE RAIN",
			"description": "Carpet bombs the entire battlefield with a storm of missiles",
			"cooldown": 8.0
		},
		"weapon": {
			"name": "Dual Shoulder Pods",
			"display_name": "DUAL PODS",
			"description": "Twin shoulder artillery launchers — area bombardment"
		}
	}
}

func _ready() -> void:
	# Default to balanced mecha
	selected_mecha = MechaType.BALANCED

# Set the selected mecha
func set_selected_mecha(mecha_type: MechaType) -> void:
	selected_mecha = mecha_type
	print("MechaSelector: Selected ", get_mecha_name())

# Get the currently selected mecha type
func get_selected_mecha() -> MechaType:
	return selected_mecha

# Get full data for currently selected mecha
func get_selected_mecha_data() -> Dictionary:
	return mecha_data[selected_mecha]

# Get mecha data by type
func get_mecha_data(mecha_type: MechaType) -> Dictionary:
	return mecha_data[mecha_type]

# Get all mecha types (for iteration)
func get_all_mecha_types() -> Array:
	return [MechaType.SCOUT, MechaType.TANK, MechaType.SPEED, MechaType.BALANCED, MechaType.ARTILLERY]

# Helper: Get current mecha name
func get_mecha_name() -> String:
	return mecha_data[selected_mecha]["name"]

# Helper: Get current mecha sprite path
func get_mecha_sprite_path() -> String:
	return mecha_data[selected_mecha]["sprite_path"]

# Helper: Get current mecha stats
func get_mecha_stats() -> Dictionary:
	return mecha_data[selected_mecha]["stats"]

# Helper: Get specific stat value
func get_stat(stat_name: String):
	return mecha_data[selected_mecha]["stats"][stat_name]
