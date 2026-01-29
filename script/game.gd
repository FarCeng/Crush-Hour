extends Node2D


# ==================================================
# KONFIGURASI RITME
# ==================================================
const GOOD_RANGE = 120.0


# ==================================================
# NODE REFERENCES
# ==================================================
@onready var note_scene     = preload("res://scene/falling_key.tscn")
@onready var key_listener   = $KeyListener
@onready var bar_nyawa      = $CanvasLayer/StaminaBar
@onready var bg_anim        = $ShakeContainer/Bg
@onready var bg_layer       = $ParallaxBackground/BackgroundLayer
@onready var camera         = $ShakeContainer/Camera2D
@onready var mc_anim        = $ShakeContainer/PlayerMC
@onready var inhaler_anim = $Inhaler
@onready var blink_anim = $BlinkEffect/TopLid/AnimationPlayer
@onready var space_label = $SpaceHintLabel
@onready var inhaler_count_label = $InhalerCount
@onready var space_delay_timer = $SpaceDelayTimer


# ==================================================
# SISTEM INHALER
# ==================================================



# ==================================================
# VARIABEL KONTROL
# ==================================================
var is_transitioning = false
var stage_timer_habis = false
var stamina_recovery_amount = [0, 20.0, 30.0, 40.0]
var start_delay_timer = 5.0
var sedang_menunggu_input = false
var show_space_hint = false


# ==================================================
# VARIABEL RITME & PARALLAX
# ==================================================
var scroll_speed = 1000.0
var current_scroll_speed = 0.0
var falling_key_queue = []


# ==================================================
# VARIABEL INHALER (LOGIKA TETAP)
# ==================================================
var inhaler_stok = 5
var inhaler_cooldown = 3.0
var bisa_pakai_inhaler = true
var inhaler_timer = 0.0


# ==================================================
# READY
# ==================================================
func _ready():
	inhaler_count_label.text = str(inhaler_stok)

	bg_layer.motion_offset.x = 0
	current_scroll_speed = 0

	sedang_menunggu_input = true
	space_label.visible = true

	bg_anim.play("start")
	mc_anim.play("stage1")
	inhaler_anim.play("unused")

	$SpawnTimer.stop()
	$StationTimer.stop()
	$PhaseTimer.stop()

	update_npc_visibility()


# ==================================================
# PHYSICS PROCESS
# ==================================================
func _physics_process(delta):
	# Transisi stage
	if stage_timer_habis and falling_key_queue.is_empty() and not is_transitioning:
		if GlobalData.current_station == 3:
			start_stage_transition(true)
		else:
			start_stage_transition(false)

	# Parallax
	if not sedang_menunggu_input:
		bg_layer.motion_offset.x -= current_scroll_speed * delta

	bar_nyawa.value = GlobalData.stamina

	# Drain stamina
	if not is_transitioning and not sedang_menunggu_input and current_scroll_speed > 100:
		GlobalData.reduce_stamina(
			GlobalData.drain_rates[GlobalData.current_station] * delta
		)


	# Auto miss
	if not falling_key_queue.is_empty():
		var current_key = falling_key_queue.front()
		if is_instance_valid(current_key):
			if current_key.global_position.y > key_listener.global_position.y + GOOD_RANGE:
				_on_miss()

	# Cooldown inhaler
	if not bisa_pakai_inhaler:
		inhaler_timer -= delta
		if inhaler_timer <= 0:
			bisa_pakai_inhaler = true
			inhaler_anim.play("unused")
			_update_player_animation()


	# Game over
	if GlobalData.stamina <= 0:
		_game_over()


# ==================================================
# TRANSISI STAGE
# ==================================================
func start_stage_transition(is_finish: bool = false):
	is_transitioning = true
	$StationTimer.stop()

	var audio_num = str(GlobalData.current_station + 1)
	AudioManager.stop_all_bgm()
	AudioManager.play_sfx("stop" + audio_num)

	var stop_tween = create_tween().set_parallel(true)
	stop_tween.tween_property(self, "current_scroll_speed", 0.0, 2.5).set_trans(Tween.TRANS_SINE)
	stop_tween.tween_property(camera, "current_intensity", 0.0, 2.5).set_trans(Tween.TRANS_SINE)
	stop_tween.tween_property(camera, "side_shake_intensity", 0.0, 2.5).set_trans(Tween.TRANS_SINE)

	var current_x = fmod(bg_layer.motion_offset.x, 3840.0)
	bg_layer.motion_offset.x = current_x
	var target_x = -3840.0 if current_x < -1920.0 else 0.0

	var p_tween = create_tween()
	p_tween.tween_property(
		bg_layer,
		"motion_offset:x",
		target_x,
		3.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await p_tween.finished

	if is_finish:
		_game_win()
	else:
		sedang_menunggu_input = true
		_show_space_hint_delayed(25.0)

		bg_anim.play("transition")
		AudioManager.play_sfx("door")

		sedang_menunggu_input = true
		GlobalData.add_stamina(stamina_recovery_amount[GlobalData.current_station])



# ==================================================
# PERSIAPAN STAGE BERIKUTNYA
# ==================================================
func prepare_next_stage():
	if is_transitioning and GlobalData.current_station > 0:
		GlobalData.current_station += 1
	elif GlobalData.current_station == 0:
		GlobalData.current_station = 1

	update_npc_visibility()
	_update_player_animation()

	stage_timer_habis = false
	bg_anim.play("default")

	var ty = 0.0
	var tx = 0.0

	match GlobalData.current_station:
		1:
			scroll_speed = 1000.0
			ty = 1.2
			tx = 2.0
			$StationTimer.start(1.0)
			$SpawnTimer.wait_time = 0.9
		2:
			scroll_speed = 1300.0
			ty = 2.5
			tx = 4.0
			$StationTimer.start(40.0)
			$SpawnTimer.wait_time = 0.7
		3:
			scroll_speed = 1600.0
			ty = 4.5
			tx = 7.0
			$StationTimer.start(40.0)
			$SpawnTimer.wait_time = 0.5
		4:
			_game_win()
			return

	AudioManager.play_bgm("s" + str(GlobalData.current_station))

	if AudioManager.bgm_parent:
		var train_sound = AudioManager.bgm_parent.get_node_or_null("bg kereta")
		if train_sound and not train_sound.playing:
			train_sound.play()

	current_scroll_speed = 0.0
	camera.current_intensity = 0.0
	camera.side_shake_intensity = 0.0

	var start_tween = create_tween().set_parallel(true)
	start_tween.tween_property(self, "current_scroll_speed", scroll_speed, 3.0).set_trans(Tween.TRANS_SINE)
	start_tween.tween_property(camera, "current_intensity", ty, 3.0).set_trans(Tween.TRANS_SINE)
	start_tween.tween_property(camera, "side_shake_intensity", tx, 3.0).set_trans(Tween.TRANS_SINE)

	$SpawnTimer.start()
	$PhaseTimer.start(5.0)

	is_transitioning = true
	await get_tree().create_timer(start_delay_timer).timeout
	is_transitioning = false


# ==================================================
# PLAYER & INHALER
# ==================================================
func gunakan_inhaler():
	GlobalData.add_stamina(10.0)
	inhaler_stok -= 1
	inhaler_count_label.text = str(inhaler_stok)

	bisa_pakai_inhaler = false
	inhaler_timer = inhaler_cooldown

	inhaler_anim.play("use_animation")
	inhaler_anim.frame = 0

	mc_anim.play("inhaler")
	AudioManager.play_sfx("inhaler")

func _update_player_animation():
	if mc_anim.animation == "inhaler" and not bisa_pakai_inhaler:
		return
	mc_anim.play("stage" + str(GlobalData.current_station))

func _on_Inhaler_animation_finished():
	if not bisa_pakai_inhaler:
		inhaler_anim.play("used")


# ==================================================
# TIMER CALLBACK
# ==================================================
func _on_station_timer_timeout():
	$SpawnTimer.stop()
	stage_timer_habis = true


# ==================================================
# INPUT
# ==================================================
func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		if not sedang_menunggu_input:
			return

		space_delay_timer.stop()
		space_label.visible = false

		blink_anim.play("blink")
		AudioManager.stop_all_bgm()
		AudioManager.stop_all_sfx()
		AudioManager.play_sfx("button")

		sedang_menunggu_input = false
		prepare_next_stage()
		return


	if Input.is_action_just_pressed("mouse_left"):
		key_listener.get_node("AnimationPlayer").play("inhale")
		_handle_rhythm_input("O2")
	elif Input.is_action_just_pressed("mouse_right"):
		key_listener.get_node("AnimationPlayer").play("exhale")
		_handle_rhythm_input("CO2")

	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		if inhaler_stok > 0 and bisa_pakai_inhaler:
			gunakan_inhaler()

func _show_space_hint_delayed(delay := 3.0):
	space_delay_timer.stop()
	space_delay_timer.wait_time = delay
	space_label.visible = false
	space_delay_timer.start()


func _on_SpaceDelayTimer_timeout():
	space_label.visible = true


# ==================================================
# RITME SYSTEM
# ==================================================
func _handle_rhythm_input(input_type):
	if falling_key_queue.is_empty():
		return

	var current_key = falling_key_queue.front()
	var dist = abs(current_key.global_position.y - key_listener.global_position.y)

	if current_key.global_position.y < 300 or dist > 130.0:
		return

	var rating = "BAD"
	var score = 5.0

	if key_listener.get_node("PerfectZone").overlaps_area(current_key):
		rating = "PERFECT"
		score = 6.0
	elif key_listener.get_node("GoodZone").overlaps_area(current_key):
		rating = "GOOD"
		score = 3.0

	if current_key.note_type == input_type:
		AudioManager.play_sfx(input_type.to_lower())
		_process_hit(current_key, rating, score)
	else:
		_handle_bad_input(current_key)


func _handle_bad_input(note):
	GlobalData.reduce_stamina(5.0)
	AudioManager.play_sfx("miss")

	note.queue_free()
	falling_key_queue.pop_front()



func _process_hit(note, rating, score):
	if rating == "BAD":
		GlobalData.reduce_stamina(score)
		AudioManager.play_sfx("miss")
	else:
		GlobalData.add_stamina(score)

	note.on_hit()
	falling_key_queue.pop_front()



func _on_miss():
	GlobalData.reduce_stamina(5.0)
	AudioManager.play_sfx("miss")

	var missed_note = falling_key_queue.front()
	if is_instance_valid(missed_note):
		missed_note.queue_free()
	falling_key_queue.pop_front()



# ==================================================
# SPAWN NOTE
# ==================================================
func _on_spawn_timer_timeout():
	var n = note_scene.instantiate()
	n.note_type = "O2" if randf() < 0.5 else "CO2"

	add_child(n)
	n.global_position = Vector2(key_listener.global_position.x, -50)
	falling_key_queue.push_back(n)


# ==================================================
# NPC & END STATE
# ==================================================
func update_npc_visibility():
	for i in range(1, 4):
		$ShakeContainer/NPC.get_node("Stage" + str(i)).visible = (
			GlobalData.current_station == i
		)


func _game_win():
	set_physics_process(false)
	$SpawnTimer.stop()


func _game_over():
	set_physics_process(false)
	get_tree().paused = true
	AudioManager.stop_all_bgm()
	AudioManager.play_sfx("lose")
