extends Node2D

# --- KONFIGURASI RITME ---
const GOOD_RANGE = 120.0 # Batas jarak untuk deteksi MISS otomatis

@onready var note_scene = preload("res://scene/falling_key.tscn")
@onready var key_listener = $KeyListener # Referensi ke node manual di Editor
@onready var status_label = $CanvasLayer/StatusLabel # Hubungkan ke Label UI kamu
@onready var score_popup = $CanvasLayer/ScorePopUp
@onready var bg_layer = $ParallaxBackground/BackgroundLayer

var scroll_speed = 1000.0
var falling_key_queue = []

func _ready():
	$PhaseTimer.start(5.0)
	$StationTimer.start(30.0)
	
	# Set durasi spawn antar grup
	$SpawnTimer.wait_time = 1.0 
	$SpawnTimer.start()
	
	print("--- RHYTHM SYSTEM READY ---")

func _process(delta):
	bg_layer.motion_offset.x -= scroll_speed * delta
	
	# Update UI Stamina
	$CanvasLayer/StaminaBar.value = GlobalData.stamina
	
	# EXAMPLE: Update Label Informasi Stasiun & Countdown [cite: 2025-09-06]
	var time_left = snapped($StationTimer.time_left, 0.1)
	status_label.text = "Stasiun: " + str(GlobalData.current_station) + "\nLanjut dalam: " + str(time_left) + "s"
	
	# Drain pasif otomatis mengikuti current_station
	var current_rate = GlobalData.drain_rates[GlobalData.current_station]
	GlobalData.reduce_stamina(current_rate * delta)
	
	# Deteksi MISS
	if falling_key_queue.size() > 0:
		var current_key = falling_key_queue.front()
		if current_key.global_position.y > (key_listener.global_position.y + GOOD_RANGE):
			_on_miss()
	
	if Input.is_action_just_pressed("mouse_left"):
		key_listener.get_node("AnimationPlayer").play("inhale")
		_handle_rhythm_input("O2")
	if Input.is_action_just_pressed("mouse_right"):
		key_listener.get_node("AnimationPlayer").play("exhale")
		_handle_rhythm_input("CO2")
	
	if GlobalData.stamina <= 0:
		_game_over()

func _on_station_timer_timeout():
	# EXAMPLE: Pindah ke stasiun berikutnya sesuai alur GDD
	GlobalData.current_station += 1
	
	if GlobalData.current_station == 2:
		# Stasiun 2: Tambah stamina 20%, durasi 40 detik
		GlobalData.add_stamina(20.0)
		$StationTimer.start(40.0)
		$SpawnTimer.wait_time = 0.6
		print("Tiba di Stasiun 2: Stamina +20%")
		
		
	elif GlobalData.current_station == 3:
		# Stasiun 3: Tambah stamina 30%, durasi 40 detik
		GlobalData.add_stamina(30.0)
		$StationTimer.start(40.0)
		$SpawnTimer.wait_time = 0.4
		print("Tiba di Stasiun 3: Stamina +30%")
		
	elif GlobalData.current_station == 4:
		# Selesai
		print("Selesai! MC Berhasil Sampai Tujuan.")
		_game_win()

func _handle_rhythm_input(input_type):
	# Jika antrian kosong, tidak usah lakukan apa-apa (GHOST HIT dihapus) [cite: 2025-09-06]
	if falling_key_queue.size() == 0:
		return

	var current_key = falling_key_queue.front()
	
	# EXAMPLE: Hirarki pengecekan area yang rapi [cite: 2025-09-06]
	if key_listener.get_node("GhostZone").overlaps_area(current_key):
		_show_feedback("TOO EARLY", -2.0) 
		GlobalData.reduce_stamina(2.0)
		return # Note tetap meluncur, pemain bisa klik lagi nanti [cite: 2025-09-06]
		
	elif current_key.note_type != input_type:
		return
		# Note tidak dihapus agar pemain sadar mereka salah tombol [cite: 2025-09-06]
		
	elif key_listener.get_node("PerfectZone").overlaps_area(current_key):
		_process_hit(current_key, "PERFECT", 8.0)
		
	elif key_listener.get_node("GoodZone").overlaps_area(current_key):
		_process_hit(current_key, "GOOD", 4.0)
		
	elif key_listener.get_node("BadZone").overlaps_area(current_key):
		_process_hit(current_key, "BAD", 2.0)

func _process_hit(note, rating, score):
	_show_feedback(rating, score if rating != "BAD" else -score)
	
	if rating == "GOOD" or rating == "PERFECT":
		print("RESULT: ", rating)
		GlobalData.add_stamina(score)
		
		note.on_hit() # Panggil queue_free di script note
		falling_key_queue.pop_front()
	elif rating == "BAD":
		print("RESULT: ", rating)
		GlobalData.reduce_stamina(score)
		
		note.on_hit() # Panggil queue_free di script note
		falling_key_queue.pop_front()
	

func _on_miss():
	_show_feedback("MISS", -5.0)
	
	print("RESULT: MISS (Terlewat)")
	GlobalData.reduce_stamina(5.0)
	
	# Ambil referensi note yang paling depan
	var missed_note = falling_key_queue.front()
	
	# EXAMPLE: Menghapus objek fisik note segera saat status MISS [cite: 2025-09-06]
	if is_instance_valid(missed_note):
		missed_note.queue_free() # Atau missed_note.on_hit() jika ingin ada efek hancur
	
	# Hapus dari antrian data
	falling_key_queue.pop_front()

func _on_spawn_timer_timeout():
	# Ambil angka acak 0-100
	var chance = randf() * 100
	
	# EXAMPLE: Logika Random berdasarkan probabilitas [cite: 2025-09-06]
	if chance < 40:
		_create_note("O2") # 40% muncul Oksigen
	elif chance < 80:
		_create_note("CO2") # 40% muncul Karbondioksida
	else:
		# 20% sisanya adalah 'Ghost Beat' atau transisi kosong agar tidak terlalu rapat
		print("DEBUG: Metronom Beat (Kosong)")

# Mekanik Spawn Beruntun untuk Testing [cite: 2025-09-06]
func _spawn_sequence():
	var count = 2
	var delay = 0.5
	# EXAMPLE: Variabel baru untuk mengatur jeda antar tipe gas [cite: 2025-09-06]
	var transition_time = 1.0 
	
	if GlobalData.current_station == 2:
		count = 3
		delay = 0.4
		transition_time = 0.8 # Jeda transisi mulai mengecil
	elif GlobalData.current_station >= 3:
		count = 4
		delay = 0.3
		transition_time = 0.5 # Jeda transisi sangat singkat (Stage 3 paling sesak)

	# Grup Oksigen
	for i in range(count):
		_create_note("O2")
		await get_tree().create_timer(delay).timeout 

	# EXAMPLE: Menggunakan variabel transisi yang dinamis [cite: 2025-09-06]
	await get_tree().create_timer(transition_time).timeout 

	# Grup CO2
	for i in range(count):
		_create_note("CO2")
		await get_tree().create_timer(delay).timeout

func _create_note(type: String):
	var n = note_scene.instantiate()
	n.note_type = type 
	add_child(n)
	# X disesuaikan agar lurus dengan KeyListener
	n.global_position = Vector2(key_listener.global_position.x, -50)
	falling_key_queue.push_back(n)

func _show_feedback(rating: String, score_val: float):
	# EXAMPLE: Hentikan tween sebelumnya agar tidak tabrakan [cite: 2025-09-06]
	var tween = create_tween()
	
	var sign_str = "+" if score_val > 0 else ""
	score_popup.text = rating + " (" + sign_str + str(score_val) + ")"
	
	# EXAMPLE: Paksa warna berubah secara konstan berdasarkan rating [cite: 2025-09-06]
	match rating:
		"PERFECT": 
			score_popup.modulate = Color.GOLD
		"GOOD": 
			score_popup.modulate = Color.GREEN
		"TOO EARLY", "WRONG TYPE", "MISS", "BAD": 
			score_popup.modulate = Color.RED
		_: 
			score_popup.modulate = Color.WHITE # Warna default jika tidak ada yang cocok
	
	# Animasi Tween tetap sama
	score_popup.position.y = 200 
	tween.tween_property(score_popup, "position:y", 150, 0.3)
	tween.parallel().tween_property(score_popup, "modulate:a", 1.0, 0.1)
	tween.tween_property(score_popup, "modulate:a", 0.0, 0.5).set_delay(0.2)

func _game_win():
	# Logika saat menang
	set_process(false)
	$SpawnTimer.stop()
	status_label.text = "STASIUN AKHIR\nMC Selamat!"

func _game_over():
	print("GAME OVER: MC Pingsan!")
	set_process(false)
