extends HBoxContainer

var difficultyIndex : int

signal load_game

func loadData(index : int):
	difficultyIndex = index
	$Button/Label.text = global.difficulties[difficultyIndex].name
	$description.text = global.difficulties[difficultyIndex].description

func _on_button_pressed():
	emit_signal("load_game", difficultyIndex)
