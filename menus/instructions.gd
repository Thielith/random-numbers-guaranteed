extends Node2D

@onready var pages := $pages.get_children()
var pageNumber := 0

var gameSizeX = ProjectSettings.get_setting("display/window/size/viewport_width")
var currentTween : Tween = null

signal exit

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(pages.size()):
		pages[i].visible = true
		pages[i].position.x = gameSizeX * i
	changePage(0)

func changePage(pageNumberNew : int):
	# makes sure that user doesnt go out of bounds
	if pageNumberNew < 0 or pageNumberNew >= pages.size():
		return
	
	var TW = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	TW.tween_property($pages, "position:x", -gameSizeX * pageNumberNew, 0.3) 
	currentTween = TW
	await TW.finished
	
	$pages.position.x = -gameSizeX * pageNumberNew
	currentTween = null
	pageNumber = pageNumberNew

func _on_left_button_pressed():
	# putting if block instead of changePage cause it wont work there
	if currentTween != null:
		currentTween.custom_step(1000000000)
	changePage(pageNumber-1)
	
func _on_right_button_pressed():
	# putting if block instead of changePage cause it wont work there
	if currentTween != null:
		currentTween.custom_step(1000000000)
	changePage(pageNumber+1)
	
func _on_exit_button_pressed():
	emit_signal("exit")
