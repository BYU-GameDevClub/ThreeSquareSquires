extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = 'Im the Server' if multiplayer.is_server() else 'Im a client'


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
