extends Node

# Quick test script to verify sprite loading
# Run this in Godot editor Script Editor to test

func _ready():
print("=== Testing Mecha Sprite Loading ===")

var sprite_paths = [
"res://sprites/mecha_light_scout.svg",
"res://sprites/mecha_heavy_tank.svg",
"res://sprites/mecha_speed_interceptor.svg",
"res://sprites/mecha_balanced_standard.svg",
"res://sprites/mecha_artillery_support.svg"
]

for path in sprite_paths:
print("\nTesting: ", path)
var texture = load(path)
if texture:
print("  ✓ Loaded successfully! Type: ", texture.get_class())
else:
print("  ✗ FAILED to load!")
# Try with ResourceLoader
texture = ResourceLoader.load(path)
if texture:
print("  ✓ ResourceLoader worked! Type: ", texture.get_class())
else:
print("  ✗ ResourceLoader also failed!")

print("\n=== Test Complete ===")
