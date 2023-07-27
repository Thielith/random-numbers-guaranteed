extends ProgressBar

var lifeTimePercentage : float
signal timer_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $Timer.is_stopped():
		lifeTimePercentage = ($Timer.time_left / $Timer.wait_time)
		value = lifeTimePercentage * 100

func stop():
	$Timer.stop()
	$AnimationPlayer.play("stop")

func _on_timer_timeout():
	emit_signal("timer_finished")
