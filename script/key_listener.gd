extends Sprite2D

# Memuat scene falling_key milikmu
@onready var falling_key_scene = preload("res://scene/falling_key.tscn")
@export var key_name: String = "ui_accept" # Tombol Space

var falling_key_queue = []

# Threshold jarak (pixel)
var perfect_threshold: float = 20.0
var good_threshold: float = 50.0

func _ready():
	# Hubungkan ke sistem spawn Global jika ada, 
	# atau gunakan SpawnTimer yang sudah kamu punya di game.gd
	pass

func _process(delta):
	# 1. Deteksi Input
	if Input.is_action_just_pressed(key_name):
		_handle_press()

	# 2. Cek MISS (Jika note sudah lewat jauh di bawah target)
	if falling_key_queue.size() > 0:
		var front_key = falling_key_queue.front()
		# Jika posisi Y note lebih besar dari posisi Y target ini + batas aman
		if front_key.global_position.y > (global_position.y + 60.0):
			_on_miss()

func _handle_press():
	if falling_key_queue.size() > 0:
		var key_to_pop = falling_key_queue.pop_front()
		
		# Hitung jarak antara bulatan dan pusat lingkaran target ini
		var distance = abs(global_position.y - key_to_pop.global_position.y)
		
		if distance < perfect_threshold:
			_process_result("PERFECT", 5.0)
		elif distance < good_threshold:
			_process_result("GOOD", 2.0)
		else:
			_process_result("BAD", -1.0)
		
		key_to_pop.queue_free() # Hapus bulatan napas
	else:
		# Penalti jika pencet saat kosong
		GlobalData.reduce_stamina(1.0)

func _process_result(rating: String, stamina_bonus: float):
	print("RESULT: ", rating)
	if stamina_bonus > 0:
		GlobalData.add_stamina(stamina_bonus)
	else:
		GlobalData.reduce_stamina(abs(stamina_bonus))

func _on_miss():
	print("RESULT: MISS")
	GlobalData.reduce_stamina(5.0)
	var key_to_remove = falling_key_queue.pop_front()
	key_to_remove.queue_free()

# Fungsi ini dipanggil oleh SpawnTimer di game.gd
func add_new_note(note_inst):
	falling_key_queue.push_back(note_inst)
