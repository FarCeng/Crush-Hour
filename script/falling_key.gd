extends Sprite2D

@export var fall_speed: float = 350.0 # Kecepatan jatuh vertikal 

func _process(delta):
	# Objek bergerak turun ke arah target di bawah 
	position.y += fall_speed * delta

func on_hit():
	# Dipanggil oleh game.gd saat berhasil di-hit 
	queue_free()
