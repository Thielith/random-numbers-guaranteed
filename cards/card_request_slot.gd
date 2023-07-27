extends Control
class_name card_request_slot

var mouseOverSlot := false
var cardInSlot : card_number = null
var disabled := false

func insertNumberCard(card : card_number):
	cardInSlot = card
	card.connect("picked_up", on_number_card_picked_up)
	$snd_card_slot.play()

func removeCardInSlot():
	if cardInSlot != null:
		cardInSlot.remove()

func disable():
	disabled = true
	if cardInSlot != null: cardInSlot.disable()
	_on_area_2d_mouse_exited() # easier to reuse the function imo

func on_number_card_picked_up():
	cardInSlot.disconnect("picked_up", on_number_card_picked_up)
	cardInSlot.emit_signal("return_to_parent", cardInSlot)
	cardInSlot.emit_signal("move_origin_to_end", cardInSlot.origin)
	cardInSlot.rotation = 0
	cardInSlot = null

func _on_area_2d_mouse_entered():
	mouseOverSlot = true
	global.currentSlotUnderMouse = self
func _on_area_2d_mouse_exited():
	mouseOverSlot = false
	if global.currentSlotUnderMouse == self:
		global.currentSlotUnderMouse = null
