extends Panel

var color : Color

func updateColor(newColor : String):
	# can't figure out how to set theme background color with code
	# so just use presets
	match newColor.to_lower():
		"red":
			color = global.color.RED
			set_theme_type_variation("PanelRed")
		"yellow":
			color = global.color.YELLOW
			set_theme_type_variation("PanelYellow")
		"green":
			color = global.color.GREEN
			set_theme_type_variation("PanelGreen")

func display():
	$Timer.stop()
	$AnimationPlayer.play("showPopup")
	await $AnimationPlayer.animation_finished
	$Timer.start()
	await $Timer.timeout
	$AnimationPlayer.play("hidePopup")
	await $AnimationPlayer.animation_finished
