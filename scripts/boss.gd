extends Area2D

# Boss script - unique behaviour per level

signal boss_destroyed(points: int)
signal boss_health_changed(current: int, maximum: int)

var max_health: int = 100
var current_health: int = 100
var boss_name: String = "BOSS"
var boss_level: int = 1
var points_reward: int = 1000

var move_speed: float = 80.0
var move_direction: int = 1
var shoot_interval: float = 1.5
var bullet_scene: PackedScene

var can_act: bool = true
var phase: int = 1
var time_elapsed: float = 0.0
var viewport_size: Vector2

var _flash_tween: Tween

func _ready() -> void:
	viewport_size = get_viewport_rect().size
	area_entered.connect(_on_area_entered)

func setup(level: int, bullet_scn: PackedScene) -> void:
	boss_level = level
	bullet_scene = bullet_scn
	_configure_for_level(level)
	_apply_sprite()
	_start_shoot_timer()
	boss_health_changed.emit(current_health, max_health)

func _configure_for_level(level: int) -> void:
	# Health scales quadratically: ~115 at L1, ~285 at L3, ~535 at L5, ~1275 at L9, ~1510 at L10
	max_health = 60 + level * 55 + level * (level - 1) * 10
	current_health = max_health
	# Speed and fire rate scale smoothly with level
	move_speed   = 65.0 + level * 8.0
	shoot_interval = maxf(0.45, 2.0 - level * 0.16)
	points_reward  = level * level * 120
	match level:
		1:  boss_name = "INFERNO DRAKE"
		2:  boss_name = "NUCLEAR COLOSSUS"
		3:  boss_name = "TIDAL LEVIATHAN"
		4:  boss_name = "MAGMA LORD"
		5:  boss_name = "FROST TITAN"
		6:  boss_name = "PLAGUE HARBINGER"
		7:  boss_name = "SAND PHARAOH"
		8:  boss_name = "VOID RIFT KEEPER"
		9:  boss_name = "OMEGA MACHINE"
		10: boss_name = "APOCALYPSE ENGINE"
		_:  boss_name = "UNKNOWN THREAT"

func _apply_sprite() -> void:
	# Color the polygon shapes per boss level for always-visible appearance
	_apply_polygon_color()
	# Optionally overlay SVG texture if imported
	var path = "res://sprites/bosses/boss_level_%d.svg" % boss_level
	var tex = load(path) if ResourceLoader.exists(path) else null
	if tex and has_node("Sprite2D"):
		$Sprite2D.texture = tex

func _apply_polygon_color() -> void:
	var wing_color: Color
	var core_color: Color
	var wing_pts: PackedVector2Array
	var core_pts: PackedVector2Array

	match boss_level:
		1: # INFERNO DRAKE — swept dragon wings, fanged head
			wing_color = Color(1.0, 0.22, 0.05, 1)
			core_color = Color(1.0, 0.65, 0.1, 1)
			wing_pts = PackedVector2Array([
				Vector2(0,-68),  Vector2(18,-48), Vector2(80,-8),
				Vector2(58,28),  Vector2(72,55),  Vector2(28,42),
				Vector2(0,65),   Vector2(-28,42), Vector2(-72,55),
				Vector2(-58,28), Vector2(-80,-8), Vector2(-18,-48)])
			core_pts = PackedVector2Array([
				Vector2(0,-50), Vector2(16,-20), Vector2(20,20),
				Vector2(0,50),  Vector2(-20,20), Vector2(-16,-20)])

		2: # NUCLEAR COLOSSUS — rounded reactor dome with 4 cannon bosses
			wing_color = Color(0.35, 1.0, 0.18, 1)
			core_color = Color(0.05, 0.55, 0.0, 1)
			wing_pts = PackedVector2Array([
				Vector2(-14,-78), Vector2(14,-78),
				Vector2(32,-68),  Vector2(60,-42),
				Vector2(72,-8),   Vector2(68,28),
				Vector2(50,60),   Vector2(22,78),
				Vector2(-22,78),  Vector2(-50,60),
				Vector2(-68,28),  Vector2(-72,-8),
				Vector2(-60,-42), Vector2(-32,-68)])
			core_pts = PackedVector2Array([
				Vector2(-24,-14), Vector2(24,-14),
				Vector2(24,48),   Vector2(-24,48)])

		3: # TIDAL LEVIATHAN — wide flowing nautilus shell / sea beast
			wing_color = Color(0.08, 0.52, 1.0, 1)
			core_color = Color(0.55, 0.88, 1.0, 1)
			wing_pts = PackedVector2Array([
				Vector2(0,-60),  Vector2(38,-50), Vector2(70,-24),
				Vector2(82,8),   Vector2(68,40),  Vector2(35,62),
				Vector2(0,70),   Vector2(-35,62), Vector2(-68,40),
				Vector2(-82,8),  Vector2(-70,-24),Vector2(-38,-50)])
			core_pts = PackedVector2Array([
				Vector2(0,-38), Vector2(26,-12), Vector2(26,30),
				Vector2(0,48),  Vector2(-26,30), Vector2(-26,-12)])

		4: # MAGMA LORD — 8-pointed jagged star (volcanic eruption)
			wing_color = Color(1.0, 0.32, 0.0, 1)
			core_color = Color(1.0, 0.85, 0.1, 1)
			wing_pts = PackedVector2Array([
				Vector2(0,-75),   Vector2(11,-26),
				Vector2(53,-53),  Vector2(26,-11),
				Vector2(75,0),    Vector2(26,11),
				Vector2(53,53),   Vector2(11,26),
				Vector2(0,75),    Vector2(-11,26),
				Vector2(-53,53),  Vector2(-26,11),
				Vector2(-75,0),   Vector2(-26,-11),
				Vector2(-53,-53), Vector2(-11,-26)])
			core_pts = PackedVector2Array([
				Vector2(0,-32), Vector2(22,0),
				Vector2(0,32),  Vector2(-22,0)])

		5: # FROST TITAN — perfect 6-pointed ice crystal / snowflake
			wing_color = Color(0.52, 0.84, 1.0, 1)
			core_color = Color(0.92, 0.97, 1.0, 1)
			wing_pts = PackedVector2Array([
				Vector2(0,-72),   Vector2(15,-26),
				Vector2(62,-36),  Vector2(30,0),
				Vector2(62,36),   Vector2(15,26),
				Vector2(0,72),    Vector2(-15,26),
				Vector2(-62,36),  Vector2(-30,0),
				Vector2(-62,-36), Vector2(-15,-26)])
			core_pts = PackedVector2Array([
				Vector2(0,-32), Vector2(28,-16),
				Vector2(28,16), Vector2(0,32),
				Vector2(-28,16),Vector2(-28,-16)])

		6: # PLAGUE HARBINGER — asymmetric organic blob with tendrils
			wing_color = Color(0.45, 0.95, 0.18, 1)
			core_color = Color(0.8, 1.0, 0.25, 1)
			wing_pts = PackedVector2Array([
				Vector2(0,-65),   Vector2(35,-58),
				Vector2(62,-35),  Vector2(74,4),
				Vector2(62,38),   Vector2(30,66),
				Vector2(-8,72),   Vector2(-44,56),
				Vector2(-68,22),  Vector2(-72,-20),
				Vector2(-50,-55), Vector2(-18,-68)])
			core_pts = PackedVector2Array([
				Vector2(-16,-30), Vector2(20,-24),
				Vector2(30,12),   Vector2(12,40),
				Vector2(-22,32),  Vector2(-32,-6)])

		7: # SAND PHARAOH — royal headdress with wide ceremonial wings
			wing_color = Color(1.0, 0.78, 0.08, 1)
			core_color = Color(1.0, 0.96, 0.5, 1)
			wing_pts = PackedVector2Array([
				Vector2(0,-80),   Vector2(20,-60),
				Vector2(14,-38),  Vector2(50,-54),
				Vector2(68,-25),  Vector2(56,8),
				Vector2(72,38),   Vector2(48,68),
				Vector2(22,75),   Vector2(-22,75),
				Vector2(-48,68),  Vector2(-72,38),
				Vector2(-56,8),   Vector2(-68,-25),
				Vector2(-50,-54), Vector2(-14,-38),
				Vector2(-20,-60)])
			core_pts = PackedVector2Array([
				Vector2(-20,-12), Vector2(20,-12),
				Vector2(28,28),   Vector2(0,52),
				Vector2(-28,28)])

		8: # VOID RIFT KEEPER — 12-pointed star (tear in spacetime)
			wing_color = Color(0.58, 0.12, 1.0, 1)
			core_color = Color(0.88, 0.58, 1.0, 1)
			wing_pts = PackedVector2Array([
				Vector2(0,-80),   Vector2(8,-31),
				Vector2(40,-69),  Vector2(23,-23),
				Vector2(69,-40),  Vector2(31,-8),
				Vector2(80,0),    Vector2(31,8),
				Vector2(69,40),   Vector2(23,23),
				Vector2(40,69),   Vector2(8,31),
				Vector2(0,80),    Vector2(-8,31),
				Vector2(-40,69),  Vector2(-23,23),
				Vector2(-69,40),  Vector2(-31,8),
				Vector2(-80,0),   Vector2(-31,-8),
				Vector2(-69,-40), Vector2(-23,-23),
				Vector2(-40,-69), Vector2(-8,-31)])
			core_pts = PackedVector2Array([
				Vector2(0,-28),  Vector2(20,-20),
				Vector2(28,0),   Vector2(20,20),
				Vector2(0,28),   Vector2(-20,20),
				Vector2(-28,0),  Vector2(-20,-20)])

		9: # OMEGA MACHINE — boxy mech chassis with shoulder cannons
			wing_color = Color(0.08, 0.85, 1.0, 1)
			core_color = Color(0.55, 1.0, 1.0, 1)
			wing_pts = PackedVector2Array([
				Vector2(-40,-75), Vector2(40,-75),
				Vector2(58,-55),  Vector2(58,-22),
				Vector2(80,0),    Vector2(58,22),
				Vector2(58,55),   Vector2(40,75),
				Vector2(-40,75),  Vector2(-58,55),
				Vector2(-58,22),  Vector2(-80,0),
				Vector2(-58,-22), Vector2(-58,-55)])
			core_pts = PackedVector2Array([
				Vector2(-24,-45), Vector2(24,-45),
				Vector2(34,0),    Vector2(24,45),
				Vector2(-24,45),  Vector2(-34,0)])

		10: # APOCALYPSE ENGINE — massive multi-pronged command dreadnought
			wing_color = Color(1.0, 0.08, 0.08, 1)
			core_color = Color(1.0, 0.82, 0.0, 1)
			wing_pts = PackedVector2Array([
				Vector2(0,-85),   Vector2(22,-68),
				Vector2(18,-44),  Vector2(52,-62),
				Vector2(70,-32),  Vector2(56,-5),
				Vector2(85,8),    Vector2(64,38),
				Vector2(40,65),   Vector2(16,78),
				Vector2(-16,78),  Vector2(-40,65),
				Vector2(-64,38),  Vector2(-85,8),
				Vector2(-56,-5),  Vector2(-70,-32),
				Vector2(-52,-62), Vector2(-18,-44),
				Vector2(-22,-68)])
			core_pts = PackedVector2Array([
				Vector2(-28,-28), Vector2(28,-28),
				Vector2(40,18),   Vector2(22,58),
				Vector2(-22,58),  Vector2(-40,18)])

		_:
			wing_color = Color(1.0, 0.25, 0.05, 1)
			core_color = Color(0.7, 0.7, 0.9, 1)
			wing_pts = PackedVector2Array([
				Vector2(0,-55), Vector2(65,-15), Vector2(45,12),
				Vector2(60,48), Vector2(0,28),   Vector2(-60,48),
				Vector2(-45,12),Vector2(-65,-15)])
			core_pts = PackedVector2Array([
				Vector2(0,-30), Vector2(22,-8), Vector2(28,20),
				Vector2(0,35),  Vector2(-28,20),Vector2(-22,-8)])

	if has_node("Shape"):
		$Shape.polygon = wing_pts
		$Shape.color   = wing_color
	if has_node("BodyCore"):
		$BodyCore.polygon = core_pts
		$BodyCore.color   = core_color

func _start_shoot_timer() -> void:
	var timer = Timer.new()
	timer.name = "ShootTimer"
	timer.wait_time = shoot_interval
	timer.timeout.connect(_on_shoot_timer)
	timer.autostart = true
	add_child(timer)

func _process(delta: float) -> void:
	if not can_act:
		return
	time_elapsed += delta
	_move(delta)

func _move(delta: float) -> void:
	var margin := 80.0
	match boss_level:
		1, 4, 7:
			# Horizontal sweep
			position.x += move_direction * move_speed * delta
			if position.x >= viewport_size.x - margin:
				move_direction = -1
			elif position.x <= margin:
				move_direction = 1
		2, 6:
			# Sine-wave horizontal
			position.x += move_direction * move_speed * delta
			if position.x >= viewport_size.x - margin:
				move_direction = -1
			elif position.x <= margin:
				move_direction = 1
			position.y = 130.0 + sin(time_elapsed * 1.2) * 55.0
		3, 5:
			# Figure-8 lemniscate
			var cx := viewport_size.x * 0.5
			position.x = cx + sin(time_elapsed * 0.8) * (viewport_size.x * 0.35)
			position.y = 130.0 + sin(time_elapsed * 1.6) * 55.0
		8:
			# Smooth glide with dual-axis oscillation
			position.x = viewport_size.x * 0.5 + sin(time_elapsed * 1.1) * (viewport_size.x * 0.40)
			position.y = 110.0 + sin(time_elapsed * 2.2) * 70.0
		9:
			# Aggressive sweep with vertical drift
			position.x += move_direction * move_speed * delta
			if position.x >= viewport_size.x - margin:
				move_direction = -1
				position.y = clamp(position.y + 28.0, 80.0, 210.0)
			elif position.x <= margin:
				move_direction = 1
				position.y = clamp(position.y - 18.0, 80.0, 210.0)
		10:
			# Complex combined pattern
			var cx := viewport_size.x * 0.5
			position.x = cx + sin(time_elapsed * 0.9) * (viewport_size.x * 0.42)
			position.y = 130.0 + sin(time_elapsed * 1.8) * 65.0 + cos(time_elapsed * 0.7) * 28.0
		_:
			position.x += move_direction * move_speed * delta
			if position.x >= viewport_size.x - margin:
				move_direction = -1
			elif position.x <= margin:
				move_direction = 1

# ── Shooting ─────────────────────────────────────────────────────────────────

func _on_shoot_timer() -> void:
	if not can_act or not bullet_scene:
		return
	match boss_level:
		1: _shoot_aimed(Color(1.0, 0.35, 0.0))
		2: _shoot_triple(15.0, Color(0.5, 1.0, 0.2))
		3: _shoot_fan(5, 30.0, Color(0.2, 0.5, 1.0))
		4: _shoot_cross(Color(1.0, 0.2, 0.0))
		5: _shoot_triple(12.0, Color(0.5, 0.8, 1.0))
		6: _shoot_circle(6, Color(0.5, 1.0, 0.2))
		7: _shoot_diagonal(Color(1.0, 0.8, 0.2))
		8: _shoot_circle(8, Color(0.6, 0.2, 1.0))
		9: _shoot_barrage(Color(0.2, 0.8, 1.0))
		10: _shoot_apocalypse()

func _shoot_aimed(color: Color) -> void:
	var dir := _player_direction()
	_fire(dir, 430, color)

func _shoot_triple(spread_deg: float, color: Color) -> void:
	for i in [-1, 0, 1]:
		var dir := Vector2(sin(deg_to_rad(i * spread_deg)), cos(deg_to_rad(i * spread_deg)))
		_fire(dir, 390, color)

func _shoot_fan(count: int, half_angle_deg: float, color: Color) -> void:
	for i in range(count):
		var t := float(i) / float(count - 1) if count > 1 else 0.5
		var angle := deg_to_rad(lerp(-half_angle_deg, half_angle_deg, t))
		_fire(Vector2(sin(angle), cos(angle)), 370, color)

func _shoot_cross(color: Color) -> void:
	for dir in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]:
		_fire(dir, 410, color)

func _shoot_diagonal(color: Color) -> void:
	for angle_deg in [30, 60, 90, 120, 150]:
		var r := deg_to_rad(angle_deg)
		_fire(Vector2(sin(r), cos(r)), 400, color)

func _shoot_circle(count: int, color: Color) -> void:
	for i in range(count):
		var angle := (TAU / count) * i
		_fire(Vector2(sin(angle), cos(angle)), 385, color)

func _shoot_barrage(color: Color) -> void:
	var base := _player_direction()
	for _i in range(3):
		var spread := randf_range(-0.18, 0.18)
		_fire(base.rotated(spread), 470, color)

func _shoot_apocalypse() -> void:
	_shoot_circle(12, Color(1.0, 0.2, 0.2))
	_shoot_aimed(Color(0.6, 0.2, 1.0))

func _player_direction() -> Vector2:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return (players[0].global_position - global_position).normalized()
	return Vector2.DOWN

func _fire(dir: Vector2, speed: float, color: Color) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position + Vector2(0, 50)
	bullet.direction = dir.normalized()
	bullet.speed = speed
	bullet.collision_layer = 8
	bullet.collision_mask = 1
	bullet.bullet_color = color
	bullet.add_to_group("enemy_bullet")
	get_parent().add_child(bullet)

# ── Damage ────────────────────────────────────────────────────────────────────

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		if not area.piercing:
			area.queue_free()
		take_damage(1)

func take_damage(damage: int = 1) -> void:
	if not can_act:
		return
	current_health = max(0, current_health - damage)
	boss_health_changed.emit(current_health, max_health)

	# Hit flash on visible polygon shape
	if _flash_tween:
		_flash_tween.kill()
	var shape_node := $Shape
	_flash_tween = create_tween()
	_flash_tween.tween_property(shape_node, "modulate", Color(3.0, 0.4, 0.4, 1.0), 0.04)
	_flash_tween.tween_property(shape_node, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)

	# Phase 2 at 50 % HP — faster and more aggressive
	if phase == 1 and current_health <= max_health / 2:
		phase = 2
		move_speed *= 1.45
		var t := get_node_or_null("ShootTimer")
		if t:
			t.wait_time = shoot_interval * 0.60

	if current_health <= 0:
		destroy()

func destroy() -> void:
	can_act = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	boss_destroyed.emit(points_reward)

	var shape_node := $Shape
	var tw := create_tween()
	tw.tween_property(shape_node, "modulate", Color(4.0, 2.0, 0.0, 1.0), 0.08)
	tw.parallel().tween_property(shape_node, "scale", Vector2(1.6, 1.6), 0.08)
	tw.tween_property(shape_node, "modulate:a", 0.0, 0.45)
	tw.parallel().tween_property(shape_node, "scale", Vector2(2.8, 2.8), 0.45)
	tw.tween_callback(queue_free)
