extends CharacterBody2D
# Gracz: ruch top-down, atak w zwarciu, pancerz i odrodzenie.
# Bez punktów życia — o śmierci decyduje rzut przy uderzeniu (try_kill).

@export var speed: float = 230.0
@export var armor_reduction: float = 0.0   # ile % szansy na smierc zdejmuje pancerz
@export var attack_cooldown: float = 0.35
@export var attack_radius: float = 52.0
@export var respawn_invuln_time: float = 1.0

@onready var attack_area: Area2D = $AttackArea
@onready var attack_col: CollisionShape2D = $AttackArea/CollisionShape2D

var spawn_position: Vector2
var can_attack: bool = true
var invulnerable: bool = false
var facing: Vector2 = Vector2.UP
var swing: float = 0.0   # jasnosc wizualizacji zamachu (1 -> 0)

func _ready() -> void:
	add_to_group("player")
	spawn_position = global_position
	var s := CircleShape2D.new()
	s.radius = attack_radius
	attack_col.shape = s
	queue_redraw()

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	if dir != Vector2.ZERO:
		facing = dir.normalized()
		queue_redraw()
	move_and_slide()

	if Input.is_action_just_pressed("attack") and can_attack:
		_attack()

	if swing > 0.0:
		swing = max(swing - delta * 4.0, 0.0)
		queue_redraw()

func _attack() -> void:
	can_attack = false
	swing = 1.0
	queue_redraw()
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.call("take_hit", 1)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func try_kill(enemy_kill_chance: float) -> void:
	if invulnerable:
		return
	if randf() * 100.0 < enemy_kill_chance - armor_reduction:
		_die()

func set_armor(reduction: float) -> void:
	armor_reduction = reduction

func _die() -> void:
	# Odrodzenie na starcie pietra — timer leci dalej (zgodnie z petla gry).
	global_position = spawn_position
	velocity = Vector2.ZERO
	invulnerable = true
	modulate = Color(1, 1, 1, 0.4)
	await get_tree().create_timer(respawn_invuln_time).timeout
	invulnerable = false
	modulate = Color(1, 1, 1, 1)

func _draw() -> void:
	var body := Color(0.30, 0.68, 1.0)
	draw_circle(Vector2.ZERO, 16, body)
	draw_arc(Vector2.ZERO, 16, 0, TAU, 28, Color(0.85, 0.95, 1.0), 2.0)
	# wskaznik kierunku
	var tip := facing * 24.0
	var l := facing.rotated(2.5) * 12.0
	var r := facing.rotated(-2.5) * 12.0
	draw_colored_polygon(PackedVector2Array([tip, l, r]), Color(1, 1, 1, 0.9))
	# zamach
	if swing > 0.0:
		draw_arc(Vector2.ZERO, attack_radius, 0, TAU, 40, Color(1.0, 0.9, 0.4, swing * 0.8), 4.0)
