extends Area2D

# Player ship script - handles movement, shooting, collision, special moves, and ultimate weapons

@export var speed: float = 400.0
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.5
var can_shoot: bool = true

# Mecha-specific bullet appearance
var mecha_bullet_color: Color = Color.WHITE
var mecha_bullet_scale: Vector2 = Vector2(1.0, 1.0)
var mecha_bullet_speed: float = 600.0

# Special move charge system
var special_charge: int = 0
var special_charges_needed: int = 8
var can_use_special: bool = false
var mecha_special_name: String = "SPECIAL"

# Ultimate weapon cooldown system
var ultimate_cooldown_remaining: float = 0.0
var ultimate_cooldown_max: float = 15.0
var can_use_ultimate: bool = true
var mecha_ultimate_name: String = "ULTIMATE"

var screen_size: Vector2

signal player_hit
signal bullet_fired
signal special_charge_changed(current: int, needed: int, is_ready: bool)
signal ultimate_cooldown_changed(remaining: float, max_val: float, is_ready: bool)

@onready var sprite = $Sprite2D

# --- Animation state ---------------------------------------------------------
var _hover_time: float = 0.0
var _tilt_current: float = 0.0   # current sprite rotation for tilt (radians)
var _recoil_y: float = 0.0       # downward offset when firing
var _rotation_override: float = 0.0  # extra rotation for shake effects
var _base_scale: Vector2 = Vector2(0.6, 0.6)
var _recoil_tween: Tween
var _flash_tween: Tween
var _pulse_tween: Tween
var _anim: Dictionary = {}

# Per-mecha animation parameters (tuned to each mecha's personality)
func _build_anim_params() -> Dictionary:
	match MechaSelector.get_selected_mecha():
		MechaSelector.MechaType.SCOUT:
			# Nimble, quick oscillation, aggressive tilt
			return { "hover_amp": 4.0, "hover_speed": 4.5, "tilt_max": 14.0, "tilt_speed": 12.0, "recoil": 7.0 }
		MechaSelector.MechaType.TANK:
			# Heavy, slow sway, minimal tilt
			return { "hover_amp": 2.0, "hover_speed": 1.5, "tilt_max": 5.0,  "tilt_speed": 4.0,  "recoil": 13.0 }
		MechaSelector.MechaType.SPEED:
			# Very fast flutter, maximum tilt
			return { "hover_amp": 3.5, "hover_speed": 6.0, "tilt_max": 20.0, "tilt_speed": 16.0, "recoil": 5.0 }
		MechaSelector.MechaType.BALANCED:
			# Smooth, steady, moderate everything
			return { "hover_amp": 3.0, "hover_speed": 2.5, "tilt_max": 10.0, "tilt_speed": 8.0,  "recoil": 8.0 }
		MechaSelector.MechaType.ARTILLERY:
			# Very slow, ponderous sway
			return { "hover_amp": 2.5, "hover_speed": 1.2, "tilt_max": 4.0,  "tilt_speed": 3.5,  "recoil": 15.0 }
		_:
			return { "hover_amp": 3.0, "hover_speed": 2.5, "tilt_max": 10.0, "tilt_speed": 8.0,  "recoil": 8.0 }

func _ready() -> void:
	add_to_group("player")
	apply_mecha_stats()
	screen_size = get_viewport_rect().size
	area_entered.connect(_on_area_entered)

func apply_mecha_stats() -> void:
	var mecha_data = MechaSelector.get_selected_mecha_data()
	var stats = mecha_data["stats"]

	speed = stats["speed"]
	fire_rate = stats["fire_rate"]

	var bullet_data = mecha_data["bullet"]
	mecha_bullet_color = bullet_data["color"]
	mecha_bullet_scale = bullet_data["scale"]
	mecha_bullet_speed = bullet_data["speed"]

	var special_data = mecha_data["special"]
	special_charges_needed = special_data["charges_needed"]
	mecha_special_name = special_data["name"]

	var ultimate_data = mecha_data["ultimate"]
	ultimate_cooldown_max = ultimate_data["cooldown"]
	mecha_ultimate_name = ultimate_data["name"]

	special_charge = 0
	can_use_special = false
	ultimate_cooldown_remaining = 0.0
	can_use_ultimate = true

	var texture = load(mecha_data["sprite_path"])
	if texture and sprite:
		sprite.texture = texture
		sprite.scale = _base_scale

	_anim = _build_anim_params()
	# Reset animation state when mecha changes
	_hover_time = 0.0
	_tilt_current = 0.0
	_recoil_y = 0.0
	_rotation_override = 0.0
	if sprite:
		sprite.position = Vector2.ZERO
		sprite.rotation = 0.0
		sprite.modulate = Color.WHITE
		sprite.scale = _base_scale

	print("Player: Applied ", mecha_data["name"], " | Special: ", mecha_special_name, " | Ultimate: ", mecha_ultimate_name)

# --- MOVEMENT & INPUT ---------------------------------------------------------
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1

	if velocity.length() > 0:
		position += velocity.normalized() * speed * delta

	position.x = clamp(position.x, 32, screen_size.x - 32)

	if Input.is_action_pressed("shoot") and can_shoot and bullet_scene:
		shoot()

	if Input.is_action_just_pressed("special") and can_use_special:
		use_special()

	if Input.is_action_just_pressed("ultimate") and can_use_ultimate:
		use_ultimate()

	if not can_use_ultimate:
		ultimate_cooldown_remaining -= delta
		if ultimate_cooldown_remaining <= 0.0:
			ultimate_cooldown_remaining = 0.0
			can_use_ultimate = true
		ultimate_cooldown_changed.emit(ultimate_cooldown_remaining, ultimate_cooldown_max, can_use_ultimate)

	_update_visual_animations(delta, velocity)

# --- VISUAL ANIMATIONS -------------------------------------------------------
func _update_visual_animations(delta: float, velocity: Vector2) -> void:
	if not sprite:
		return

	# Idle hover: gentle up/down oscillation via sprite local position
	_hover_time += delta
	var hover_y = sin(_hover_time * _anim["hover_speed"]) * _anim["hover_amp"]

	# Movement tilt: lean into the direction of travel
	var target_tilt = 0.0
	if velocity.x < 0:
		target_tilt = -deg_to_rad(_anim["tilt_max"])
	elif velocity.x > 0:
		target_tilt = deg_to_rad(_anim["tilt_max"])
	# Exponential smoothing for organic tilt feel
	_tilt_current = lerp(_tilt_current, target_tilt, 1.0 - exp(-_anim["tilt_speed"] * delta))

	sprite.position.y = hover_y + _recoil_y
	sprite.rotation = _tilt_current + _rotation_override

# Recoil: brief backward lurch on every shot
func _animate_shoot_recoil() -> void:
	if _recoil_tween:
		_recoil_tween.kill()
	_recoil_y = 0.0
	_recoil_tween = create_tween()
	_recoil_tween.tween_property(self, "_recoil_y", _anim["recoil"], 0.04)
	_recoil_tween.tween_property(self, "_recoil_y", 0.0, 0.12)

# Hit flash: red pulse when taking damage
func _animate_hit_flash() -> void:
	if _flash_tween:
		_flash_tween.kill()
	sprite.modulate = Color.WHITE
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "modulate", Color(1.0, 0.1, 0.1, 1.0), 0.05)
	_flash_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.18)

# Special activation: mecha-colored flash + quick scale pulse
func _animate_special() -> void:
	var c = MechaSelector.get_selected_mecha_data()["color"]
	var bright = Color(minf(c.r * 2.2, 1.0), minf(c.g * 2.2, 1.0), minf(c.b * 2.2, 1.0), 1.0)
	if _pulse_tween:
		_pulse_tween.kill()
	sprite.scale = _base_scale
	sprite.modulate = Color.WHITE
	_pulse_tween = create_tween()
	_pulse_tween.tween_property(sprite, "scale", _base_scale * 1.25, 0.07)
	_pulse_tween.parallel().tween_property(sprite, "modulate", bright, 0.07)
	_pulse_tween.tween_property(sprite, "scale", _base_scale, 0.22)
	_pulse_tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.22)

# Ultimate activation: dramatic screen-shake-like burst + bright flash + rotation shudder
func _animate_ultimate() -> void:
	var c = MechaSelector.get_selected_mecha_data()["color"]
	var burst = Color(minf(c.r * 3.5, 1.0), minf(c.g * 3.5, 1.0), minf(c.b * 3.5, 1.0), 1.0)
	if _pulse_tween:
		_pulse_tween.kill()
	sprite.scale = _base_scale
	sprite.modulate = Color.WHITE
	_rotation_override = 0.0
	_pulse_tween = create_tween()
	# Big scale-up + color burst
	_pulse_tween.tween_property(sprite, "scale", _base_scale * 1.6, 0.07)
	_pulse_tween.parallel().tween_property(sprite, "modulate", burst, 0.07)
	# Rapid rotation shudder (tweens _rotation_override so tilt still works)
	_pulse_tween.tween_property(self, "_rotation_override", deg_to_rad(6.0),  0.05)
	_pulse_tween.tween_property(self, "_rotation_override", deg_to_rad(-6.0), 0.05)
	_pulse_tween.tween_property(self, "_rotation_override", deg_to_rad(4.0),  0.04)
	_pulse_tween.tween_property(self, "_rotation_override", deg_to_rad(-4.0), 0.04)
	_pulse_tween.tween_property(self, "_rotation_override", 0.0, 0.04)
	# Settle back to normal
	_pulse_tween.tween_property(sprite, "scale", _base_scale, 0.25)
	_pulse_tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.25)

# --- NORMAL SHOOTING ----------------------------------------------------------
func shoot() -> void:
	can_shoot = false

	_fire_bullet(Vector2(0, -20), Vector2.UP, mecha_bullet_color, mecha_bullet_scale, mecha_bullet_speed)
	_animate_shoot_recoil()

	if not can_use_special:
		special_charge += 1
		if special_charge >= special_charges_needed:
			special_charge = special_charges_needed
			can_use_special = true
		special_charge_changed.emit(special_charge, special_charges_needed, can_use_special)

	bullet_fired.emit()

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

# --- SPECIAL MOVES ------------------------------------------------------------
func use_special() -> void:
	can_use_special = false
	special_charge = 0
	special_charge_changed.emit(0, special_charges_needed, false)
	_animate_special()

	match MechaSelector.get_selected_mecha():
		MechaSelector.MechaType.SCOUT:
			_special_rapid_burst()
		MechaSelector.MechaType.TANK:
			_special_heavy_shell()
		MechaSelector.MechaType.SPEED:
			_special_triple_shot()
		MechaSelector.MechaType.BALANCED:
			_special_piercing_round()
		MechaSelector.MechaType.ARTILLERY:
			_special_barrage()

# SCOUT - 5 fast bullets in quick succession
func _special_rapid_burst() -> void:
	for i in range(5):
		_fire_bullet(Vector2(0, -20), Vector2.UP,
				mecha_bullet_color, mecha_bullet_scale * 1.2, mecha_bullet_speed * 1.3)
		await get_tree().create_timer(0.08).timeout

# TANK - one massive piercing shell
func _special_heavy_shell() -> void:
	_fire_bullet(Vector2(0, -20), Vector2.UP,
			Color(1.0, 0.1, 0.1, 1.0), mecha_bullet_scale * 2.5, 220.0, true)

# SPEED - three bullets spread at -20, 0, +20 degrees
func _special_triple_shot() -> void:
	for angle_deg in [-20.0, 0.0, 20.0]:
		var dir = Vector2.UP.rotated(deg_to_rad(angle_deg))
		_fire_bullet(Vector2(0, -20), dir, mecha_bullet_color, mecha_bullet_scale, mecha_bullet_speed)

# BALANCED - single piercing bullet
func _special_piercing_round() -> void:
	_fire_bullet(Vector2(0, -20), Vector2.UP,
			Color(0.5, 1.0, 0.5, 1.0), mecha_bullet_scale * 1.4, 750.0, true)

# ARTILLERY - three shells spread 100 px apart
func _special_barrage() -> void:
	for x_off in [-100.0, 0.0, 100.0]:
		var clamped_x = clamp(position.x + x_off, 50.0, screen_size.x - 50.0) - position.x
		_fire_bullet(Vector2(clamped_x, -20), Vector2.UP,
				mecha_bullet_color, mecha_bullet_scale * 1.4, mecha_bullet_speed)

# --- ULTIMATE WEAPONS ---------------------------------------------------------
func use_ultimate() -> void:
	can_use_ultimate = false
	ultimate_cooldown_remaining = ultimate_cooldown_max
	ultimate_cooldown_changed.emit(ultimate_cooldown_remaining, ultimate_cooldown_max, false)
	_animate_ultimate()

	match MechaSelector.get_selected_mecha():
		MechaSelector.MechaType.SCOUT:
			_ultimate_hyper_beam()
		MechaSelector.MechaType.TANK:
			_ultimate_gatling_storm()
		MechaSelector.MechaType.SPEED:
			_ultimate_blade_rush()
		MechaSelector.MechaType.BALANCED:
			_ultimate_mega_buster()
		MechaSelector.MechaType.ARTILLERY:
			_ultimate_missile_rain()

# SCOUT - HYPER BEAM: sustained rapid-fire cyan laser
func _ultimate_hyper_beam() -> void:
	var beam_color = Color(0.0, 1.0, 1.0, 1.0)
	for i in range(25):
		_fire_bullet(Vector2(0, -20), Vector2.UP,
				beam_color, Vector2(0.35, 12.0), 1400.0, true)
		await get_tree().create_timer(0.04).timeout

# TANK - GATLING STORM: 3 waves of 9-direction wide spread
func _ultimate_gatling_storm() -> void:
	var angles = [-40.0, -30.0, -20.0, -10.0, 0.0, 10.0, 20.0, 30.0, 40.0]
	for _wave in range(3):
		for angle_deg in angles:
			var dir = Vector2.UP.rotated(deg_to_rad(angle_deg))
			_fire_bullet(Vector2(0, -20), dir,
					Color(1.0, 0.15, 0.15, 1.0), Vector2(1.4, 1.4), 520.0)
		await get_tree().create_timer(0.25).timeout

# SPEED - BLADE RUSH: 6 piercing sabers across full screen width
func _ultimate_blade_rush() -> void:
	var positions = [-240.0, -144.0, -48.0, 48.0, 144.0, 240.0]
	for x_off in positions:
		var clamped_x = clamp(position.x + x_off, 40.0, screen_size.x - 40.0) - position.x
		_fire_bullet(Vector2(clamped_x, -20), Vector2.UP,
				Color(1.0, 0.55, 0.0, 1.0), Vector2(2.5, 3.0), 950.0, true)

# BALANCED - MEGA BUSTER: one enormous wide piercing blast
func _ultimate_mega_buster() -> void:
	_fire_bullet(Vector2(0, -20), Vector2.UP,
			Color(0.3, 1.0, 0.4, 1.0), Vector2(7.0, 5.0), 380.0, true)

# ARTILLERY - MISSILE RAIN: 10 missiles carpet-bombing full screen width
func _ultimate_missile_rain() -> void:
	var num_missiles = 10
	for i in range(num_missiles):
		var t = float(i) / float(num_missiles - 1)
		var target_x = lerp(60.0, screen_size.x - 60.0, t)
		var x_off = clamp(target_x, 40.0, screen_size.x - 40.0) - position.x
		_fire_bullet(Vector2(x_off, -20), Vector2.UP,
				Color(0.75, 0.2, 1.0, 1.0), Vector2(1.6, 2.2), 380.0)
		await get_tree().create_timer(0.06).timeout

# --- BULLET FIRING HELPER -----------------------------------------------------
func _fire_bullet(offset: Vector2, dir: Vector2, color: Color,
		bscale: Vector2, spd: float, is_piercing: bool = false) -> void:
	if not bullet_scene:
		return
	var bullet = bullet_scene.instantiate()
	bullet.position = position + offset
	bullet.direction = dir
	bullet.collision_layer = 4
	bullet.collision_mask = 2
	bullet.add_to_group("player_bullet")
	bullet.bullet_color = color
	bullet.bullet_scale = bscale
	bullet.speed = spd
	bullet.piercing = is_piercing
	get_parent().add_child(bullet)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_bullet"):
		_animate_hit_flash()
		player_hit.emit()
		area.queue_free()

func take_damage() -> void:
	_animate_hit_flash()
	player_hit.emit()
