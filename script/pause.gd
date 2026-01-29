extends Control

@onready var pause: Control = $"."
@onready var button: AudioStreamPlayer2D = $Panel/VBoxContainer/Resume/button
@onready var setting: Control = $Setting
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var panel: Panel = $Panel



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause.visible = false


func _on_resume_pressed() -> void:
	button.play()
	pause.visible = false
	get_tree().paused = false


func _on_settings_pressed() -> void:
	button.play()
	panel.visible = false
	setting.visible = true

func _on_exit_m_pressed() -> void:
	button.play()


func _on_exit_g_pressed() -> void:
	button.play()
