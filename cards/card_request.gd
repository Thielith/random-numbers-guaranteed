extends Control
class_name card_request

var slotScene : PackedScene = load("res://cards/card_request_slot.tscn")
var slotAmount : int
@onready var slotContainer := $card/VBoxContainer/HBoxContainer
var slots : Array[card_request_slot]
var allSlotsFilled := false

var requirementVal : int
var acceptableText : String
var acceptableList : Array[int]
var popupText : String
var popupColor : Color

var maxStrikesAllowed := 2
var strikes : int
var satisfied := false
var myMarker : Marker2D = null

signal shake
signal removing
var removeReason : String

func setup():
	generateSlots()
	$card/VBoxContainer/header.text = str(requirementVal)
	$card/VBoxContainer/footer.text = acceptableText
	$snd_card_swipe.play()

func checkIfSlotsAreFilled():
	for slot in slots:
		if not slot.slotFilled:
			return false
	return true

func generateSlots():
	for i in range(slotAmount):
		var newSlot = slotScene.instantiate()
		slotContainer.add_child(newSlot)
		slots.append(newSlot)

func areSlotsEmpty():
	for slot in slots:
		if slot.cardOverSlot == null:
			return true
	return false

func displayPopup(color : Color):
	$popup_panel.currentColor = color
	$popup_panel.updateColor()
	$popup_panel/Label.text = popupText
	
	$popupTimer.stop()
	$popup_panel/AnimationPlayer.play("showPopup")
	await $popup_panel/AnimationPlayer.animation_finished
	$popupTimer.start()
	await $popupTimer.timeout
	$popup_panel/AnimationPlayer.play("hidePopup")
	await $popup_panel/AnimationPlayer.animation_finished

func processNumberInput():
	var value : int = 0
	var tensPlace = 1
	
	for i in range(slots.size()):
		var index : int = slots.size()-1 - i
		value += slots[index].cardOverSlot.number * tensPlace
		tensPlace *= 10
	
	if value == requirementVal:
		randomize()
		popupText = global.correctMessages.pick_random()
		$Button/AnimationPlayer.play("hide")
		satisfied = true
		$popup_panel/ProgressBar.stop()
		removeReason = "correct"
		$snd_ding.play()
		removeCard(Color.GREEN)
	elif acceptableList.has(value):
		randomize()
		popupText = global.passMessages.pick_random()
		$Button/AnimationPlayer.play("hide")
		satisfied = true
		$popup_panel/ProgressBar.stop()
		removeReason = "pass"
		removeCard(Color.YELLOW)
	else:
		randomize()
		popupText = global.strikeMessages.pick_random()
		addStrike()

func addStrike():
	if strikes >= maxStrikesAllowed:
		strikeOut()
		return
	
	strikes += 1
	$strike_display.text += "❌"
#	emit_signal("shake")
	displayPopup(Color.RED)

func strikeOut():
	$strike_display.text += "❌"
	randomize()
	popupText = global.failMessages.pick_random()
	removeReason = "fail"
	removeCard(Color.RED)

func spin():
	randomize()
	var endRotation = randi_range(-8, 8)
	var extraRotation = randi_range(-45, 45)
	rotation_degrees = extraRotation
	
	var TW : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	TW.tween_property(self, "rotation_degrees", endRotation, 3.0)

func removeCard(color : Color):
	$Button.disabled = true
	for slot in slots:
		slot.disableSelf()
	await displayPopup(color)
	
	for slot in slots:
		slot.set_process_mode(PROCESS_MODE_INHERIT)
		slot.removeCard()
	
	$AnimationPlayer.play("remove")
	await $AnimationPlayer.animation_finished
	
	myMarker.cardOnPosition = false
	queue_free()

func tweenColor():
	var TW = create_tween().set_ease(Tween.EASE_OUT)
	TW.tween_property($remove_anim_stuff/return, "theme_override_colors/font_color",
	$popup_panel.currentColor, 0.25)

func emitRemoveSignal():
	var multiplier : float = (0.75 + 0.25*slotAmount) + $popup_panel/ProgressBar.lifeTimePercentage
	emit_signal("removing", {"reason": removeReason, "multiplier": multiplier})

func _on_button_pressed():
	$Button/snd_button.play()
	if not areSlotsEmpty():
		processNumberInput()
	else:
		popupText = "All slots not filled!"
		addStrike()

func _on_timer_timeout():
	if not satisfied:
		if areSlotsEmpty():
			popupText = "Time's up!"
			removeReason = "fail"
			removeCard(Color.RED)
		else:
			strikes = 100
			processNumberInput()
