extends Node2D
# Shooter Arena — Godot 4 port · core slice.
# Everything is drawn in _draw() and driven from one node, mirroring the original
# JS game so it's easy to grow scene-by-scene later. Movement uses delta-time, so
# it runs at the same real speed on any refresh rate (60/90/120 Hz).

const PLAYER_SPEED := 260.0      # px per second
const BULLET_SPEED := 720.0
const ENEMY_SPEED := 110.0
const FIRE_COOLDOWN := 0.14      # seconds between shots
const JOY_RADIUS := 90.0         # touch drag distance for full deflection (functional)
const RING_RADIUS := 45.0        # drawn ring size (visual) — same look/feel as the web version
const AIM_FIRE_THRESHOLD := 12.0

var player_pos := Vector2.ZERO
var player_aim := Vector2.RIGHT
var fire_cd := 0.0
var score := 0
var health := 5

var bullets: Array = []          # {pos:Vector2, vel:Vector2}
var enemies: Array = []          # {pos:Vector2}
var spawn_cd := 0.0

# floating dual joysticks (left = move, right = aim + auto-fire)
var move_joy := {"active": false, "id": -1, "center": Vector2.ZERO, "delta": Vector2.ZERO}
var aim_joy := {"active": false, "id": -1, "center": Vector2.ZERO, "delta": Vector2.ZERO}
var move_vec := Vector2.ZERO

func _ready() -> void:
	player_pos = get_viewport_rect().size * 0.5

func _process(delta: float) -> void:
	_read_keyboard()
	if move_vec.length() > 0.01:
		player_pos += move_vec.limit_length(1.0) * PLAYER_SPEED * delta
	var vp := get_viewport_rect().size
	player_pos = player_pos.clamp(Vector2(20, 20), vp - Vector2(20, 20))

	# aim + fire
	var firing := false
	if aim_joy.active and aim_joy.delta.length() > AIM_FIRE_THRESHOLD:
		player_aim = aim_joy.delta.normalized()
		firing = true
	fire_cd -= delta
	if firing and fire_cd <= 0.0:
		bullets.append({"pos": player_pos, "vel": player_aim * BULLET_SPEED})
		fire_cd = FIRE_COOLDOWN

	for b in bullets:
		b.pos += b.vel * delta
	for e in enemies:
		e.pos += (player_pos - e.pos).normalized() * ENEMY_SPEED * delta

	spawn_cd -= delta
	if spawn_cd <= 0.0 and enemies.size() < 30:
		_spawn_enemy()
		spawn_cd = 1.2

	_collisions()
	queue_redraw()

func _read_keyboard() -> void:
	if move_joy.active:
		return   # touch has priority
	var v := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP): v.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN): v.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT): v.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT): v.x += 1
	move_vec = v

func _spawn_enemy() -> void:
	var vp := get_viewport_rect().size
	var p := Vector2.ZERO
	match randi() % 4:
		0: p = Vector2(randf() * vp.x, -30)
		1: p = Vector2(vp.x + 30, randf() * vp.y)
		2: p = Vector2(randf() * vp.x, vp.y + 30)
		_: p = Vector2(-30, randf() * vp.y)
	enemies.append({"pos": p})

func _collisions() -> void:
	var vp := get_viewport_rect().size
	for bi in range(bullets.size() - 1, -1, -1):
		var b = bullets[bi]
		var hit := false
		for ei in range(enemies.size() - 1, -1, -1):
			if b.pos.distance_to(enemies[ei].pos) < 22.0:
				enemies.remove_at(ei)
				score += 1
				hit = true
				break
		if hit or b.pos.x < -40 or b.pos.y < -40 or b.pos.x > vp.x + 40 or b.pos.y > vp.y + 40:
			bullets.remove_at(bi)
	for ei in range(enemies.size() - 1, -1, -1):
		if enemies[ei].pos.distance_to(player_pos) < 28.0:
			enemies.remove_at(ei)
			health = max(0, health - 1)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_press(event.index, event.position)
		else:
			_release(event.index)
	elif event is InputEventScreenDrag:
		_drag(event.index, event.position)

func _press(id: int, pos: Vector2) -> void:
	var half := get_viewport_rect().size.x * 0.5
	if pos.x < half and not move_joy.active:
		move_joy.active = true; move_joy.id = id; move_joy.center = pos; move_joy.delta = Vector2.ZERO
		move_vec = Vector2.ZERO
	elif pos.x >= half and not aim_joy.active:
		aim_joy.active = true; aim_joy.id = id; aim_joy.center = pos; aim_joy.delta = Vector2.ZERO

func _drag(id: int, pos: Vector2) -> void:
	if move_joy.active and move_joy.id == id:
		move_joy.delta = (pos - move_joy.center).limit_length(JOY_RADIUS)
		move_vec = move_joy.delta / JOY_RADIUS
	elif aim_joy.active and aim_joy.id == id:
		aim_joy.delta = (pos - aim_joy.center).limit_length(JOY_RADIUS)

func _release(id: int) -> void:
	if move_joy.active and move_joy.id == id:
		move_joy.active = false; move_joy.id = -1; move_joy.delta = Vector2.ZERO; move_vec = Vector2.ZERO
	elif aim_joy.active and aim_joy.id == id:
		aim_joy.active = false; aim_joy.id = -1; aim_joy.delta = Vector2.ZERO

func _draw() -> void:
	var vp := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, vp), Color(0.043, 0.051, 0.094))     # arena background
	for b in bullets:
		draw_circle(b.pos, 5.0, Color(0.96, 0.84, 0.30))
	for e in enemies:
		draw_circle(e.pos, 16.0, Color(1.0, 0.24, 0.43))
	draw_circle(player_pos, 18.0, Color(0.31, 0.82, 1.0))
	draw_line(player_pos, player_pos + player_aim * 26.0, Color.WHITE, 3.0)
	if move_joy.active:
		_draw_joy(move_joy, Color(0.79, 0.64, 1.0))
	if aim_joy.active:
		_draw_joy(aim_joy, Color(0.96, 0.84, 0.48))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(20, 34), "SCORE %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.96, 0.84, 0.30))
	draw_string(font, Vector2(20, 62), "HP %d" % health, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1.0, 0.48, 0.62))

func _draw_joy(joy: Dictionary, col: Color) -> void:
	draw_arc(joy.center, RING_RADIUS, 0.0, TAU, 40, col, 2.0)
	var knob: Vector2 = joy.center + (joy.delta / JOY_RADIUS) * RING_RADIUS
	draw_circle(knob, 15.0, col)
