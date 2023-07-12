extends Control

signal move_to_end

func move():
	emit_signal("move_to_end", self)
