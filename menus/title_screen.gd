extends Node2D

signal play
signal instructions
@export var playingIntro := true

func _input(event):
	if Input.is_action_just_pressed("select_card") and playingIntro:
		playingIntro = false
		$buttons/AnimationPlayer.play("RESET")
		$title_label/AnimationPlayer.play("RESET")
		await $title_label/AnimationPlayer.animation_finished
		$title_label/AnimationPlayer.play("idle")

func playIntro():
	$title_label/AnimationPlayer.play("start")

func _on_play_pressed():
	emit_signal("play")

func _on_instructions_pressed():
	emit_signal("instructions")
