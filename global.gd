extends Node

var currentCardOnMouse : card_number = null

var pointsRequestCorrect := 15
var pointsRequestPass := 5
var pointsRequestFail := -5

var correctMessages : Array
var passMessages : Array
var strikeMessages : Array
var failMessages : Array

var cards : Array

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

