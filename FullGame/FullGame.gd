extends Node2D

@onready var player1 = $player1
@onready var player2 = $player2

var moves = NetMutex.register('moves', _make_moves)
var hasMoved = NetMutex.register('hasMoved',func(_v):emitSigToPlayers('made_move'))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func emitSigToPlayers(sigRPC):
	player1.rpc(sigRPC)
	player2.rpc(sigRPC)

func _make_moves(playerMoves):
	var player1moves = playerMoves[0][0]
	var player1traps = playerMoves[0][1]
	var player2moves = playerMoves[1][0]
	var player2traps = playerMoves[1][1]
	player1.rpc('make_moves', player1moves, player2moves, player2traps)
	player2.rpc('make_moves', player2moves, player1moves, player1traps)
