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
var tileSize
var board = create2dArray(boardHeight,boardWidth)

func _ready():
	tileSize = $Tiles.tile_set.tile_size.x*$Tiles.scale.x
	print(tileSize)
	$Player.rready()
	board[1][1]=wall
	
func RegisterPlayer():
	set_multiplayer_authority(name.to_int())
	

#For updating different location during the game loop
func updateLocation(type,Coord):
	board[Coord.x][Coord.y]=type

func BtoW(board):
	var new = Vector2()
	new.x = board.x*tileSize+tileSize/2
	new.y = board.y*tileSize+tileSize/2
	return new
