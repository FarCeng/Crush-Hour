extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var setting: Control = $Setting
@onready var button: AudioStreamPlayer2D = $HBoxContainer/Start/button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	button.play()
	get_tree().change_scene_to_file("res://scene/Scene_Intro.tscn")


func _on_settings_pressed() -> void:
	button.play()
	setting.visible = true
	h_box_container.visible = false


func _on_extras_pressed() -> void:
	button.play()


func _on_exit_pressed() -> void:
	button.play()
	get_tree().quit()
