extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = ''
	if is_multiplayer_authority(): initial_on_player()

func initial_on_player():
	$Label.text += 'ME - '

@rpc()
func test_rpc():
	$Label.text += '1'
	
@rpc('any_peer')
func test_rpc_any_peer():
	$Label.text += '2'

@rpc('call_local')
func test_rpc_call_local():
	$Label.text += '3'

@rpc('call_local','any_peer')
func test_rpc_local_any_peer():
	$Label.text += '4'

@rpc()
func test_rpc_if():
	if multiplayer.get_remote_sender_id() != get_multiplayer_authority(): return
	$Label.text += '5'
	
@rpc('any_peer')
func test_rpc_any_peer_if():
	if multiplayer.get_remote_sender_id() != get_multiplayer_authority(): return
	$Label.text += '6'

@rpc('call_local')
func test_rpc_call_local_if():
	if multiplayer.get_remote_sender_id() != get_multiplayer_authority(): return
	$Label.text += '7'

@rpc('call_local','any_peer')
func test_rpc_local_any_peer_if():
	if multiplayer.get_remote_sender_id() != get_multiplayer_authority(): return
	$Label.text += '8'

func _on_button_pressed():
	rpc.call('test_rpc')
	rpc.call('test_rpc_call_local')
	rpc.call('test_rpc_any_peer')
	rpc.call('test_rpc_local_any_peer')
	rpc.call('test_rpc_if')
	rpc.call('test_rpc_call_local_if')
	rpc.call('test_rpc_any_peer_if')
	rpc.call('test_rpc_local_any_peer_if')
