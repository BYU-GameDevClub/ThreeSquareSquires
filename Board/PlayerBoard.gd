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
	for x in range(height):
		a.append([])
		a[x].resize(width)
		for y in range(width):
			a[x][y] = Tiles.empty
	return a
	


#Variables related to the board and size
@export var boardHeight = 9
@export var boardWidth = 22
@onready var tileSize = $Tiles.tile_set.tile_size.x*$Tiles.scale.x
var board = create2dArray(boardHeight,boardWidth)

func _ready():
	for i in boardWidth:
		board[0][i]=Tiles.wall
		board[boardHeight-1][i]=Tiles.wall
	for i in boardHeight:
		board[i][0]=Tiles.wall
		board[i][boardWidth-1]=Tiles.wall
		
	$Player.ready_player()

func RegisterPlayer(id):
	name = str(id)
	set_multiplayer_authority(id)
	$Player.ready_player()

#For updating different location during the game loop
func updateLocation(type,Coord):
	board[Coord.x][Coord.y]=type

func checkTile(coord):
	return board[coord.x][coord.y]

func BtoW(board):
	var new = Vector2()
	new.x = board.x*tileSize+tileSize/2+global_position.x
	new.y = board.y*tileSize+tileSize/2+global_position.y
	return new
