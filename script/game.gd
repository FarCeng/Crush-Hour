extends Node2D

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
