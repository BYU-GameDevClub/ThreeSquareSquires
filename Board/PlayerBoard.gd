extends Node2D

#For specifying what is put on the board spaces
#More can be added later
enum Tiles{
	empty,
	player,
	wall,
	trap
}

#Just to make a 2dArray
func create2dArray(height,width):
	var a = []
	for x in range(width):
		a.append([])
		a[x].resize(height)
		for y in range(height):
			a[x][y] = Tiles.empty
	return a
	
#Variables related to the board and size
@export var boardHeight = 9
@export var boardWidth = 22
@onready var tileSize = $Tiles.tile_set.tile_size.x*$Tiles.scale.x
var board = create2dArray(boardHeight,boardWidth)
var otherBoard
@onready var tileMap:TileMap = $Tiles
@onready var player = $Player
func make_moves(moves, other_moves, enemeyTraps):
	if (!is_multiplayer_authority()): return
	print(Network.get_id(),': I moved ',moves,' they moved ', other_moves,' they placed traps @', enemeyTraps)
	# DEAL WITH OTHER PLAYER
	for i in range(len(moves)):
		print('%d: Move #%d'%[Network.get_id(), i+1])
		var _myMove = moves[i]
		var _oponentMove = other_moves[i]
		otherBoard.player.boardPosition += other_moves[i]
		if (Network.is_host()): await get_tree().create_timer(1).timeout
		await get_parent().hasMoved.post()
func _ready():
	for i in boardHeight:
		board[0][i]=Tiles.wall
		board[boardWidth-1][i]=Tiles.wall
	for i in boardWidth:
		board[i][0]=Tiles.wall
		board[i][boardHeight-1]=Tiles.wall

func RegisterPlayer(id, other):
	name = str(id)
	set_multiplayer_authority(id)
	if (id != Network.get_id()):
		# Code to set differences
		$Player/squareSelector.visible = false
	otherBoard = other
	$Player.ready_player()

#For updating different location during the game loop
func updateLocation(type,Coord):
	board[Coord.x][Coord.y]=type

func checkTile(coord):
	return board[coord.x][coord.y]

func BtoW(_board):
	var new = Vector2()
	new.x = _board.x*tileSize+tileSize/2+global_position.x
	new.y = _board.y*tileSize+tileSize/2+global_position.y
	return new
