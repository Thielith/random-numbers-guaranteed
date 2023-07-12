extends Control
class_name card_number

var origin : Control
var moving := false
var newPosition : Vector2
var currentTween : Tween = null

signal move_to_slot
signal remove_from_slot

@onready var hitbox = $click_area
static var priority := 0
var mouseOnCard := false
var followMouse := false
var mySlot : card_request_slot = null
var locked := false

@export var number : int

func _ready():
	updateNumber()
	process_priority = priority
	priority -= 1

func updateNumber():
	$border/number.text = str(number)
	name = "num_" + str(number)

func _process(delta):
	if mouseOnCard and Input.is_action_pressed("select_card") and global.currentCardOnMouse == null:
		if locked:
			origin.move()
			emit_signal("remove_from_slot", self)
		
		followMouse = true
		locked = false
		global.currentCardOnMouse = self
		origin.visible = true
		$snd_card_pickup.play()
		newPosition = get_global_mouse_position() - Vector2(0, $border.size.y/2)
	elif Input.is_action_just_released("select_card"):
		followMouse = false
		global.currentCardOnMouse = null
		
#		followMouse = true
#		if followMouse and global.currentCardOnMouse == null:
#			$snd_card_pickup.play()
#			global.currentCardOnMouse = self
	
	if followMouse:
		moveToMouse()
	elif not moving and not locked and global_position != origin.global_position + origin.pivot_offset:
		newPosition = origin.global_position + origin.pivot_offset
		if currentTween != null:
			currentTween.kill()
		moveToLocationTween()
#		if global.currentCardOnMouse == self:
#			global.currentCardOnMouse = null

func moveToMouse():
	rotation_degrees = 0
	if currentTween != null:
		currentTween.kill()
		moving = false
	newPosition = get_global_mouse_position() - Vector2(0, $border.size.y/2)
	moveToLocationLerp()

func moveToLocationLerp():
	if $moveTimer.is_stopped(): $moveTimer.start()
	var timerProgression = 1 - $moveTimer.time_left / $moveTimer.wait_time

	global_position = lerp(global_position, newPosition, timerProgression)

func moveToLocationTween():
	moving = true
	
	var TW = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	currentTween = TW
	TW.tween_property(self, "position", newPosition, 0.5)
	await TW.finished
	
	currentTween = null
	moving = false

func removeOrigin():
	origin.queue_free()
	var TW = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	TW.tween_property(self, "modulate:a", 0, 0.5)
	await TW.finished
	
	queue_free()

func _on_area_2d_mouse_entered():
	mouseOnCard = true
func _on_area_2d_mouse_exited():
	mouseOnCard = false
