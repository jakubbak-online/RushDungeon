extends Area2D
# Przedmiot do podniesienia: pancerz obnizajacy szanse na smierc.
# Ikona tarczy rysowana wektorowo, z lekkim unoszeniem sie.

@export var armor_reduction: float = 70.0

var bob: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _process(delta: float) -> void:
	bob += delta * 3.0
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("set_armor"):
		body.call("set_armor", armor_reduction)
		queue_free()

func _draw() -> void:
	var off := Vector2(0, sin(bob) * 2.0)
	var steel := Color(0.80, 0.82, 0.88)
	var edge := Color(0.42, 0.45, 0.52)
	var pts := PackedVector2Array([
		Vector2(0, -16) + off, Vector2(14, -11) + off, Vector2(13, 6) + off,
		Vector2(0, 18) + off, Vector2(-13, 6) + off, Vector2(-14, -11) + off,
	])
	draw_colored_polygon(pts, steel)
	var outline := pts
	outline.append(pts[0])
	draw_polyline(outline, edge, 2.0)
	draw_line(Vector2(0, -9) + off, Vector2(0, 11) + off, edge, 2.0)
	draw_line(Vector2(-8, 0) + off, Vector2(8, 0) + off, edge, 2.0)
