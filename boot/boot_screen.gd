extends Control

signal finished_boot

func _ready():
	$Timer.start()

func _input(event):
	if Input.is_action_just_pressed("select_card"):
		finish()

func finish():
	emit_signal("finished_boot")

func _on_timer_timeout():
	$AnimationPlayer.play("boot")
