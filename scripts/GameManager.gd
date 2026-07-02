extends Node
# Koordynator rozgrywki (autoload). Trzyma stan gry, odlicza czas piętra,
# rozgłasza zmiany przez sygnały i rejestruje sterowanie.

signal time_changed(time_left: float)
signal state_changed(message: String)

enum State { PLAYING, WON, LOST }

var state: State = State.PLAYING
var time_left: float = 0.0

func _ready() -> void:
	# Autoload działa też przy zapauzowanym drzewie — dzięki temu po końcu gry
	# nadal łapiemy klawisz restartu.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input()

func _process(delta: float) -> void:
	if state == State.PLAYING:
		time_left = max(time_left - delta, 0.0)
		time_changed.emit(time_left)
		if time_left <= 0.0:
			lose()
	elif Input.is_action_just_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()

func start_floor(duration: float) -> void:
	state = State.PLAYING
	time_left = duration
	get_tree().paused = false
	state_changed.emit("")
	time_changed.emit(time_left)

func win() -> void:
	if state != State.PLAYING:
		return
	state = State.WON
	state_changed.emit("WYGRANA!\n[R] - zagraj ponownie")
	get_tree().paused = true

func lose() -> void:
	if state != State.PLAYING:
		return
	state = State.LOST
	state_changed.emit("PORAZKA - czas sie skonczyl\n[R] - zagraj ponownie")
	get_tree().paused = true

# Sterowanie definiujemy w kodzie (klawisze fizyczne) — niezależnie od układu
# klawiatury i wersji edytora.
func _setup_input() -> void:
	_bind("move_left",  [KEY_A, KEY_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT])
	_bind("move_up",    [KEY_W, KEY_UP])
	_bind("move_down",  [KEY_S, KEY_DOWN])
	_bind("attack",     [KEY_SPACE, KEY_J])
	_bind("restart",    [KEY_R])

func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
