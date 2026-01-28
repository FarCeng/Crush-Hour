extends Node2D

# --- KONFIGURASI RITME (Taiko Vertikal) ---
const PERFECT_RANGE = 20.0
const GOOD_RANGE = 50.0

# 1. ATUR POSISI HIT POINT DI SINI
# 550.0 artinya target ada di bagian bawah layar.
# Ubah angkanya (misal ke 300.0) jika ingin target lebih ke tengah.
const HIT_ZONE_Y = 936.0 

@onready var note_scene = preload("res://scene/falling_key.tscn") 
var falling_key_queue = []

func _ready():
	$PhaseTimer.start(5.0)
	$StationTimer.start(30.0)
	
	# 2. SET SPAWN KONSTAN SETIAP 3 DETIK
	$SpawnTimer.wait_time = 3.0 
	$SpawnTimer.start()
	
	print("--- DEBUG MODE START ---")
	print("Hit Zone berada di Y: ", HIT_ZONE_Y)

func _process(delta):
	$CanvasLayer/StaminaBar.value = GlobalData.stamina
	# Drain pasif
	var current_rate = GlobalData.drain_rates[GlobalData.current_station]
	GlobalData.reduce_stamina(current_rate * delta)
	
	# 3. DEBUGGING MISS
	if falling_key_queue.size() > 0:
		var current_key = falling_key_queue.front()
		if current_key.global_position.y > (HIT_ZONE_Y + GOOD_RANGE):
			_on_miss()

	# Cek Kalah
	if GlobalData.stamina <= 0:
		print("DEBUG: MC Pingsan! Stamina Habis.")
		set_process(false)

	if Input.is_action_just_pressed("ui_accept"):
		_handle_rhythm_input()

func _handle_rhythm_input():
	if falling_key_queue.size() > 0:
		var current_key = falling_key_queue.front()
		var distance = abs(current_key.global_position.y - HIT_ZONE_Y)
		
		# 4. PRINT DEBUG UNTUK JARAK HIT
		print("DEBUG HIT: Jarak ke Target = ", snapped(distance, 0.1))
		
		if distance <= PERFECT_RANGE:
			_process_hit(current_key, "PERFECT", 5.0)
		elif distance <= GOOD_RANGE:
			_process_hit(current_key, "GOOD", 2.0)
		else:
			print("DEBUG RESULT: BAD (Terlalu Cepat/Jauh!)")
			GlobalData.reduce_stamina(2.0)
	else:
		print("DEBUG RESULT: GHOST HIT (Pencet saat kosong)")
		GlobalData.reduce_stamina(1.0)

func _process_hit(note, rating, bonus):
	print("DEBUG RESULT: ", rating, "! Stamina +", bonus)
	GlobalData.add_stamina(bonus)
	note.on_hit() 
	falling_key_queue.pop_front()

func _on_miss():
	print("DEBUG RESULT: MISS! (Note terlewat). Stamina -5.0")
	GlobalData.reduce_stamina(5.0)
	falling_key_queue.pop_front()

func _on_spawn_timer_timeout():
	var n = note_scene.instantiate()
	add_child(n)
	# Pastikan X sesuai dengan posisi jalur visualmu (misal 900)
	n.global_position = Vector2(1728, -50) 
	falling_key_queue.push_back(n)
	print("DEBUG: Note Muncul!")   
# Menghubungkan script ke Node ProgressBar
@onready var bar_ketahanan = $bar_ketahanan 
# Menghubungkan script ke inhaler
@onready var animasi_mc = $inhaler
@onready var inhaler_ui = $inhaler/inhaler_ui
@onready var stok_label = $inhaler/inhaler_ui/Label

# var bar ketahanan
var health = 100.0
var decay_rate = 2.5 # 1% per detik untuk Stasiun 1

# var inhaler
var inhaler_stok = 5           # Jatah inhaler
var inhaler_cooldown = 3.0    # Waktu tunggu (3 detik)
var bisa_pakai_inhaler = true  # Status apakah boleh pakai sekarang

func _ready():
	# Update angka stok di awal game
	stok_label.text = str(inhaler_stok)
	inhaler_ui.value = 0 # Bar kosong karena siap pakai
	# Mengambil resource animasi dan mematikan loop untuk animasi "pakai_inhaler"
	var frames = animasi_mc.sprite_frames
	frames.set_animation_loop("inhaler", false)

func _process(delta):
	health -= decay_rate * delta
	bar_ketahanan.value = health
	
	if health <= 0:
		game_over()
	
	if health > 100:
		health = 100
		
	# PERBAIKAN VISUAL COOLDOWN
	if not bisa_pakai_inhaler:
		# Kurangi nilai berdasarkan waktu nyata (delta)
		inhaler_ui.value -= (100.0 / inhaler_cooldown) * delta
		
		# Jika nilai sudah mendekati atau di bawah 0, pastikan berhenti di 0
		if inhaler_ui.value <= 0:
			inhaler_ui.value = 0
			bisa_pakai_inhaler = true # Aktifkan kembali di sini agar lebih sinkron
			print("Inhaler siap!")

func _input(event):
	# Cek apakah event-nya adalah pengetikan keyboard
	if event is InputEventKey:
		# Cek apakah tombol yang ditekan adalah huruf I dan baru saja ditekan (bukan ditahan)
		if event.pressed and event.keycode == KEY_I:
			
			# Cek syarat: stok masih ada DAN tidak sedang cooldown
			if inhaler_stok > 0 and bisa_pakai_inhaler:
				gunakan_inhaler()
			else:
				if inhaler_stok <= 0:
					print("Stok habis!")
				else:
					print("Sabar, masih sesak! (Cooldown)")

func gunakan_inhaler():
	health += 10
	inhaler_stok -= 1
	stok_label.text = str(inhaler_stok)
	
	# MEMULAI ANIMASI
	animasi_mc.play("inhaler")
	
	# Mulai Cooldown
	bisa_pakai_inhaler = false
	inhaler_ui.value = 100 

func game_over():
	print("MC Pingsan! Game Over.")
	# Di sini nanti kamu bisa munculkan layar kalah
	get_tree().paused = true # Menghentikan game sejenak
