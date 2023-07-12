extends Panel

var currentColor : Color
var panelRed = load("res://cards/theme_background_red.tres")
var panelYellow = load("res://cards/theme_background_yellow.tres")
var panelGreen = load("res://cards/theme_background_green.tres")

func updateColor():
	match currentColor:
		Color.RED:
			add_theme_stylebox_override("panel", panelRed)
		Color.YELLOW:
			add_theme_stylebox_override("panel", panelYellow)
		Color.GREEN:
			add_theme_stylebox_override("panel", panelGreen)
