extends Node2D

var gameScene = load("res://game.tscn")
var titleScreenScene = load("res://menus/title_screen.tscn")
var instructionsScene = load("res://menus/instructions.tscn")
var difficultyScene = load("res://menus/difficulty_selector.tscn")
@onready var loadedScreen = $boot_screen

func loadGame():
	await loadScene(gameScene)
	loadedScreen.connect("end_game", loadMainMenu)
	loadedScreen.connect("restart_game", loadGame)

func loadMainMenu():
	await loadScene(titleScreenScene)
	loadedScreen.connect("play", loadDifficultySelection)
	loadedScreen.connect("instructions", loadInstructions)
	
func loadInstructions():
	await loadScene(instructionsScene)
	loadedScreen.connect("exit", loadMainMenu)

func loadDifficultySelection():
	await loadScene(difficultyScene)
	loadedScreen.connect("start_game", loadGame)
	loadedScreen.connect("exit", loadMainMenu)
	
func loadScene(scene : PackedScene):
	var TW = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	TW.tween_property(loadedScreen, "modulate:a", 0, 0.1)
	await TW.finished
	
	loadedScreen.queue_free()
	loadedScreen = scene.instantiate()
	add_child(loadedScreen)
	
	TW = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	loadedScreen.modulate.a = 0
	TW.tween_property(loadedScreen, "modulate:a", 1.0, 0.1)

func _on_boot_screen_finished_boot():
	loadedScreen.queue_free()
	loadedScreen = titleScreenScene.instantiate()
	loadedScreen.fadeInButtons()
	add_child(loadedScreen)
	loadedScreen.connect("play", loadDifficultySelection)
	loadedScreen.connect("instructions", loadInstructions)
