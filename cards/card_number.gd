extends Control
class_name card_number

@onready var cardSize : Vector2 = $card.size
static var priority : int = 0
var number : int

var mouseOnCard := false
var followMouse := false
var origin : Control
var currentMoveTween : Tween = null
var locked := false
var disabled := false
var removing := false
@onready var mainParent : Node2D = get_parent()

signal picked_up
signal return_to_parent(card : card_number)
signal move_origin_to_end(node : Control)

func _ready():
	updatePriority()

func updateNumber():
	$card/number.text = str(number)
	name = "num_" + str(number)
	origin.name = "origin_" + name
func updatePriority():
	process_priority = priority
	priority -= 1

func _process(delta):
	# picked up by player detection
	if (not followMouse and mouseOnCard and not disabled and
		Input.is_action_pressed("select_card") and
		global.currentCardHeldByMouse == null
	):
		global.currentCardHeldByMouse = self
		followMouse = true
		locked = false
		origin.visible = true
		rotation = 0
		$snd_pickup.play()
		emit_signal("picked_up")
	elif (Input.is_action_just_released("select_card") and
		global.currentCardHeldByMouse == self
	):
		global.currentCardHeldByMouse = null
		followMouse = false
		
		if (global.currentSlotUnderMouse != null and 
			global.currentSlotUnderMouse.cardInSlot == null and 
			not global.currentSlotUnderMouse.disabled
		):
			global.currentSlotUnderMouse.insertNumberCard(self)
			lockToSlot(global.currentSlotUnderMouse)
	
	if followMouse and global.currentCardHeldByMouse == self:
		moveToMouse()
	elif not locked and global_position != origin.global_position:
		if get_parent() != mainParent:
			emit_signal("return_to_parent", self)
			origin.visible = true
		moveToOrigin()

func moveToMouse():
	# tweens tweening the position will disrupt moving to mouse, so kill them
	if currentMoveTween != null:
		currentMoveTween.kill()
		currentMoveTween = null
	
	var newPosition : Vector2 = get_global_mouse_position() - Vector2(0, cardSize.y/2)
	global_position = lerp(global_position, newPosition, 0.1)

func moveToOrigin():
	origin.goingToEnd = false
	if currentMoveTween == null:  # don't want multiple tweens tweening
		currentMoveTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		currentMoveTween.tween_property(self, "global_position",
										origin.global_position, 0.5)
		await currentMoveTween.finished
		currentMoveTween = null

func lockToSlot(slot : card_request_slot):
	locked = true
	get_parent().remove_child(self)  # so the number card moves with the slot
	slot.add_child(self)             # if put in while it's moving
	position = Vector2.ZERO          # position is local to slot now
	
	origin.visible = false
	emit_signal("move_origin_to_end", origin)

func disable():
	disabled = true
	$slot_snap_area/CollisionShape2D.disabled = true
	$click_area/CollisionShape2D.disabled = true
	_on_area_2d_mouse_exited()

func remove():
	if removing: return
	removing = true
	
	disable()
	origin.queue_free() # new number cards get new origins, so remove old ones
	var TW = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	TW.tween_property(self, "modulate:a", 0, 0.5)
	await TW.finished

	queue_free()

func _on_area_2d_mouse_entered():
	mouseOnCard = true
func _on_area_2d_mouse_exited():
	mouseOnCard = false
