extends CharacterBody2D

enum{
	up = -1,
	down = 1,
	left = -1,
	right = 1,
	none = 0
}

#Initialize for movement
var tileSize = 40
var boardPosition = Vector2(0,0)

var boardRef

#Setting stage of turn
var stage = 0

#Change to board length for proper spacing
func ready_player():
	if get_parent().tileSize != null:
		print('hi')
		tileSize =  get_parent().tileSize
		boardRef = get_parent()
		
	turnFlow()

func _process(delta):
	if !is_multiplayer_authority(): return OK
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
var selectorPos = boardPosition
func movement():
	if spacesLeft>0:
		selectorPos += squareMovement()
		if Input.is_action_just_pressed('select'):
			squareSelection()
		if Input.is_action_just_pressed("return") and !storedMovement.is_empty():
			goBack()
	else:
		stage+=1
		boardRef.updateLocation(boardRef.player,boardPosition)
		print(storedMovement)


#Controls moving selection square
func squareSelection():
	var change = selectorPos-boardPosition
	if change.length() == 1 and boardRef.board[selectorPos.x][selectorPos.y] == boardRef.empty:
		global_position += change*tileSize
		boardPosition = selectorPos
		$squareSelector.global_position = global_position
		selectorPos = boardPosition
		storedMovement.append(change)
		spacesLeft -= 1
		print(spacesLeft)
	else:
		print(selectorPos)

func goBack():
	global_position += -storedMovement.pop_back()*tileSize
	spacesLeft +=1

#//////////////Function for stage 2:Trap Selection
func traps():
	return

#Function for moving selection Square
func squareMovement():
	var changes = Vector2(0,0)
	if Input.is_action_just_pressed('move_right'):
		changes.x += right
	if Input.is_action_just_pressed("move_left"):
		changes.x += left
	if Input.is_action_just_pressed("move_up"):
		changes.y += up
	if Input.is_action_just_pressed("move_down"):
		changes.y += down
	$squareSelector.global_position += changes*tileSize
	return changes
