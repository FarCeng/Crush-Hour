extends Camera2D


# ==================================================
# PARAMETER DASAR
# ==================================================
@export var base_speed: float = 8.0
var time: float = 0.0


# ==================================================
# VARIABEL KONTROL GETARAN
# ==================================================
var current_intensity: float = 0.0
var side_shake_intensity: float = 0.0


# ==================================================
# READY
# ==================================================
func _ready():
	# Set zoom sekali saja (lebih efisien daripada tiap frame)
	zoom = Vector2(1.05, 1.05)


# ==================================================
# PHYSICS PROCESS
# Sinkron dengan parallax & movement
# ==================================================
func _physics_process(delta):
	# Jika tidak ada intensitas, kamera diam
	if current_intensity <= 0.0:
		if offset != Vector2.ZERO:
			offset = Vector2.ZERO
		return

	time += delta

	# Getaran vertikal (Y)
	var offset_y = sin(time * base_speed) * current_intensity

	# Getaran horizontal (X / side shake)
	var offset_x = 0.0
	if fmod(time, 4.0) < 0.5:
		offset_x = sin(time * base_speed * 2.0) * side_shake_intensity

	# Terapkan offset kamera
	offset = Vector2(offset_x, offset_y)
