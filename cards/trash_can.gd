extends card_request_slot

# duplicate of card_request_slot script lol

signal remove_cards

func insertNumberCard(card : card_number):
	card.remove()
	$sfx.play()

func _on_button_pressed():
	$sfx.play()
	emit_signal("remove_cards")
