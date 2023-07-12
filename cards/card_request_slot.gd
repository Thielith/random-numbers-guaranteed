extends Control
class_name card_request_slot

var mouseOverSlot := false
var cardOverSlot : card_number = null
var slotFilled := false
var canTakeCard := true

func _process(delta):
	if cardOverSlot != null and not get_children().has(cardOverSlot):
		emptySlot()

func _input(event):
	if Input.is_action_just_released("select_card") and (
		mouseOverSlot and global.currentCardOnMouse != null and not slotFilled and canTakeCard
	):
		cardOverSlot = global.currentCardOnMouse
		lockCardToSlot()
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
	slotFilled = true
	canTakeCard = false
	cardOverSlot.mySlot = self
	cardOverSlot.locked = true
	cardOverSlot.followMouse = false
	cardOverSlot.origin.visible = false
	cardOverSlot.emit_signal("move_to_slot", cardOverSlot, self)
#	cardOverSlot.global_position = global_position + pivot_offset
#	cardOverSlot.rotation_degrees = rad_to_deg(get_global_transform().get_rotation())
	
	$snd_card_slot.play()

func emptySlot():
	if cardOverSlot != null:
		cardOverSlot.mySlot = null
		cardOverSlot.locked = false
		cardOverSlot = null
	slotFilled = false
	canTakeCard = true

func removeCard():
	if cardOverSlot != null:
		cardOverSlot.set_process_mode(PROCESS_MODE_INHERIT)
		cardOverSlot.set_process(false)
		await cardOverSlot.removeOrigin()

func disableSelf():
	canTakeCard = false
	if cardOverSlot != null:
		cardOverSlot.set_process_mode(PROCESS_MODE_DISABLED)
	set_process_mode(PROCESS_MODE_DISABLED)

func _on_area_2d_mouse_entered():
	mouseOverSlot = true
func _on_area_2d_mouse_exited():
	mouseOverSlot = false
	if (global.currentCardOnMouse != null and global.currentCardOnMouse == cardOverSlot
		and not global.currentCardOnMouse.locked
	):
		emptySlot()
