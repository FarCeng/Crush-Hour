extends Control

@onready var pause_2: Control = $Pause2
@onready var setting_2: Control = $Pause2/Setting2
@onready var stay: TextureButton = $Panel/Stay
@onready var ride: TextureButton = $Panel/Ride
@onready var button: AudioStreamPlayer2D = $Panel/Pause/button


func _on_pause_pressed() -> void:
	button.play()
	pause_2.visible = true
	get_tree().paused = true


func _on_stay_pressed() -> void:
	button.play()
	get_tree().change_scene_to_file("res://scene/sleep.tscn")


func _on_ride_pressed() -> void:
	button.play()
	get_tree().change_scene_to_file("res://scene/game.tscn")


func _on_confirm_pressed() -> void:
	pass # Replace with function body.
