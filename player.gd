extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = name
	if is_multiplayer_authority(): initial_on_player()

func initial_on_player():
	$Label.text += ' - ME'

@rpc()
func test_rpc():
	print('called from: '+ name)
	$Label.text += 'I'

@rpc('call_local')
func test_rpc_call_local():
	print('called from: '+ name)
	$Label.text += 'L'

@rpc('any_peer')
func test_rpc_any_peer():
	print('called from: '+ name)
	$Label.text += 'A'
@rpc('call_local','any_peer')
func test_rpc_local_any_peer():
	print('called from: '+ name)
	$Label.text += 'J'

@rpc('call_local')
func test_rpc_all():
	if multiplayer.get_remote_sender_id() != get_multiplayer_authority(): return
	print('called from: '+ name)
	$Label.text += '2'

func _on_button_pressed():
	rpc.call('test_rpc')
	rpc.call('test_rpc_call_local')
	rpc.call('test_rpc_any_peer')
	rpc.call('test_rpc_local_any_peer')
	rpc.call('test_rpc_all')
