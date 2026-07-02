extends CanvasLayer
# Interfejs: czas, aktualny pancerz i komunikaty konca gry.

@onready var timer_label: Label = $TimerLabel
@onready var armor_label: Label = $ArmorLabel
@onready var message_label: Label = $MessageLabel

func _ready() -> void:
	GameManager.time_changed.connect(_on_time_changed)
	GameManager.state_changed.connect(_on_state_changed)
	message_label.text = ""

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		armor_label.text = "Pancerz: -%d%% szansy na smierc" % int(player.armor_reduction)

func _on_time_changed(t: float) -> void:
	timer_label.text = "Czas: %0.1f s" % t

func _on_state_changed(message: String) -> void:
	message_label.text = message
