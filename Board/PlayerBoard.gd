extends Node2D
class_name PlayerBoard

#For specifying what is put on the board spaces
enum TileLayer {
	BACKGROUND		= 0,
	DECORATION		= 1,
	PLAYER			= 2,
	TRAPS_HIDDEN	= 3,
	TRAPS_VISIBLE	= 4,
	BOOST_HIDDEN	= 5,
	BOOST_VISIBLE	= 6,
	GHOST			= 7
}
enum Tile {
	BACKGROUND	= 0,
	WALL		= 1,
	SPIKE_TRAP	= 2,
	PIT_TRAP	= 3,
	SPRING_PAD 	= 4,
}
var tile_to_vec = {
	Tile.BACKGROUND:Vector2i(0,6),
	Tile.WALL:		Vector2i(6,2),
	Tile.SPIKE_TRAP:Vector2i(4,6),
	Tile.PIT_TRAP:	Vector2i(7,1),
	Tile.SPRING_PAD:Vector2i(6,5)
}
#region CONSTANTS
#Variables related to the board and size
const BOARD_HEIGHT = 9
const BOARD_WIDTH = 22
@onready var TILE_SIZE = $Tiles.tile_set.tile_size.x*$Tiles.scale.x
const TRAPS = [Tile.SPIKE_TRAP, Tile.PIT_TRAP]
const BOOSTS = [Tile.SPRING_PAD]
#endregion CONSTANTS
@onready var tile_map:TileMap = $Tiles
@onready var player = $Player
var other_board
func make_moves(moves, other_moves, your_traps, enemey_traps):
	if (!is_multiplayer_authority()): return
	$Player/Arrows.clear_layer(0)
	print(Network.get_id(),': I moved ',moves,' they moved ', other_moves)
	print('they placed traps @', enemey_traps, ' you placed@', your_traps)
	for trap_info in enemey_traps:
		set_tile(trap_info[0], trap_info[1], TileLayer.TRAPS_HIDDEN)
	for trap_info in your_traps:
		other_board.set_tile(trap_info[0], trap_info[1], TileLayer.TRAPS_HIDDEN)
	await get_parent().hasMoved.post()
	for i in range(len(moves)):
		print('%d: Move #%d'%[Network.get_id(), i+1])
		player.move(moves[i])
		other_board.player.move( other_moves[i])
		if (Network.is_host()): await get_tree().create_timer(1).timeout
		await get_parent().hasMoved.post()

func RegisterPlayer(id, other):
	name = str(id)
	set_multiplayer_authority(id)
	other_board = other
	if (id != Network.get_id()):
		tile_map.set_layer_modulate(TileLayer.TRAPS_HIDDEN, Color.html("#FFFFFFAA"))
		tile_map.set_layer_modulate(TileLayer.BOOST_HIDDEN, Color.html("#FFFFFFAA"))
		$Player/squareSelector.visible = false
	else:
		$Player.process_mode = Node.PROCESS_MODE_INHERIT
	$Player.ready_player()

func set_tile(coord:Vector2i,type:Tile,layer:TileLayer):
	tile_map.set_cell(layer,coord,0,tile_to_vec[type])

func is_wall(coord:Vector2i):
	return tile_map.get_cell_atlas_coords(TileLayer.BACKGROUND, coord) == tile_to_vec[Tile.WALL]

func is_trap(coord:Vector2i):
	for trap in TRAPS:
		if tile_map.get_cell_atlas_coords(TileLayer.TRAPS_HIDDEN, coord) == tile_to_vec[trap]:
			return true
		if tile_map.get_cell_atlas_coords(TileLayer.TRAPS_VISIBLE, coord) == tile_to_vec[trap]:
			return true
	return false

func is_boost(coord:Vector2i):
	for boost in BOOSTS:
		if tile_map.get_cell_atlas_coords(TileLayer.BOOST_HIDDEN, coord) == tile_to_vec[boost]:
			return true
		if tile_map.get_cell_atlas_coords(TileLayer.BOOST_VISIBLE, coord) == tile_to_vec[boost]:
			return true
	return false

func reveal_tile(coord:Vector2i):
	var trap_hidden:Vector2i = tile_map.get_cell_atlas_coords(TileLayer.TRAPS_HIDDEN, coord)
	if trap_hidden != Vector2i(-1, -1):
		tile_map.set_cell(TileLayer.TRAPS_HIDDEN,coord)
		tile_map.set_cell(TileLayer.TRAPS_VISIBLE,coord,0,trap_hidden)

func BtoW(_board):
	return tile_map.to_global(tile_map.map_to_local(_board))
func clear_ghosts():
	tile_map.clear_layer(TileLayer.GHOST)
	other_board.tile_map.clear_layer(TileLayer.GHOST)
