extends TileMap

var pos = Vector2i(0,0)

func _on_player_arrows(changes,reverse):
	var current = changes[0]
	var previous = changes[1]
	if !reverse:
		pos += current
		if current.x>0:
			if abs(current) == abs(previous):
				set_cell(0,pos-current,41,Vector2i(1,0))
			elif previous != Vector2i(0,0):
				if previous.y>0:
					set_cell(0,pos-current,41,Vector2i(1,2))
				else:
					set_cell(0,pos-current,41,Vector2i(1,1))
			set_cell(0,pos,41,Vector2i(2,0))

		elif current.x<0:
			if abs(current) == abs(previous):
				set_cell(0,pos-current,41,Vector2i(1,0))
			elif previous != Vector2i(0,0):
				if previous.y>0:
					set_cell(0,pos-current,41,Vector2i(2,2))
				else:
					set_cell(0,pos-current,41,Vector2i(2,1))
			set_cell(0,pos,41,Vector2i(0,0))

		elif current.y>0:
			if abs(current) == abs(previous):
				set_cell(0,pos-current,41,Vector2i(0,2))
			elif previous != Vector2i(0,0):
				if previous.x>0:
					set_cell(0,pos-current,41,Vector2i(2,1))
				else:
					set_cell(0,pos-current,41,Vector2i(1,1))
			set_cell(0,pos,41,Vector2i(0,3))

		elif current.y<0:
			if abs(current) == abs(previous):
				set_cell(0,pos-current,41,Vector2i(0,2))
			elif previous != Vector2i(0,0):
				if previous.x>0:
					set_cell(0,pos-current,41,Vector2i(2,2))
				else:
					set_cell(0,pos-current,41,Vector2i(1,2))
			set_cell(0,pos,41,Vector2i(0,1))

	else:
		pos -= current
		set_cell(0,pos+current,41)
		if previous.x>0:
			set_cell(0,pos,41,Vector2i(2,0))
		elif previous.x<0:
			set_cell(0,pos,41,Vector2i(0,0))
		elif previous.y>0:
			set_cell(0,pos,41,Vector2i(0,3))
		elif previous.y<0:
			set_cell(0,pos,41,Vector2i(0,1))
