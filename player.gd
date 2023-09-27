extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	set_multiplayer_authority(name.to_int())
	$Label.text = name
	if !is_multiplayer_authority(): initial_on_player()

func initial_on_player():
	$Label.text += ' - ME'
