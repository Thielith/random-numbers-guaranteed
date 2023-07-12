extends Node2D

@onready var pages := $pages.get_children()
var pageNumber := 0

signal exit

# Called when the node enters the scene tree for the first time.
func _ready():
	changePage(0)

func changePage(pageNum : int):
	if pageNum < 0 or pageNum >= pages.size():
		return
	
	pages[pageNumber].visible = false
	pages[pageNum].visible = true
	pageNumber = pageNum

func _on_left_pressed():
	changePage(pageNumber-1)

func _on_right_pressed():
	changePage(pageNumber+1)

func _on_exit_pressed():
	emit_signal("exit")
