extends Camera2D

# Parameter Getaran Utama (Sumbu Y)
@export var base_intensity: float = 1.2
@export var base_speed: float = 8.0

# Parameter Guncangan Berkala (Sumbu X)
@export var side_shake_intensity: float = 2.0
@export var side_shake_interval: float = 4.0 # Muncul setiap 4 detik
var time: float = 0.0

func _process(delta):
	time += delta
	
	# 1. Getaran Y yang halus dan konstan
	var offset_y = sin(time * base_speed) * base_intensity
	
	# 2. Getaran X yang hanya muncul sesekali
	var offset_x = 0.0
	
	# Menggunakan fmod untuk mengecek apakah sudah masuk waktu guncangan samping
	# Kita beri durasi guncangan sekitar 0.5 detik setiap intervalnya
	if fmod(time, side_shake_interval) < 0.5:
		# EXAMPLE: Sumbu X bergetar lebih kasar saat dipicu
		offset_x = sin(time * (base_speed * 2.0)) * side_shake_intensity
	
	# Terapkan ke offset kamera
	self.offset = Vector2(offset_x, offset_y)
	self.zoom = Vector2(1.05, 1.05)
