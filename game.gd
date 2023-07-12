extends Node2D

var cardRequestScene = load("res://cards/card_request.tscn")
var cardNumberOrigin = load("res://cards/card_origin.tscn")
var cardNumberScene = load("res://cards/card_number.tscn")
var requestCards : Array[Node] = []
var numberCards : Array[card_number] = []

var points : int = 0
var bonuses : Array[Dictionary]
var numOfNumberCards := 0
var maxNumberCards := 20
@onready var cardAreaPositions = $card_area.get_children()

signal restart_game
signal end_game

# Called when the node enters the scene tree for the first time.
func _ready():
	$game.play()
	$hud.updatePoints(points)
	spawnRequestCard()
	spawnNumberCard()
	spawnNumberCard()
	spawnNumberCard()
	spawnNumberCard()
	spawnNumberCard()
	spawnNumberCard()
	spawnNumberCard()
	spawnNumberCard()
	spawnNumberCard()
	spawnNumberCard()
	$snd_card_1.play()

func printRange(start:int, end:int):
	var string := "["
	for i in range(start, end):
		string += str(i) + ", "
	print(string + str(end) + "]")
func printRangeOdd(start:int, end:int):
	var string := "["
	for i in range(start, end):
		if i%2 == 1:
			string += str(i) + ", "
	print(string + str(end) + "]")
func printRangeEven(start:int, end:int):
	var string := "["
	for i in range(start, end):
		if i%2 == 0:
			string += str(i) + ", "
	print(string + str(end) + "]")

func printPrime(amount : int):
	var string := "["
	for i in range(amount+1):
		if isPrime(i):
			string += str(i) + ", "
	print(string + "]")
func isPrime(num : int):
	for i in range(2, num):
		if num%i == 0:
			return false
	return true

func _process(delta):
#	sortRequestCardsPriority()
	numOfNumberCards = $card_holder_anchor/deck.get_children().size()

func sortRequestCardsPriority():
	requestCards = $request_cards.get_children()
	requestCards.sort_custom(sort_ascending)
	
	var priorityCounter := 0
	for card in requestCards:
		card.process_priority = priorityCounter
		priorityCounter -= 1
	
func sort_ascending(a, b):
	if a.position.y < b.position.y:
		return true
	return false


func spawnRequestCard():
	var newCard = cardRequestScene.instantiate()
	
	for i in range(cardAreaPositions.size()):
		randomize()
		newCard.myMarker = cardAreaPositions[randi_range(0, cardAreaPositions.size()-1)]
		if not newCard.myMarker.cardOnPosition:
			break
	if newCard.myMarker.cardOnPosition:
		return
	newCard.myMarker.cardOnPosition = true
	
	newCard.connect("removing", on_card_removed)
	newCard.connect("shake", shake)
	$request_cards.add_child(newCard)
	
	randomize()
	var pickedCard = global.cards.pick_random()
	if "targetVal" in pickedCard:
		newCard.requirementVal = pickedCard.targetVal
	else:
		randomize()
		newCard.requirementVal = pickedCard.rangeVals.pick_random()
	
	newCard.slotAmount = int(pickedCard.slots)
	newCard.acceptableText = pickedCard.rangeText
	for val in pickedCard.rangeVals:
		newCard.acceptableList.append(int(val))
	newCard.setup()
	
	var newCardNewPosition : Vector2 = newCard.myMarker.global_position - newCard.pivot_offset
	newCard.global_position = Vector2(960, -200)
	var TW : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	TW.tween_property(newCard, "global_position", newCardNewPosition, 3.0)
	newCard.spin()

func spawnNumberCard():
	if numOfNumberCards >= maxNumberCards:
		return
	
	var newCardOrigin = cardNumberOrigin.instantiate()
	var newCard = cardNumberScene.instantiate()
	$card_holder_anchor/deck.add_child(newCardOrigin)
	$number_cards.add_child(newCard)
	numberCards.append(newCard)
	newCard.connect("move_to_slot", on_card_move_to_slot)
	newCard.connect("remove_from_slot", on_card_remove_from_slot)
	newCardOrigin.connect("move_to_end", on_card_origin_move_to_end)
	
	randomize()
	newCard.origin = newCardOrigin
	newCard.number = randi_range(0, 9)
	newCard.updateNumber()
	newCard.position = Vector2(2000, newCardOrigin.global_position.y)

func shake():
	$AnimationPlayer.play("shake")

func on_card_removed(data : Dictionary):
	match data.reason:
		"correct":
			points += global.pointsRequestCorrect * data.multiplier
		"pass":
			points += global.pointsRequestPass * (data.multiplier / 2)
		"fail":
			points += global.pointsRequestFail
	$hud.updatePoints(points)

func on_card_move_to_slot(numberCard : card_number, requestCardSlot : card_request_slot):
	numberCard.get_parent().remove_child(numberCard)
	requestCardSlot.add_child(numberCard)
	numberCard.position = Vector2.ZERO
	numberCard.newPosition = numberCard.position
func on_card_remove_from_slot(numberCard : card_number):
	numberCard.get_parent().remove_child(numberCard)
	$number_cards.add_child(numberCard)
	numberCard.position = numberCard.global_position
	numberCard.newPosition = numberCard.position

func on_card_origin_move_to_end(origin : Control):
	$card_holder_anchor/deck.move_child(origin, -1)

func _on_card_spawner_timeout():
	spawnRequestCard()
func _on_card_number_spawner_timeout():
	spawnNumberCard()
	spawnNumberCard()
	spawnNumberCard()
	spawnNumberCard()
	spawnNumberCard()
	$snd_card_1.play()

func _on_pause_menu_exit():
	emit_signal("end_game")

func _on_round_summary_menu_restart():
	emit_signal("restart_game")

func _on_round_progress_bar_timer_finished():
	$round_summary_menu.visible = true
	$round_summary_menu.displayPoints(points)
	get_tree().paused = true
