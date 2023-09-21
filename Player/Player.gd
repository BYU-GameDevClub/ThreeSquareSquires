extends CharacterBody2D

#Initialize for movement
var height = 5
var width = 5

#Change to board length for proper spacing
func _ready():
	if get_parent().name =="Board":
		height = get_parent().boardHeight
		width = get_parent().boardWidth
