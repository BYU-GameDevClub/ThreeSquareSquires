extends Node2D

@onready var HostJoinMenu = $PanelContainer/MarginContainer/HostJoin
@onready var HostMenu = $PanelContainer/MarginContainer/Host
@onready var JoinMenu = $PanelContainer/MarginContainer/Join
@onready var WaitMenu = $PanelContainer/MarginContainer/Waiting
@onready var SettingsMenu = $PanelContainer/MarginContainer/Settings
@onready var PortLineEdit = $PanelContainer/MarginContainer/Settings/HBoxContainer/PortLineEdit
@onready var WaitLineEdit = $PanelContainer/MarginContainer/Waiting/HBoxContainer/IPEditText
@onready var JoinIPLineEdit = $PanelContainer/MarginContainer/Join/HBoxContainer/JoinLineEdit
@onready var SettingsCancelButton = $PanelContainer/MarginContainer/Settings/HBoxContainer/CancelButton
@onready var SaveButton = $"PanelContainer/MarginContainer/Settings/HBoxContainer2/Save Button"

func _ready():
	WaitMenu.visibility_changed.connect(func(): WaitLineEdit.text = Network.get_address())
	SettingsMenu.visibility_changed.connect(func(): PortLineEdit.text = str(Network.get_port()))
	Network.game_start.connect(game_start)

func _all_invis():
	HostJoinMenu.visible = false
	HostMenu.visible = false
	JoinMenu.visible = false
	WaitMenu.visible = false
	SettingsMenu.visible = false

func _on_hj_host_btn_pressed():
	HostJoinMenu.visible = false
	HostMenu.visible = true

func _on_hj_join_btn_pressed():
	HostJoinMenu.visible = false
	JoinMenu.visible = true

func _on_h_host_network_btn_pressed():
	if Network.host_network():
		Network.launch_server()
		HostMenu.visible = false
		WaitMenu.visible = true
	else:
		$PanelContainer/MarginContainer/Host/HBoxContainer/HostNetwork.disabled = true

func _on_h_host_lan_btn_pressed():
	if Network.host_local():
		Network.launch_server()
		HostMenu.visible = false
		WaitMenu.visible = true
	else:
		$PanelContainer/MarginContainer/Host/HBoxContainer2/HostLAN.disabled = true

func _on_j_join_btn_pressed():
	Network.join_server(JoinIPLineEdit.text)

func _on_cancel_button_pressed():
	_all_invis()
	HostJoinMenu.visible = true
	Network.cancel()

func _on_s_save_btn_pressed(node):
	Network.set_port(int(PortLineEdit.text))
	node.visible = true
	SettingsMenu.visible = false

func _on_s_cancel_btn_pressed(node):
	node.visible = true
	SettingsMenu.visible = false

func _on_settings_button_pressed(nodePath):
	var node = get_node(nodePath)
	node.visible = false
	SettingsMenu.visible = true
	if SaveButton.pressed.is_connected(_on_s_save_btn_pressed):
		SaveButton.pressed.disconnect(_on_s_save_btn_pressed)
		SettingsCancelButton.pressed.disconnect(_on_s_cancel_btn_pressed)
	SaveButton.pressed.connect(_on_s_save_btn_pressed.bind(node))
	SettingsCancelButton.pressed.connect(_on_s_cancel_btn_pressed.bind(node))

func game_start():
	var game = preload("res://FullGame/FullGame.tscn").instantiate()
	add_sibling(game)
	for id in Network.get_connected_ids():
		if id == 1:
			game.player1.RegisterPlayer(id, game.player2)
		else:
			game.player2.RegisterPlayer(id, game.player1)
	call_deferred("free")


func _on_quick_connect_pressed():
	Network.quick_connect()
	HostJoinMenu.visible = false
	WaitMenu.visible = true


func _on_mini_game_pressed():
	add_sibling(preload("res://Minigame/MinigameTest.tscn").instantiate())
