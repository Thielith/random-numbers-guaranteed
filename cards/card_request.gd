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

var maxStrikesAllowed := 3
var strikes : int
var satisfied := false
var myMarker : Marker2D = null

var snd_correct = load("res://sounds/snd_ding.mp3")
var snd_pass = load("res://sounds/snd_ding_dull.mp3")
var snd_wrong = load("res://sounds/snd_wrong.mp3")
var snd_fail = load("res://sounds/snd_fail.mp3")

signal shake
signal removing(marker:Marker2D, reason:String, multipliier:float)
var removeReason : String

func setup():
	generateSlots()
	$card/VBoxContainer/header.text = str(requirementVal)
	$card/VBoxContainer/footer.text = acceptableText

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
		if slot.cardInSlot == null:
			return true
	return false

func displayPopup(color : String):
	$popup_panel.updateColor(color)
	$popup_panel/Label.text = popupText
	await $popup_panel.display()

func processNumberInput():
	# calculate inputted number. starting from 1's place due to variable slot amount
	var value : int = 0
	var tensPlace = 1
	for i in range(slots.size()): # 421 => 1 + 20 + 400
		var index : int = slots.size()-1 - i
		value += slots[index].cardInSlot.number * tensPlace
		tensPlace *= 10
	
	randomize()
	# check if value is invalid. otherwise, its acceptable
	if not acceptableList.has(value):
		popupText = global.strikeMessages.pick_random()  # here instead of the function
		addStrike()                                      # since adding a strike can happen
		return                                           # elsewhere  48
	satisfied = true
	
	# check how acceptable the value is
	if value == requirementVal:
		removeReason = "correct"
		popupText = global.correctMessages.pick_random()
		playSoundResult(snd_correct)
		removeCard("green")
	elif acceptableList.has(value):
		removeReason = "pass"
		popupText = global.passMessages.pick_random()
		playSoundResult(snd_pass)
		removeCard("yellow")

func addStrike():
	strikes += 1
	$strike_display.text += "❌"
	if strikes >= maxStrikesAllowed:
		strikeOut()
		return
	
	playSoundResult(snd_wrong)
	displayPopup("red")

func strikeOut():
	randomize()
	popupText = global.failMessages.pick_random()
	removeReason = "fail"
	playSoundResult(snd_fail)
	removeCard("red")

func spin():  # really makes it FEEL like the card is being thrown
	randomize()
	var endRotation = randi_range(-8, 8)
	var extraRotation = randi_range(-45, 45)
	rotation_degrees = extraRotation
	
	var TW : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	TW.tween_property(self, "rotation_degrees", endRotation, 3.0)

func removeCard(color : String):
	# make the card look like its disabled
	$Button.disabled = true
	$popup_panel/ProgressBar.stop()
	$Button/AnimationPlayer.play("hide")
	
	# disable slots
	for slot in slots:
		slot.disable()
	await displayPopup(color)
	
	# temp enable processing on the slots so they can remove their number cards
	for slot in slots:
		slot.set_process_mode(PROCESS_MODE_INHERIT)
		slot.removeCardInSlot()
	
	# fancy remove animation
	$AnimationPlayer.play("remove")
	await $AnimationPlayer.animation_finished
	
	# send point data to game handler and die
	var multiplier : float = (0.75 + 0.25*slotAmount) + $popup_panel/ProgressBar.lifeTimePercentage
	emit_signal("removing", myMarker, removeReason, multiplier)
	myMarker.cardOnPosition = false
	queue_free()

func tweenColor():
	var TW = create_tween().set_ease(Tween.EASE_OUT)
	TW.tween_property($remove_anim_stuff/return, "theme_override_colors/font_color",
						$popup_panel.color, 0.25)

func playSoundResult(sound : AudioStream):
	$sfx_result.stream = sound
	$sfx_result.play()

func _on_button_pressed():
	$Button/snd_click.play()
	
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
			playSoundResult(snd_wrong)
			removeCard("red")
		else:
			strikes = 100
			processNumberInput()
