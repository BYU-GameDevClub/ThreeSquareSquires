extends CharacterBody2D

enum{
	up = -1,
	down = 1,
	left = -1,
	right = 1,
	none = 0
}

signal arrows(changes,pos)

#Initialize for movement
var tileSize = 40
var boardPosition = Vector2(1,1)

var boardRef
var gameRef

#Setting stage of turn
var stage = 0

#Change to board length for proper spacing
func ready_player():
	boardRef = get_parent()
	gameRef = boardRef.get_parent()
	if get_parent().tileSize != null:
		tileSize =  boardRef.tileSize
		global_position=(boardRef.BtoW(Vector2(1,1)))
	turnFlow()

func _process(_delta):
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
			pass

#//////////////Functions relating to stage 1: movement
var spacesLeft = 3
var storedMovement = []
var placedTraps = []
var selectorPos = boardPosition
var init = false
func movement():
	if !init:
		$squareSelector.global_position = global_position
		selectorPos = boardPosition
		init = true
	if spacesLeft>0:
		var changes = squareMovement()
		selectorPos +=changes
		squareSelection(changes)
	if Input.is_action_just_pressed("return") and !storedMovement.is_empty():
		goBack()
	if (Input.is_action_just_pressed("select") and spacesLeft == 0):
		stage+=1
		init = false

#Controls the actually selection of a movement space
func squareSelection(changes):
	if boardRef.board[selectorPos.x][selectorPos.y] != boardRef.Tiles.wall and changes != Vector2(0,0):
		boardPosition = selectorPos
		$squareSelector.global_position = boardRef.BtoW(boardPosition)
		spacesLeft -= 1
		storedMovement.append(changes)
		var arrowChanges = [changes,Vector2(0,0)]
		if storedMovement.size()>1:
			arrowChanges[1] = storedMovement[-2]
		arrows.emit(arrowChanges,false)
	else:
		selectorPos -= changes

func goBack():
	var reverse = storedMovement.pop_back()
	$squareSelector.global_position -= reverse*tileSize
	var send = [reverse,Vector2(0,0)]
	if storedMovement.size()>0:
		send = [reverse,storedMovement[-1]]
	arrows.emit(send,true)
	selectorPos -= reverse
	spacesLeft +=1

#//////////////Function for stage 2:Trap Selection
var currentTrap = 3
var trapsLeft = 3
func traps():
	if trapsLeft > 0:
		var changes = squareMovement()
		selectorPos += changes
		$squareSelector.global_position += changes*tileSize
		if Input.is_action_just_pressed("select"):
			placeTrap()
	else:
		stage += 1
		go()
	return

func placeTrap():
	placedTraps.append(selectorPos)
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
	
	if(stage!=0):
		if $squareSelector.global_position.x == boardLeft.x and changes.x == left:
			return Vector2(0,0)
		if $squareSelector.global_position.x == boardRight.x and changes.x == right:
			return Vector2(0,0)
		if $squareSelector.global_position.y == boardLeft.y and changes.y == up:
			return Vector2(0,0)
		if $squareSelector.global_position.y == boardRight.y and changes.y == down:
			return Vector2(0,0)
	
	return changes


#//////////////PLay through the game
var completed:bool = false
func go():
	gameRef.moves.post([storedMovement.duplicate(), placedTraps.duplicate()])
	if boardRef.checkTile(boardPosition) == boardRef.Tiles.trap:
		print("Trapped")
	endOfTurn()
	await boardRef.finishedTurn
	print('New Turn')
	reset()

func reset():
	trapsLeft = 3
	spacesLeft = 3
	stage=0
	placedTraps = []
	storedMovement = []

func endOfTurn():
	$Arrows.clear_layer(0)
	$Arrows.pos = Vector2(0,0)
	global_position = boardRef.BtoW(boardPosition)
	$squareSelector.global_position=boardRef.BtoW(selectorPos)
	boardRef.updateLocation(boardRef.Tiles.player,boardPosition)
