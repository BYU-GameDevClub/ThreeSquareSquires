extends CharacterBody2D

enum{
	up,
	down,
	left,
	right,
	none
}

#Initialize for movement
var tileSize = 4

#Setting stage of turn
var stage = 0

#Change to board length for proper spacing
func _ready():
	if get_parent().name =="Board":
		if get_parent().tileSize != null:
			tileSize =  get_parent().tileSize
	turnFlow()

func _process(delta):
	turnFlow()

func turnFlow():
	match stage:
		0:
			movement()
		1:
			traps()

#//////////////Functions relating to stage 1: movement
var spacesLeft = 4
var storedMovement = []
func movement():
	if spacesLeft>0:
		var direction = checkInputDirection()
		squareSelection(direction)
		if direction != none:
			temp(direction)
		if Input.is_action_just_pressed("return") and !storedMovement.is_empty():
			goBack()
	else:
		stage+=1
		print(storedMovement)


#Controls moving selection square
func squareSelection(direction):
	match direction:
		right:
			global_position.x += tileSize
		left:
			global_position.x -= tileSize
		up:
			global_position.y -= tileSize
		down:
			global_position.y += tileSize
		none:
			return

func temp(direction):
	storedMovement.append(direction)
	spacesLeft -=1

func goBack():
	var direction = none
	match storedMovement.pop_back():
		up:
			direction = down
		left:
			direction = right
		right:
			direction = left
		down:
			direction = up
	squareSelection(direction)
	spacesLeft+=1

func checkInputDirection():
	var direction = none
	if Input.is_action_just_pressed('move_right'):
		direction = right
	if Input.is_action_just_pressed("move_left"):
		direction = left
	if Input.is_action_just_pressed("move_up"):
		direction = up
	if Input.is_action_just_pressed("move_down"):
		direction = down
	return direction

#//////////////Function for stage 2:Trap Selection
func traps():
	return
