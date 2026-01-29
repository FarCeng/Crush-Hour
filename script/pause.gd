extends Control

@onready var pause: Control = self
@onready var button: AudioStreamPlayer2D = $Panel/VBoxContainer/Resume/button
@onready var setting: Control = $Setting
@onready var panel: Panel = $Panel

func _enter_tree():
	# UI tetap hidup walau game di-pause
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	pause.visible = false
	setting.visible = false


func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC
		if pause.visible:
			_resume_game()
		else:
			_pause_game()


# ==============================
# PAUSE / RESUME
# ==============================
func _pause_game():
	button.play()
	pause.visible = true
	get_tree().paused = true


func _resume_game():
	button.play()
	pause.visible = false
	get_tree().paused = false


# ==============================
# BUTTON CALLBACK
# ==============================
func _on_resume_pressed():
	button.play()
	get_tree().paused = false
	visible = false



func _on_settings_pressed() -> void:
	button.play()
	panel.visible = false
	setting.visible = true


func _on_exit_m_pressed() -> void:
	button.play()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")


func _on_exit_g_pressed() -> void:
	button.play()
	get_tree().quit()
