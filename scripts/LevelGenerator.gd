class_name LevelGenerator
extends RefCounted
# Proceduralne rozmieszczenie zawartości piętra na siatce komórek.
# Gwarantuje, że wyjście jest osiągalne (BFS) i że byty się nie nakładają.

const GOBLIN := 0
const OGR := 1

var rect: Rect2
var cell: float
var cols: int
var rows: int
var origin: Vector2

func _init(play_rect: Rect2, cell_size: float) -> void:
	rect = play_rect
	cell = cell_size
	cols = max(int(rect.size.x / cell), 2)
	rows = max(int(rect.size.y / cell), 2)
	var used := Vector2(cols, rows) * cell
	origin = rect.position + (rect.size - used) * 0.5 + Vector2(cell, cell) * 0.5

func cell_center(c: int, r: int) -> Vector2:
	return origin + Vector2(c, r) * cell

# Kilka prób wygenerowania sensownego układu; w razie porażki układ bez przeszkód.
func generate(density: float, enemy_count: int) -> Dictionary:
	for i in 10:
		var res := _try(density, enemy_count)
		if not res.is_empty():
			return res
	return _try(0.0, enemy_count)

func _try(density: float, enemy_count: int) -> Dictionary:
	var player_cell := Vector2i(cols / 2, rows - 1)
	var exit_cell := _far_cell(player_cell)

	var blocked := {}
	for c in cols:
		for r in rows:
			var cc := Vector2i(c, r)
			if cc == player_cell or cc == exit_cell:
				continue
			if randf() < density:
				blocked[cc] = true

	# Odrzuć układ, w którym nie da się dojść do wyjścia.
	if not _bfs(player_cell, blocked).has(exit_cell):
		return {}

	var free: Array = []
	for cc in _bfs(player_cell, blocked):
		if cc != player_cell and cc != exit_cell:
			free.append(cc)
	free.shuffle()

	# Przeciwników trzymamy z dala od gracza; przedmiot może być blisko.
	var far: Array = []
	var near: Array = []
	for cc in free:
		if Vector2(cc - player_cell).length() >= 2.0:
			far.append(cc)
		else:
			near.append(cc)

	if far.size() < enemy_count:
		return {}

	var enemy_cells: Array = far.slice(0, enemy_count)
	var pickup_pool: Array = near + far.slice(enemy_count)
	if pickup_pool.is_empty():
		return {}

	var kinds := _kinds(enemy_count)
	var enemies: Array = []
	for i in enemy_count:
		var cc: Vector2i = enemy_cells[i]
		enemies.append({"pos": cell_center(cc.x, cc.y), "kind": kinds[i]})

	var obstacles: Array = []
	for cc in blocked:
		obstacles.append(cell_center(cc.x, cc.y))

	var pk: Vector2i = pickup_pool[0]
	return {
		"player": cell_center(player_cell.x, player_cell.y),
		"exit": cell_center(exit_cell.x, exit_cell.y),
		"pickup": cell_center(pk.x, pk.y),
		"enemies": enemies,
		"obstacles": obstacles,
	}

# Dobór typów: przy 3+ wrogach jeden Ogr, reszta Goblinów.
func _kinds(n: int) -> Array:
	var list: Array = []
	var ogres := 1 if n >= 3 else 0
	for i in ogres:
		list.append(OGR)
	for i in range(n - ogres):
		list.append(GOBLIN)
	list.shuffle()
	return list

func _far_cell(pc: Vector2i) -> Vector2i:
	var best := Vector2i.ZERO
	var best_d := -1.0
	for c in cols:
		for r in rows:
			var cc := Vector2i(c, r)
			var d := Vector2(cc - pc).length() + randf() * 1.5
			if d > best_d:
				best_d = d
				best = cc
	return best

func _bfs(start: Vector2i, blocked: Dictionary) -> Dictionary:
	var visited := {start: true}
	var queue: Array = [start]
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		for d in dirs:
			var nx: Vector2i = cur + d
			if nx.x < 0 or nx.x >= cols or nx.y < 0 or nx.y >= rows:
				continue
			if visited.has(nx) or blocked.has(nx):
				continue
			visited[nx] = true
			queue.append(nx)
	return visited
