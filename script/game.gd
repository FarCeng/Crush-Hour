extends Node2D

# --- KONFIGURASI RITME ---
const GOOD_RANGE = 120.0 

@onready var note_scene = preload("res://scene/falling_key.tscn")
@onready var key_listener = $KeyListener
@onready var status_label = $CanvasLayer/StatusLabel
@onready var score_popup = $CanvasLayer/ScorePopUp
@onready var bg_layer = $ParallaxBackground/BackgroundLayer
# Gunakan StaminaBar di CanvasLayer sebagai indikator utama
@onready var bar_nyawa = $CanvasLayer/StaminaBar 

# --- SISTEM INHALER ---
@onready var inhaler_ui = $CanvasLayer/inhaler_ui
@onready var stok_label = $CanvasLayer/inhaler_ui/Label

# --- VARIABEL RITME ---
var scroll_speed = 1000.0
var falling_key_queue = []

# --- VARIABEL ITEM ---
var inhaler_stok = 5
var inhaler_cooldown = 3.0
var bisa_pakai_inhaler = true

func _ready():
	# Inisialisasi Ritme
	$PhaseTimer.start(5.0)
	$StationTimer.start(30.0)
	$SpawnTimer.wait_time = 1.0 
	$SpawnTimer.start()
	
	# Inisialisasi Item
	stok_label.text = str(inhaler_stok)
	inhaler_ui.value = 0 

	print("--- SYSTEMS INTEGRATED: SINGLE STAMINA SYSTEM ---")

func _process(delta):
	# 1. Logika Parallax
	bg_layer.motion_offset.x -= scroll_speed * delta
	
	# 2. Update UI Stamina dari GlobalData [cite: 2025-09-06]
	bar_nyawa.value = GlobalData.stamina
	
	# 3. Drain pasif GlobalData otomatis mengikuti current_station [cite: 2025-09-06]
	var current_rate = GlobalData.drain_rates[GlobalData.current_station]
	GlobalData.reduce_stamina(current_rate * delta)
	
	# 4. Update Label Informasi Stasiun
	var time_left = snapped($StationTimer.time_left, 0.1)
	status_label.text = "Stasiun: " + str(GlobalData.current_station) + "\nLanjut dalam: " + str(time_left) + "s"

	# 5. Deteksi MISS Ritme
	if falling_key_queue.size() > 0:
		var current_key = falling_key_queue.front()
		if current_key.global_position.y > (key_listener.global_position.y + GOOD_RANGE):
			_on_miss()
	
	# 6. Perbaikan Visual Cooldown Inhaler
	if not bisa_pakai_inhaler:
		inhaler_ui.value -= (100.0 / inhaler_cooldown) * delta
		if inhaler_ui.value <= 0:
			inhaler_ui.value = 0
			bisa_pakai_inhaler = true 
	
	# 7. Cek Kondisi Kalah
	if GlobalData.stamina <= 0:
		_game_over()

func _input(event):
	if Input.is_action_just_pressed("mouse_left"):
		key_listener.get_node("AnimationPlayer").play("inhale")
		_handle_rhythm_input("O2")
	if Input.is_action_just_pressed("mouse_right"):
		key_listener.get_node("AnimationPlayer").play("exhale")
		_handle_rhythm_input("CO2")

	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		if inhaler_stok > 0 and bisa_pakai_inhaler:
			gunakan_inhaler()

# --- FUNGSI ITEM ---

func gunakan_inhaler():
	# EXAMPLE: Tambah stamina langsung ke sistem global [cite: 2025-09-06]
	GlobalData.add_stamina(10.0) 
	inhaler_stok -= 1
	stok_label.text = str(inhaler_stok)
	
	_show_feedback("INHALER", 10.0)
	
	bisa_pakai_inhaler = false
	inhaler_ui.value = 100 

# --- FUNGSI RITME ---

func _handle_rhythm_input(input_type):
	if falling_key_queue.size() == 0:
		return
	var current_key = falling_key_queue.front()
	
	if key_listener.get_node("GhostZone").overlaps_area(current_key):
		_show_feedback("TOO EARLY", -2.0) 
		GlobalData.reduce_stamina(2.0)
		return 

	elif current_key.note_type != input_type:
		return

	elif key_listener.get_node("PerfectZone").overlaps_area(current_key):
		_process_hit(current_key, "PERFECT", 8.0)
	elif key_listener.get_node("GoodZone").overlaps_area(current_key):
		_process_hit(current_key, "GOOD", 4.0)
	elif key_listener.get_node("BadZone").overlaps_area(current_key):
		_process_hit(current_key, "BAD", 2.0)

func _process_hit(note, rating, score):
	_show_feedback(rating, score if rating != "BAD" else -score)
	
	if rating == "BAD":
		GlobalData.reduce_stamina(score)
	else:
		GlobalData.add_stamina(score)
		
	note.on_hit()
	falling_key_queue.pop_front()

func _on_miss():
	_show_feedback("MISS", -5.0)
	GlobalData.reduce_stamina(5.0)
	
	var missed_note = falling_key_queue.front()
	if is_instance_valid(missed_note):
		missed_note.queue_free()
	falling_key_queue.pop_front()

func _on_spawn_timer_timeout():
	var chance = randf() * 100
	if chance < 40:
		_create_note("O2")
	elif chance < 80:
		_create_note("CO2")

func _create_note(type: String):
	var n = note_scene.instantiate()
	n.note_type = type 
	add_child(n)
	n.global_position = Vector2(key_listener.global_position.x, -50)
	falling_key_queue.push_back(n)

func _show_feedback(rating: String, score_val: float):
	var tween = create_tween()
	var sign_str = "+" if score_val > 0 else ""
	score_popup.text = rating + " (" + sign_str + str(score_val) + ")"
	
	match rating:
		"PERFECT": score_popup.modulate = Color.GOLD
		"GOOD": score_popup.modulate = Color.GREEN
		"INHALER": score_popup.modulate = Color.CYAN
		_: score_popup.modulate = Color.RED
	
	score_popup.position.y = 200 
	tween.tween_property(score_popup, "position:y", 150, 0.3)
	tween.parallel().tween_property(score_popup, "modulate:a", 1.0, 0.1)
	tween.tween_property(score_popup, "modulate:a", 0.0, 0.5).set_delay(0.2)

# --- GAME STATE ---

func _on_station_timer_timeout():
	GlobalData.current_station += 1
	if GlobalData.current_station == 2:
		GlobalData.add_stamina(20.0)
		$StationTimer.start(40.0)
		$SpawnTimer.wait_time = 0.6
	elif GlobalData.current_station == 3:
		GlobalData.add_stamina(30.0)
		$StationTimer.start(40.0)
		$SpawnTimer.wait_time = 0.4
	elif GlobalData.current_station == 4:
		_game_win()

func _game_win():
	set_process(false)
	$SpawnTimer.stop()
	status_label.text = "STASIUN AKHIR\nMC Selamat!"

func _game_over():
	set_process(false)
	get_tree().paused = true
