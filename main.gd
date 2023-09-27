extends Node2D


var upnp = UPNP.new()
var multi_peer = ENetMultiplayerPeer.new()

@onready var lbl = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HostIPLabel
@onready var portTxt = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/LineEdit
# Called when the node enters the scene tree for the first time.
var players = []
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_quit():
	if multiplayer.is_server():
		upnp.delete_port_mapping(4242,"UPD")
		upnp.delete_port_mapping(4242,"TCP")

func _get_port_num():
	var portNum = 4242
	if str(portTxt.text) != "":
		portNum = str(portTxt.text).to_int()
	return portNum

func _on_host_button_pressed():
	var port = _get_port_num()
	var is_host = TryUPNP(port)
	multi_peer.create_server(port, 2)
	multiplayer.multiplayer_peer = multi_peer
	multi_peer.peer_connected.connect(func(id): add_player_character(id))
	add_player_character()

func _on_join_button_pressed():
	var port = _get_port_num()
	multi_peer.create_client(lbl.text, port)
	multiplayer.multiplayer_peer = multi_peer
	add_player_character()
	
func TryUPNP(port:int):
	var discover_result = upnp.discover()
	if discover_result != UPNP.UPNP_RESULT_SUCCESS: return false
	if !upnp.get_gateway() or !upnp.get_gateway().is_valid_gateway(): return false
	var udp_result = upnp.add_port_mapping(port,port,"three_square_udp","UDP",0)
	var tcp_result = upnp.add_port_mapping(port,port,"three_square_tcp","TCP",0)
	if udp_result != UPNP.UPNP_RESULT_SUCCESS:
		udp_result = upnp.add_port_mapping(port,port,"","UDP",0)
	if tcp_result != UPNP.UPNP_RESULT_SUCCESS:
		tcp_result = upnp.add_port_mapping(port,port,"","TCP",0)
	if udp_result != UPNP.UPNP_RESULT_SUCCESS && tcp_result != UPNP.UPNP_RESULT_SUCCESS:
		upnp.delete_port_mapping(port,"UDP")
		upnp.delete_port_mapping(port,"TCP")
		return false
	lbl.text = upnp.query_external_address()
	lbl.editable = false
	print(lbl.text)
	return true

@rpc("call_local")
func StartGame(playerInfo):
	print('starting the game...')
	var game = preload("res://game.tscn").instantiate()
	add_sibling(game)
	for id in playerInfo:
		var player = preload("res://player.tscn").instantiate()
		player.name = str(id);
		game.add_child(player)
	call_deferred("free")
	
func add_player_character(id=1):
	print('%d joined' % id)
	players.append(id)
	if len(players) == 2: rpc("StartGame", players)
