extends Node2D

signal play
signal instructions

func fadeInButtons():
	$buttons/AnimationPlayer.play("show")

func _on_play_button_pressed():
	emit_signal("play")
func _on_instructions_button_pressed():
	emit_signal("instructions")
func _on_quit_button_pressed():
	get_tree().quit()
