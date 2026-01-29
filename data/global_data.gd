extends Node


# ==================================================
# SIGNAL (UNTUK UPDATE UI OTOMATIS)
# ==================================================
# UI bisa connect langsung ke signal ini
signal stamina_changed(new_value)
signal station_changed(new_station)
signal inhaler_changed(new_count)


# ==================================================
# STATUS MC & GAME STATE
# ==================================================
var is_inhaling: bool = true          # Digunakan game.gd
var is_transitioning: bool = false
var is_game_over: bool = false

var stamina_recovery_amount = [20.0, 30.0, 40.0]
var start_delay_timer = 5.0           # Jeda sebelum stamina turun lagi


# ==================================================
# STAMINA & INHALER (DENGAN SETTER)
# ==================================================
var stamina: float = 100.0:
	set(value):
		stamina = clamp(value, 0.0, 100.0)
		emit_signal("stamina_changed", stamina)


var inhaler_count: int = 5:
	set(value):
		inhaler_count = value
		emit_signal("inhaler_changed", inhaler_count)


# ==================================================
# PROGRES PERJALANAN
# ==================================================
var current_station: int = 1:
	set(value):
		current_station = value
		emit_signal("station_changed", current_station)


# ==================================================
# KONFIGURASI KESULITAN
# Stamina berkurang per detik tiap stasiun
# ==================================================
var drain_rates = {
	1: 1.0,   # Stasiun 1 → 2
	2: 5.0,   # Stasiun 2 → 3
	3: 10.0   # Stasiun 3 → 4 (paling sesak)
}


# ==================================================
# READY
# ==================================================
func _ready():
	reset_game()


# ==================================================
# STAMINA CONTROL
# ==================================================
func add_stamina(amount: float):
	if not is_game_over:
		stamina += amount


func reduce_stamina(amount: float):
	if not is_game_over:
		stamina -= amount
		if stamina <= 0:
			trigger_game_over()


# ==================================================
# INHALER
# ==================================================
func use_inhaler() -> bool:
	if inhaler_count > 0 and not is_game_over:
		inhaler_count -= 1
		add_stamina(10.0)   # Bonus sesuai GDD
		return true
	return false


# ==================================================
# GAME STATE
# ==================================================
func trigger_game_over():
	is_game_over = true
	print("MC Pingsan atau Sampai Tujuan!")


func reset_game():
	stamina = 100.0
	inhaler_count = 5
	current_station = 1
	is_inhaling = true
	is_game_over = false
