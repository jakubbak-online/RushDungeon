extends StaticBody2D
# Przeszkoda kolizyjna — kamienny blok. Lekka wariacja odcienia dla urozmaicenia.

var shade: float = 0.0

func _ready() -> void:
	shade = randf_range(-0.03, 0.05)
	queue_redraw()

func _draw() -> void:
	var base := Color(0.26 + shade, 0.26 + shade, 0.31 + shade)
	var hw := 28.0
	draw_rect(Rect2(-hw, -hw, hw * 2.0, hw * 2.0), base)
	draw_rect(Rect2(-hw, -hw, hw * 2.0, hw * 2.0), Color(0.14, 0.14, 0.18), false, 2.0)
	draw_line(Vector2(-hw * 0.4, -hw * 0.5), Vector2(hw * 0.1, hw * 0.2), Color(0.18, 0.18, 0.22), 2.0)
	draw_line(Vector2(hw * 0.3, -hw * 0.2), Vector2(hw * 0.5, hw * 0.4), Color(0.18, 0.18, 0.22), 2.0)
