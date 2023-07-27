extends Node2D

var cardRequestScene = load("res://cards/card_request.tscn")
var cardNumberOrigin = load("res://cards/card_origin.tscn")
var cardNumberScene = load("res://cards/card_number.tscn")
#var requestCards : Array[Node] = []
#var numberCards : Array[card_number] = []

var points : int = 0
#var bonuses : Array[Dictionary]
var numOfRequestCards := 0
var numOfNumberCards := 0
var maxNumberCards := 20
@onready var cardAreaPositions = $card_area.get_children()

signal restart_game
signal end_game

func _ready():
	$hud.updatePoints(points)
	difficultySetup()
	$bg_music.play()

func _process(delta):
	numOfNumberCards = $card_holder_anchor/deck.get_children().size()
	numOfRequestCards = $request_cards.get_children().size()

func difficultySetup():
	# setup settings based on difficulty
	for i in range(global.chosenDifficulty.requestSpawnStart):
		spawnRequestCard()
	for i in range(global.chosenDifficulty.numberSpawnStart):
		spawnNumberCard()
	
	$round_progress_bar/Timer.start(global.chosenDifficulty.roundTime)
	$card_request_spawner.start(global.chosenDifficulty.requestSpawnFrequency)
	$card_number_spawner.start(global.chosenDifficulty.numberSpawnFrequency)
	$bg_music.stream = load(global.backgroundMusic[global.chosenDifficulty.name])

func spawnRequestCard():
	# makes sure theres room to spawn a card to
	if numOfRequestCards >= cardAreaPositions.size():
		return
	
	# create request card
	var newCard = cardRequestScene.instantiate()
	newCard.connect("removing", on_request_removed)
	newCard.connect("shake", shake)
	$request_cards.add_child(newCard)
	newCard.global_position = Vector2(960, -200)  # hides it for later
	
	# choose what request it will have
	randomize()
	var pickedCard = global.cards.pick_random()
	# functionality for requests to have a hardcoded value
	if "targetVal" in pickedCard:
		newCard.requirementVal = pickedCard.targetVal
	else:
		randomize()
		newCard.requirementVal = pickedCard.rangeVals.pick_random()
	newCard.slotAmount = int(pickedCard.slots)
	newCard.acceptableText = pickedCard.rangeText
	if pickedCard.rangeVals != null:
		for val in pickedCard.rangeVals:
			newCard.acceptableList.append(int(val))
	newCard.setup()
	
	# choose which position in the play area to slide to
	randomize()
	var choice = cardAreaPositions.pick_random()
	cardAreaPositions.erase(choice)
	newCard.myMarker = choice
	choice.cardOnPosition = true
	
	# slide card to play area position
	var newCardNewPosition : Vector2 = newCard.myMarker.global_position - newCard.pivot_offset
	var TW : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	TW.tween_property(newCard, "global_position", newCardNewPosition, 3.0)
	newCard.spin()

func spawnNumberCard():
	# dont spawn if hand is full
	if numOfNumberCards >= maxNumberCards:
		return
	
	# create number card and deck origin
	var newCardOrigin = cardNumberOrigin.instantiate()
	var newCard = cardNumberScene.instantiate()
	$card_holder_anchor/deck.add_child(newCardOrigin)
	$number_cards.add_child(newCard)
#	numberCards.append(newCard)
	newCard.connect("return_to_parent", on_number_card_return_to_parent)
	newCard.connect("move_origin_to_end", on_number_card_move_origin_to_end)
	
	# set data and move to appropriate position
	randomize()
	newCard.position = Vector2(2000, newCardOrigin.global_position.y)
	newCard.origin = newCardOrigin
	newCard.number = randi_range(0, 9)
	newCard.updateNumber()

func shake():  # keep in case you want it for later
	$AnimationPlayer.play("shake")

func on_request_removed(requestMarker:Marker2D, removeReason:String, multipliier:float):
	# add back position so cards can be slid there again
	cardAreaPositions.append(requestMarker)
	
	# give points
	match removeReason:
		"correct":
			points += ceil(global.pointsRequestCorrect * multipliier)
		"pass":
			points += ceil(global.pointsRequestPass * (multipliier / 2))
		"fail":
			points += global.pointsRequestFail
	$hud.updatePoints(points)

# since number card gets parent'd to slots, we have to put them
# back in the collection node when needed
func on_number_card_return_to_parent(numberCard : card_number):
	var oldGlobalPosition = numberCard.global_position
	numberCard.get_parent().remove_child(numberCard)
	$number_cards.add_child(numberCard)
	numberCard.global_position = oldGlobalPosition

# putting number cards back into the collection node moves them to
# the front visibly, so they must go to the right-most side of the deck.
# using seperate origin node so cards can overlap
func on_number_card_move_origin_to_end(origin : Control):
	origin.goingToEnd = true
	$card_holder_anchor/deck.move_child(origin, -1)

func _on_request_spawner_timeout():
	# dont spawn more if you cant spawn more
	if numOfRequestCards > cardAreaPositions.size():
		return
	
	$card_request_spawner/snd_spawn_request.play()
	for i in range(global.chosenDifficulty.requestSpawnAmount):
		spawnRequestCard()
func _on_number_spawner_timeout():
	# dont spawn more if you cant spawn more
	if numOfNumberCards >= maxNumberCards:
		return
	
	$card_number_spawner/snd_spawn_number.play()
	var backNumber : card_number = $number_cards.get_children().back()
	for i in range(global.chosenDifficulty.numberSpawnAmount):
		spawnNumberCard()
	
	if backNumber != null and backNumber.origin.goingToEnd:
		backNumber.origin.goingToEnd = false
		on_number_card_move_origin_to_end(backNumber.origin)
		on_number_card_return_to_parent(backNumber)
		backNumber.updatePriority()

func _on_pause_menu_exit():
	$bg_music.stop()
	emit_signal("end_game")
func _on_round_summary_menu_restart():
	emit_signal("restart_game")

func _on_round_progress_bar_timer_finished():
	$round_summary_menu.visible = true
	$round_summary_menu.displayPoints(points)
	get_tree().paused = true

func _on_trash_can_remove_cards():
	var cardsToRemove : Array = $number_cards.get_children()
	
	for i in range(ceil(cardsToRemove.size() / 2.0)):
		randomize()
		var cardRemoved : card_number = cardsToRemove.pick_random()
		cardRemoved.disable()
		cardRemoved.locked = true
		cardRemoved.remove()
		cardsToRemove.erase(self)
