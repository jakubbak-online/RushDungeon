extends Area2D
# Wyjscie z pietra jako wirujacy portal. W PoC dotkniecie = wygrana.

var spin: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _process(delta: float) -> void:
	spin += delta * 1.4
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.win()

func _draw() -> void:
	var g := Color(0.2, 0.95, 0.5)
	draw_circle(Vector2.ZERO, 30, Color(0.2, 0.9, 0.45, 0.12))
	# dwa wirujace luki (widac obrot)
	draw_arc(Vector2.ZERO, 26, spin, spin + 2.4, 24, g, 4.0)
	draw_arc(Vector2.ZERO, 26, spin + PI, spin + PI + 2.4, 24, g, 4.0)
	draw_arc(Vector2.ZERO, 18, -spin * 1.3, -spin * 1.3 + 2.0, 20, Color(0.6, 1, 0.75, 0.8), 2.0)
	draw_arc(Vector2.ZERO, 18, -spin * 1.3 + PI, -spin * 1.3 + PI + 2.0, 20, Color(0.6, 1, 0.75, 0.8), 2.0)
	draw_circle(Vector2.ZERO, 10, Color(0.04, 0.18, 0.11))
