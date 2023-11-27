extends Node
var _mutexes = {}
func register(key, onComplete=func(_v):pass) -> _Mutex:
	self._mutexes[key] = _Mutex.new(key, onComplete)
	add_child(_mutexes[key])
	return _mutexes[key]

@rpc("call_local", "any_peer")
func _set_val(_id, idx, val):
	_mutexes[_id]._set_val(idx, val)

@rpc("call_local", "any_peer")
func _reset(_id):
	_mutexes[_id]._reset()

class _Mutex extends Node:
	# Private Values
	var _default
	var _id
	var _vals
	var _max = 2
	var _set_count = 0
	var complete = func():pass
	var _nodes = {}
	class sigNode extends Node:
		func _init(id) -> void:
			name = str(id)
			set_multiplayer_authority(id)
		signal _s
			
	func _init(key, onComplete) -> void:
		self._id = key
		self.complete = onComplete
		self._reset()
		self.name = str(_id)
		for id in Network.get_connected_ips():
			_nodes[id] = sigNode.new(id)
			add_child(_nodes[id])
			
	func post(val = _default):
		var idx = int(Network.get_id()!=1)
		NetMutex.rpc('_set_val', _id, idx, val)
		for n in _nodes:
			await _nodes[n]._s
		print(Network.get_id(),': fin post')
	func reset():
		NetMutex.rpc('_reset', _id) 
	func _reset():
		_vals = [_default, _default]
		_set_count = 0
	func _rollover():
		await complete.call(_vals)
		for n in _nodes:
			await _nodes[n]._s.emit()
		_reset()
		print(Network.get_id(),': %s emitted'%_id)
	func _set_val(idx, val):
		_set_count+= 1
		_vals[idx] = val
		if _set_count == _max: _rollover()

