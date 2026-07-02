extends Node2D
# Buduje losowe piętro przy każdym uruchomieniu/restarcie i startuje timer.

@export var floor_time: float = 60.0
@export var cell_size: float = 96.0
@export var obstacle_density: float = 0.14
@export var min_enemies: int = 3
@export var max_enemies: int = 5

const PLAYER := preload("res://scenes/Player.tscn")
const ENEMY := preload("res://scenes/Enemy.tscn")
const PICKUP := preload("res://scenes/Pickup.tscn")
const EXIT := preload("res://scenes/Exit.tscn")
const OBSTACLE := preload("res://scenes/Obstacle.tscn")

# Obszar rozmieszczania — wewnątrz zewnętrznych ścian, z marginesem.
const PLAY_RECT := Rect2(130, 130, 890, 410)

func _ready() -> void:
	_build_level()
	GameManager.start_floor(floor_time)

func _build_level() -> void:
	var gen := LevelGenerator.new(PLAY_RECT, cell_size)
	var layout := gen.generate(obstacle_density, randi_range(min_enemies, max_enemies))

	for pos in layout["obstacles"]:
		var o := OBSTACLE.instantiate()
		o.position = pos
		add_child(o)

	# Gracz najpierw — przeciwnicy szukają go w swoim _ready przez grupę.
	var p := PLAYER.instantiate()
	p.position = layout["player"]
	add_child(p)

	var ex := EXIT.instantiate()
	ex.position = layout["exit"]
	add_child(ex)

	var pk := PICKUP.instantiate()
	pk.position = layout["pickup"]
	add_child(pk)

	for spec in layout["enemies"]:
		var en := ENEMY.instantiate()
		en.position = spec["pos"]
		en.kind = spec["kind"]
		add_child(en)
