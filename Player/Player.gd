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
var boardPosition = Vector2i(1,1)

@onready var boardRef:PlayerBoard = get_parent()
var gameRef

#Setting stage of turn
var stage = 0

#Change to board length for proper spacing
func ready_player():
	gameRef = boardRef.get_parent()
	if get_parent().TILE_SIZE != null:
		tileSize =  boardRef.TILE_SIZE
		global_position=(boardRef.BtoW(Vector2i(1,1)))

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
			free_movement()

#//////////////Functions relating to stage 1: movement
var storedMovement = []
var placedTraps = []
var selectorPos = boardPosition
var init = false
func movement():
	if !init:
		$squareSelector.global_position = global_position
		selectorPos = boardPosition
		init = true
	if len(storedMovement) < 3:
		var changes = squareMovement()
		selectorPos += changes
		squareSelection(changes)
	if Input.is_action_just_pressed("return") and !storedMovement.is_empty():
		goBack()
	if (Input.is_action_just_pressed("select") and len(storedMovement) == 3):
		stage+=1
		init = false
func free_movement():
	var changes = squareMovement()
	selectorPos += changes
	$squareSelector.global_position = boardRef.BtoW(selectorPos)

#Controls the actually selection of a movement space
func squareSelection(changes):
	if !boardRef.is_wall(selectorPos) and changes != Vector2i(0,0):
		$squareSelector.global_position = boardRef.BtoW(selectorPos)
		storedMovement.append(changes)
		var arrowChanges = [changes, Vector2i(0,0)]
		if storedMovement.size()>1:
			arrowChanges[1] = storedMovement[-2]
		arrows.emit(arrowChanges,false)
	else:
		selectorPos -= changes

func goBack():
	var reverse = storedMovement.pop_back()
	$squareSelector.global_position -= reverse*tileSize
	var send = [reverse,Vector2i(0,0)]
	if storedMovement.size()>0:
		send = [reverse,storedMovement[-1]]
	arrows.emit(send,true)
	selectorPos -= reverse

#//////////////Function for stage 2:Trap Selection
var currentTrap = 3
func traps():
	if len(placedTraps) < 3:
		var changes = squareMovement()
		selectorPos += changes
		$squareSelector.global_position += changes*tileSize
		if Input.is_action_just_pressed("select"):
			placeTrap()
	else:
		stage += 1
		await gameRef.moves.post([storedMovement.duplicate(), placedTraps.duplicate()])
		reset()
	return

func placeTrap():
	placedTraps.append([selectorPos, currentTrap])
	boardRef.set_tile(selectorPos, currentTrap, PlayerBoard.TileLayer.GHOST)


#///////////////Function for moving selection Square
func squareMovement():
	var changes = Vector2i(0,0)
	if Input.is_action_just_pressed('move_right'):
		changes.x += right
	elif Input.is_action_just_pressed("move_left"):
		changes.x += left
	elif Input.is_action_just_pressed("move_up"):
		changes.y += up
	elif Input.is_action_just_pressed("move_down"):
		changes.y += down
	var boardLeft = Vector2(boardRef.BtoW(Vector2i(0,0)))
	var boardRight = Vector2(boardRef.BtoW(Vector2i(boardRef.BOARD_WIDTH-1,boardRef.BOARD_HEIGHT-1)))
	
	if(stage != 0):
		if $squareSelector.global_position.x == boardLeft.x and changes.x == left:
			return Vector2i(0,0)
		if $squareSelector.global_position.x == boardRight.x and changes.x == right:
			return Vector2i(0,0)
		if $squareSelector.global_position.y == boardLeft.y and changes.y == up:
			return Vector2i(0,0)
		if $squareSelector.global_position.y == boardRight.y and changes.y == down:
			return Vector2i(0,0)
	
	return changes


#//////////////PLay through the game

func reset():
	init = false
	$Arrows.clear_layer(0)
	$Arrows.pos = Vector2i(0,0)
	boardRef.clear_ghosts()
	print(Network.get_id(),': New Turn')
	stage=0
	placedTraps = []
	storedMovement = []

func move(dir):
	boardPosition += dir
	global_position = boardRef.BtoW(boardPosition)
	if boardRef.is_trap(boardPosition):
		boardRef.reveal_tile(boardPosition)
		print("TRIGGERED TRAP")
	
