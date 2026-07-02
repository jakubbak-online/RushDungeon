extends CharacterBody2D
# Przeciwnik z prostym AI. Statystyki i wygląd wynikają z pola `kind`
# (jeden skrypt, wiele typów). Goblin i Ogr mają osobne ikony rysowane wektorowo.

enum Kind { GOBLIN, OGR }

@export var kind: Kind = Kind.GOBLIN

var speed: float
var kill_chance: float
var max_hp: int
var attack_range: float
var detection_range: float
var attack_cooldown: float
var radius: float
var body_color: Color

var hp: int
var player = null
var can_attack: bool = true

@onready var col: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("enemy")
	_apply_archetype()
	hp = max_hp
	var shape := CircleShape2D.new()
	shape.radius = radius
	col.shape = shape
	queue_redraw()

func _apply_archetype() -> void:
	match kind:
		Kind.OGR:
			speed = 72.0
			kill_chance = 175.0
			max_hp = 3
			attack_range = 54.0
			detection_range = 430.0
			attack_cooldown = 1.6
			radius = 24.0
			body_color = Color(0.78, 0.30, 0.22)
		_:
			speed = 135.0
			kill_chance = 90.0
			max_hp = 1
			attack_range = 40.0
			detection_range = 290.0
			attack_cooldown = 0.9
			radius = 15.0
			body_color = Color(0.46, 0.78, 0.36)

func _physics_process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	var to_player: Vector2 = player.global_position - global_position
	var dist := to_player.length()

	# Poza zasiegiem wykrywania stoi — wolnego Ogra latwo zgubic.
	if dist > detection_range:
		velocity = Vector2.ZERO
		return

	if dist > attack_range:
		velocity = to_player.normalized() * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if can_attack:
			_attack()

func _attack() -> void:
	can_attack = false
	if player.has_method("try_kill"):
		player.call("try_kill", kill_chance)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_hit(damage: int) -> void:
	hp -= damage
	_flash()
	if hp <= 0:
		queue_free()

func _flash() -> void:
	modulate = Color(1, 1, 1, 0.4)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(self):
		modulate = Color(1, 1, 1, 1)

func _draw() -> void:
	if kind == Kind.OGR:
		_draw_ogr()
	else:
		_draw_goblin()

func _draw_goblin() -> void:
	var c := body_color
	var dark := c.darkened(0.3)
	var r := radius
	draw_colored_polygon(PackedVector2Array([Vector2(-r * 0.6, -r * 0.4), Vector2(-r * 1.4, -r * 1.2), Vector2(-r * 0.2, -r * 0.8)]), c)
	draw_colored_polygon(PackedVector2Array([Vector2(r * 0.6, -r * 0.4), Vector2(r * 1.4, -r * 1.2), Vector2(r * 0.2, -r * 0.8)]), c)
	draw_circle(Vector2.ZERO, r, c)
	draw_arc(Vector2.ZERO, r, 0, TAU, 20, dark, 1.5)
	draw_circle(Vector2(-r * 0.35, -r * 0.05), r * 0.16, Color(0.9, 0.15, 0.1))
	draw_circle(Vector2(r * 0.35, -r * 0.05), r * 0.16, Color(0.9, 0.15, 0.1))

func _draw_ogr() -> void:
	var c := body_color
	var dark := c.darkened(0.35)
	var wood := Color(0.45, 0.32, 0.2)
	var r := radius
	# pala
	draw_line(Vector2(r * 0.8, r * 0.3), Vector2(r * 1.7, -r * 0.7), wood, 6.0)
	draw_circle(Vector2(r * 1.8, -r * 0.8), r * 0.5, wood)
	# cialo
	draw_circle(Vector2.ZERO, r, c)
	draw_arc(Vector2.ZERO, r, 0, TAU, 28, dark, 2.0)
	# brwi
	draw_line(Vector2(-r * 0.5, -r * 0.25), Vector2(-r * 0.1, -r * 0.1), dark, 3.0)
	draw_line(Vector2(r * 0.5, -r * 0.25), Vector2(r * 0.1, -r * 0.1), dark, 3.0)
	# oczy
	draw_circle(Vector2(-r * 0.28, r * 0.05), r * 0.13, Color(0.95, 0.85, 0.2))
	draw_circle(Vector2(r * 0.28, r * 0.05), r * 0.13, Color(0.95, 0.85, 0.2))
