extends Control

var isPaused := false

signal exit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pause_pressed():
	isPaused = !isPaused
	get_tree().paused = isPaused
	$paused_stuff.visible = isPaused

func _on_continue_pressed():
	_on_pause_pressed()

func _on_exit_pressed():
	emit_signal("exit")
	_on_pause_pressed()
