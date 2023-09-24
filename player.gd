extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	set_multiplayer_authority(name.to_int())
	if !is_multiplayer_authority():
		$HBoxContainer/Button.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
