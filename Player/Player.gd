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
var boardPosition = Vector2(1,1)

var boardRef

#Setting stage of turn
var stage = 0

#Change to board length for proper spacing
func ready_player():
	boardRef = get_parent()
	if get_parent().tileSize != null:
		tileSize =  boardRef.tileSize
		print("Starting Position: ",boardRef.BtoW(Vector2(1,1)))
		global_position=(boardRef.BtoW(Vector2(1,1)))
	
	turnFlow()

func _process(delta):
	if !is_multiplayer_authority(): return OK
	turnFlow()
	return OK

func turnFlow():
	match stage:
		0:
			movement()
		1:
			traps()
		2:
			go()

#//////////////Functions relating to stage 1: movement
var spacesLeft = 3
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
		print("Moves performed: ",storedMovement)

#Controls the actually selection of a movement space
func squareSelection():
	var change = selectorPos-boardPosition
	if change.length() <= spacesLeft and boardRef.board[selectorPos.x][selectorPos.y] != boardRef.Tiles.wall:
		boardPosition = selectorPos
		$squareSelector.global_position = boardRef.BtoW(boardPosition)
		storedMovement.append(change)
		spacesLeft -= ceil(change.length())
		print("Movement Left: ",spacesLeft)
	else:
		print("Something prevents movement at: ",selectorPos)

func goBack():
	global_position += -storedMovement.pop_back()*tileSize
	spacesLeft +=1



#//////////////Function for stage 2:Trap Selection
var currentTrap = 3
var trapsLeft = 3
func traps():
	if trapsLeft > 0:
		selectorPos += squareMovement()
		if Input.is_action_just_pressed("select"):
			placeTrap()
			print("Traps Left: ",trapsLeft)
	else:
		stage += 1
		print("Traps Placed: ", boardRef.Tiles.keys()[currentTrap])
	return

func placeTrap():
	boardRef.updateLocation(currentTrap,selectorPos)
	trapsLeft -= 1


#///////////////Function for moving selection Square
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
	var boardLeft = Vector2(boardRef.BtoW(Vector2(0,0)))
	var boardRight = Vector2(boardRef.BtoW(Vector2(boardRef.boardWidth-1,boardRef.boardHeight-1)))
	
	if $squareSelector.global_position.x == boardLeft.x and changes.x == left:
		return Vector2(0,0)
	if $squareSelector.global_position.x == boardRight.x and changes.x == right:
		return Vector2(0,0)
	if $squareSelector.global_position.y == boardLeft.y and changes.y == up:
		return Vector2(0,0)
	if $squareSelector.global_position.y == boardRight.y and changes.y == down:
		return Vector2(0,0)
	
	$squareSelector.global_position += changes*tileSize
	return changes


#//////////////PLay through the game
var completed:bool = false
func go():
	if completed == true:
		reset()
		completed = false
		print("New Turn")
	else:
		if boardRef.checkTile(boardPosition) == boardRef.Tiles.trap:
			print("Trapped")
		endOfTurn()
		completed = true

func reset():
	trapsLeft = 3
	spacesLeft = 3
	stage=0

func endOfTurn():
	global_position = boardRef.BtoW(boardPosition)
	storedMovement.clear()
	$squareSelector.global_position=boardRef.BtoW(selectorPos)
	boardRef.updateLocation(boardRef.Tiles.player,boardPosition)
