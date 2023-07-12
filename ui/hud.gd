extends Control

var currentPointCount : int = -1

func updatePoints(number : int):
	if currentPointCount == number:
		return
	
	currentPointCount = currentPointCount+1 if currentPointCount < number else currentPointCount-1
	$point_label/number.text = str(currentPointCount)
	
	$point_label/point_increment_timer.start()
	await $point_label/point_increment_timer.timeout
	updatePoints(number)
