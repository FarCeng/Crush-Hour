extends Node

# --- Signal untuk Update UI Otomatis ---
# Teman UI bisa menghubungkan progress bar ke signal ini
signal stamina_changed(new_value)
signal station_changed(new_station)
signal inhaler_changed(new_count)

# --- Variabel Status MC ---
var is_inhaling: bool = true # Perbaikan: Tambahkan ini agar bisa diakses game.gd

var stamina: float = 100.0 :
	set(val):
		stamina = clamp(val, 0, 100)
		emit_signal("stamina_changed", stamina)

var inhaler_count: int = 5 :
	set(val):
		inhaler_count = val
		emit_signal("inhaler_changed", inhaler_count)

# --- Variabel Progres Perjalanan ---
var current_station: int = 1 :
	set(val):
		current_station = val
		emit_signal("station_changed", current_station)

var is_game_over: bool = false

# --- Konfigurasi Kesulitan (Bisa diakses teman System) ---
# Berapa % stamina berkurang per detik di tiap stasiun
var drain_rates = {
	1: 1.0,  # Stasiun 1 ke 2
	2: 1.5,  # Stasiun 2 ke 3
	3: 2.0   # Stasiun 3 ke 4 (paling sesak)
}

func _ready():
	reset_game()

# Fungsi untuk menambah stamina (dipanggil saat hit PERFECT/GOOD)
func add_stamina(amount: float):
	if not is_game_over:
		stamina += amount

# Fungsi untuk mengurangi stamina (dipanggil saat MISS atau drain pasif)
func reduce_stamina(amount: float):
	if not is_game_over:
		stamina -= amount
		if stamina <= 0:
			trigger_game_over()

# Fungsi pakai inhaler (maksimal 5x sesuai GDD)
func use_inhaler() -> bool:
	if inhaler_count > 0 and not is_game_over:
		inhaler_count -= 1
		add_stamina(10.0) # Bonus 10% sesuai GDD
		return true
	return false

func trigger_game_over():
	is_game_over = true
	print("MC Pingsan atau Sampai Tujuan!")

func reset_game():
	stamina = 100.0
	inhaler_count = 5
	current_station = 1
	is_inhaling = true # Reset fase ke awal (menghirup)
	is_game_over = false
