extends Control

@onready var setting: Control = $"."
@onready var h_box_container: HBoxContainer = $"../HBoxContainer"
@onready var button: AudioStreamPlayer2D = $TextureButton/button
@onready var v_box_container: VBoxContainer = $"../Panel/VBoxContainer"
@onready var panel: Panel = $"../Panel"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setting.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_texture_button_pressed() -> void:
	button.play()
	setting.visible = false
	h_box_container.visible = true
	panel.visible = true
