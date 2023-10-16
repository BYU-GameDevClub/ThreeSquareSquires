extends Node2D

#For specifying what is put on the board spaces
#More can be added later
enum {
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
			a[x][y] = empty
	return a
	


#Variables related to the board and size
@export var boardHeight = 7
@export var boardWidth = 20
var tileSize = 50
var board = create2dArray(boardHeight,boardWidth)

func _ready():
	board[1][1]=wall
	
func RegisterPlayer(id):
	name = str(id)
	set_multiplayer_authority(id)
	$Player.ready_player()

#For updating different location during the game loop
func updateLocation(type,Coord):
	board[Coord.x][Coord.y]=type
