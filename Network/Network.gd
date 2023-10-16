extends Node

var hostIP = ""
var port = 4242
enum  { DISCONNECTED, UNPN_HOST, LAN_HOST, CLIENT }
var status = DISCONNECTED
signal game_start

var _upnp = UPNP.new()
var multi_peer = ENetMultiplayerPeer.new()
var connectedIPs = []

func tree_exiting():
	if status == UNPN_HOST:
		_upnp.delete_port_mapping(4242,"UPD")
		_upnp.delete_port_mapping(4242,"TCP")
		
func launch_server():
	multi_peer.create_server(port, 2)
	multiplayer.multiplayer_peer = multi_peer
	multi_peer.peer_connected.connect(func(id): add_player_character(id))
	add_player_character()
	
func join_server(joinIP):
	multi_peer.create_client(joinIP, port)
	multiplayer.multiplayer_peer = multi_peer
	status = CLIENT

func host_network():
	var discover_result = _upnp.discover()
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		hostIP = ''
		return false
	if !_upnp.get_gateway() or !_upnp.get_gateway().is_valid_gateway():
		hostIP = ''
		return false
	var udp_result = _upnp.add_port_mapping(port,port,"three_square_udp","UDP",0)
	var tcp_result = _upnp.add_port_mapping(port,port,"three_square_tcp","TCP",0)
	if udp_result != UPNP.UPNP_RESULT_SUCCESS:
		udp_result = _upnp.add_port_mapping(port,port,"","UDP",0)
	if tcp_result != UPNP.UPNP_RESULT_SUCCESS:
		tcp_result = _upnp.add_port_mapping(port,port,"","TCP",0)
	if udp_result != UPNP.UPNP_RESULT_SUCCESS && tcp_result != UPNP.UPNP_RESULT_SUCCESS:
		_upnp.delete_port_mapping(port,"UDP")
		_upnp.delete_port_mapping(port,"TCP")
		hostIP = ''
		return false
	status = UNPN_HOST
	hostIP = _upnp.query_external_address()
	return true

func host_local():
	print(OS.get_environment('HOSTNAME'), OS.get_environment('hostname'), OS)
	if OS.has_feature("windows") && OS.has_environment("COMPUTERNAME"):
		hostIP = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	elif OS.has_environment("HOSTNAME"):
		hostIP = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	else:
		hostIP = IP.get_local_addresses()[0]
	status = LAN_HOST
	return true

func add_player_character(id=1):
	connectedIPs.append(id)
	if len(connectedIPs) == 2: rpc("start_game", connectedIPs)

func cancel():
	if DISCONNECTED: return
	if CLIENT: pass
	elif UNPN_HOST:
		_upnp.delete_port_mapping(4242,"UPD")
		_upnp.delete_port_mapping(4242,"TCP")
		multi_peer.close()
	elif LAN_HOST:
		multi_peer.close()

func get_port():
	return port
func set_port(num):
	port = num
func get_address():
	return hostIP
func get_connected_ips():
	return connectedIPs

func quick_connect():
	host_local()
	if multi_peer.create_server(port, 2) != OK:
		join_server(hostIP)
	else:
		multiplayer.multiplayer_peer = multi_peer
		multi_peer.peer_connected.connect(func(id): add_player_character(id))
		add_player_character()
	return OK

@rpc("call_local")
func start_game(playerIds):
	connectedIPs = playerIds
	game_start.emit()

