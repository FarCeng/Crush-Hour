extends Control

@onready var victory = $Victory
@onready var defeat = $Defeat
@onready var skip_button = $Skip

@export var victory_scene: String = "res://scene/scene_menang.tscn"
@export var defeat_scene: String = "res://scene/scene_kalah.tscn"

var is_victory := false

func _enter_tree():
	# PAKSA UI tetap hidup walau game paused
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready():
	# pastikan semua parent & button juga PROCESS
	_set_pause_recursive(self)

	AudioManager.stop_all_bgm()
	AudioManager.stop_all_sfx()

	visible = false
	victory.visible = false
	defeat.visible = false

	skip_button.pressed.connect(_on_skip_pressed)


func show_victory():
	is_victory = true
	visible = true
	victory.visible = true
	defeat.visible = false


func show_defeat():
	print("SHOW DEFEAT")
	is_victory = false
	visible = true
	victory.visible = false
	defeat.visible = true


func _on_skip_pressed():
	print("SKIP PRESSED")

	var tree := Engine.get_main_loop()
	if tree == null:
		push_error("SceneTree NULL")
		return

	tree.paused = false
	await tree.process_frame

	if is_victory:
		tree.change_scene_to_file(victory_scene)
	else:
		tree.change_scene_to_file(defeat_scene)



# ==================================================
# UTIL — paksa semua child tetap process saat pause
# ==================================================
func _set_pause_recursive(node: Node):
	process_mode = Node.PROCESS_MODE_ALWAYS

	for c in node.get_children():
		_set_pause_recursive(c)
