extends card_request_slot

# duplicate of card_request_slot script lol

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if cardOverSlot != null and cardOverSlot.followMouse and slotFilled:
#		slotFilled = false

#func _input(event):
#	if Input.is_action_just_pressed("select_card"):
#		if mouseOverSlot and cardOverSlot != null and (
#			global.currentCardOnMouse == cardOverSlot or global.currentCardOnMouse == null
#		):
#			cardOverSlot.locked = false
#			cardOverSlot.origin.visible = true
#	elif Input.is_action_just_released("select_card"):
#		if mouseOverSlot and cardOverSlot != null and not slotFilled:
#			lockCardToSlot()

func lockCardToSlot():
	super.lockCardToSlot()
	removeCard()

func removeCard():
	super.removeCard()
	mouseOverSlot = false
	cardOverSlot = null
	slotFilled = false
	canTakeCard = true

#func _on_area_2d_mouse_entered():
#	mouseOverSlot = true
#func _on_area_2d_mouse_exited():
#	mouseOverSlot = false
#
#func _on_area_2d_area_entered(area):
#	if not slotFilled:
#		cardOverSlot = area.get_parent()
#func _on_area_2d_area_exited(area):
#	if area.get_parent() == cardOverSlot:
#		slotFilled = false
#		cardOverSlot = null
