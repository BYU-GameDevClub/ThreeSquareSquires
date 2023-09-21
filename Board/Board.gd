extends Node2D

#Just to make a 2dArray
func create2dArray(height,width):
	var a = []
	for x in range(height):
		a.append([])
		a[x].resize(width)
	return a
	
#For specifying what is put on the board spaces
#More can be added later
enum spaces {
	empty,
	wall,
	trap
}

#Variables related to the board and size
@export var boardHeight = 30
@export var boardWidth = 30
var board = create2dArray(boardHeight,boardWidth)

#For updating different location during the game loop
func updateLocation(type,xCoord,yCoord):
	board[xCoord][yCoord]=type
