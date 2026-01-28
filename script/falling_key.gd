extends Area2D

# 1. Pastikan baris ini ada agar game.gd bisa memberikan data "O2" atau "CO2"
@export var note_type: String = "O2" 

@onready var sprite = $Sprite2D

# EXAMPLE: Menyiapkan aset untuk dua jenis gas [cite: 2025-09-06]
var tex_o2 = preload("res://assets/o2.png") # Ganti dengan path aslimu
var tex_co2 = preload("res://assets/co2.png")  # Ganti dengan path aslimu

func _ready():
	# EXAMPLE: Logika ganti tekstur berdasarkan tipe yang dikirim game.gd [cite: 2025-09-06]
	if note_type == "CO2":
		sprite.texture = tex_co2
	else:
		sprite.texture = tex_o2

func _process(delta):
	# Kecepatan jatuh
	position.y += 350 * delta

func on_hit():
	# EXAMPLE: Menghapus note dari memori saat berhasil di-hit [cite: 2025-09-06]
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	pass # Replace with function body.
