extends CharacterBody2D

#Initialize for movement
var height = 5
var width = 5

#Setting stage of turn
var stage = 0

#Change to board length for proper spacing
func _ready():
	if get_parent().name =="Board":
		height = get_parent().boardHeight
		width = get_parent().boardWidth

func _process(delta):
	turnFlow()

func turnFlow():
	match stage:
		0:
			movement()
		1:
			traps()

#//////////////Functions relating to stage 1: movement
func movement():
	squareSelection()

#Controls moving selection square
func squareSelection():
	if Input.is_action_just_pressed('move_right'):
		print('hi')

#//////////////Function for stage 2:Trap Selection
func traps():
	print('trap')
