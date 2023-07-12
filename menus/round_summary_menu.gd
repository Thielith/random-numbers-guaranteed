extends Node2D

signal restart
signal exit

func displayPoints(num : int):
	$stuff/VBoxContainer/points.text = "Points: " + str(num)

func _on_restart_pressed():
	get_tree().paused = false
	emit_signal("restart")

func _on_end_pressed():
	get_tree().paused = false
	emit_signal("exit")
