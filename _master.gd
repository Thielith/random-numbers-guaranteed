extends Node2D

var gameScene = load("res://game.tscn")
var titleScreenScene = load("res://menus/title_screen.tscn")
var instructionsScene = load("res://menus/instructions.tscn")
var loadedScreen :  Node2D

var overlayScreen : Node2D = null

func _ready():
	loadedScreen = $title_screen
	loadedScreen.connect("play", on_play_pressed)
	loadedScreen.connect("instructions", on_instructions_pressed)

func on_play_pressed():
	loadedScreen.queue_free()
	loadedScreen = gameScene.instantiate()
	loadedScreen.connect("restart_game", on_play_pressed)
	loadedScreen.connect("end_game", on_game_exit)
	add_child(loadedScreen)

func on_instructions_pressed():
	overlayScreen = instructionsScene.instantiate()
	overlayScreen.connect("exit", on_instructions_exit)
	add_child(overlayScreen)

func on_game_exit():
	loadedScreen.queue_free()
	loadedScreen = titleScreenScene.instantiate()
	loadedScreen.connect("play", on_play_pressed)
	loadedScreen.connect("instructions", on_instructions_pressed)
	add_child(loadedScreen)

func on_instructions_exit():
	overlayScreen.queue_free()
	overlayScreen = null
