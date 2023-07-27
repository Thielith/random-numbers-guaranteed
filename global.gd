extends Node

# in hex because its easier to copy-paste it elsewhere if needed
var color = {
	"RED": "ff6459",
	"YELLOW": "c2a853",
	"GREEN": "6bff66"
}

var currentCardHeldByMouse : card_number = null
var currentSlotUnderMouse : card_request_slot = null

var pointsRequestCorrect := 15
var pointsRequestPass := 5
var pointsRequestFail := -5

var correctMessages : Array
var passMessages : Array
var strikeMessages : Array
var failMessages : Array

var cards : Array
var difficulties : Array
var chosenDifficulty : Dictionary
var backgroundMusic : Dictionary = {
	"Classic": "res://music/classic.mp3",
	"Easy": "res://music/easy.mp3",
	"Normal": "res://music/normal.mp3",
	"Hard": "res://music/hard.mp3"
}

func _ready():
	var fileString = FileAccess.get_file_as_string("res://data/cards.json")
	var fileDict = JSON.parse_string(fileString)
	cards = fileDict["cards"] as Array[Dictionary]
	
	fileString = FileAccess.get_file_as_string("res://data/popup_messages.json")
	fileDict = JSON.parse_string(fileString)
	correctMessages = fileDict["messages_correct"] as Array[String]
	passMessages = fileDict["messages_pass"] as Array[String]
	strikeMessages = fileDict["messages_strike"] as Array[String]
	failMessages = fileDict["messages_fail"] as Array[String]
	
	fileString = FileAccess.get_file_as_string("res://data/difficulties.json")
	fileDict = JSON.parse_string(fileString)
	difficulties = fileDict as Array[Dictionary]
	

