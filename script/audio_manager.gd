extends Node


# ==================================================
# NODE REFERENCES (AUTOLOAD SAFE)
# ==================================================
@onready var bgm_parent = get_node_or_null("BGM")
@onready var sfx_parent = get_node_or_null("SFX")


# ==================================================
# BGM CONTROL
# ==================================================
func play_bgm(song_name: String):
	if bgm_parent == null:
		return

	_stop_audio_children(bgm_parent)

	var song = bgm_parent.get_node_or_null(song_name)
	if song and song.has_method("play"):
		song.play()


func stop_all_bgm():
	if bgm_parent == null:
		return

	_stop_audio_children(bgm_parent)


# ==================================================
# SFX CONTROL
# ==================================================
func play_sfx(sfx_name: String):
	if sfx_parent == null:
		return

	var sound = sfx_parent.get_node_or_null(sfx_name)
	if sound and sound.has_method("play"):
		sound.play()


func stop_all_sfx():
	if sfx_parent == null:
		return

	_stop_audio_children(sfx_parent)


# ==================================================
# TRANSITION / STOP SFX
# ==================================================
func play_transition_sfx(stage_num: String):
	stop_all_bgm()

	if sfx_parent == null:
		return

	var stop_sfx = sfx_parent.get_node_or_null("stop" + stage_num)
	if stop_sfx and stop_sfx.has_method("play"):
		stop_sfx.play()


# ==================================================
# INTERNAL HELPER (ROBUST & FUTURE-PROOF)
# ==================================================
func _stop_audio_children(parent: Node):
	for child in parent.get_children():
		if child.has_method("stop"):
			child.stop()
