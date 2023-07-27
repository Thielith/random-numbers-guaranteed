extends Control

var difficultyScene = load("res://menus/difficulty_choice.tscn")
var spacer = load("res://menus/spacer_v.tscn")

signal start_game
signal exit

func _ready():
	# create options on fly in case I want to add more in the future
	for i in range(global.difficulties.size()):
		var newChoice = difficultyScene.instantiate()
		newChoice.loadData(i)
		newChoice.connect("load_game", on_difficulty_selected)
		$VBoxContainer.add_child(newChoice)
		
		# makes sure there isnt an extra spacer at the end
		# because it would shift everything up slightly
		if i != global.difficulties.size():
			var space = spacer.instantiate()
			$VBoxContainer.add_child(space)

func on_difficulty_selected(index : int):
	global.chosenDifficulty = global.difficulties[index]
	emit_signal("start_game")

func on_exit_button_pressed():
	emit_signal("exit")
