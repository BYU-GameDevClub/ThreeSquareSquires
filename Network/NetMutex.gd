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
	var _bound = false
	var complete = func():pass
	signal _signal
	signal _unbound
	func _init(key, onComplete) -> void:
		self._id = key
		self.complete = onComplete
		self.name = str(_id)
		self._reset()
	func _wait():
		if _bound: await _unbound
		_bound = true
	func _unwait():
		_bound = false
		call_deferred('emit_signal', '_unbound')
	func post(val = true):
		await _wait()
		NetMutex.rpc('_set_val', _id, int(Network.get_id()!=1), val)
		_unwait()
		await _signal
	func reset():
		NetMutex.rpc('_reset', _id) 
	func _reset():
		_vals = [_default, _default]
		_set_count = 0
	func _rollover():
		await complete.call(_vals)
		_signal.emit()
		_reset()
	func _set_val(idx, val):
		await _wait()
		_set_count+= 1
		_vals[idx] = val
		if _set_count == _max: _rollover()
		_unwait()

