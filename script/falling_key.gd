extends Area2D

@export var note_type: String = "O2" 

@onready var sprite = $Sprite2D

# OPTIMASI: Gunakan load atau pindahkan preload ke variabel global jika memungkinkan [cite: 2025-09-06]
var tex_o2 = preload("res://assets/o2.png") 
var tex_co2 = preload("res://assets/co2.png") 

func _ready():
	if note_type == "CO2":
		sprite.texture = tex_co2
	else:
		sprite.texture = tex_o2

func _physics_process(delta):
	# Gunakan physics_process agar sinkron dengan game.gd [cite: 2025-09-06]
	position.y += 350 * delta

func on_hit():
	# Menghapus dari memori
	queue_free()

# --- PERBAIKAN KRUSIAL: MENGHAPUS NOTE YANG LEWAT --- [cite: 2025-09-06]
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Jika note keluar dari layar bawah dan tidak di-hit, wajib dihapus! [cite: 2025-09-06]
	# Ini akan menurunkan angka Process Time di Profiler secara drastis
	queue_free()
