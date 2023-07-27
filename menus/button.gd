extends Button

@onready var labelPosition = $Label.position
var snd_button_down = load("res://sounds/snd_button_1_press.mp3")
var snd_button_up = load("res://sounds/snd_button_1_release.mp3")

func _ready():
	createAudioStream()
	connect("button_down", on_button_down)
	connect("button_up", on_button_up)

func createAudioStream():
	var streamPlayer = AudioStreamPlayer.new()
	add_child(streamPlayer)
	streamPlayer.name = "snd_button_event"

func on_button_down():
	$snd_button_event.stream = snd_button_down
	$snd_button_event.play()
	$Label.position.y = labelPosition.y + 15
func on_button_up():
	$snd_button_event.stream = snd_button_up
	$snd_button_event.play()
	$Label.position.y = labelPosition.y
