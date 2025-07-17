extends CanvasLayer

@onready var fish : Fish = get_tree().get_first_node_in_group("FISH")
@onready var lightMeter: TextureProgressBar = %LightMeter
@onready var gameNode : Node2D = get_tree().get_first_node_in_group("GAMENODE")
@onready var upgrade_menu_control: Control = $UpgradeMenuControl

signal end_reached

func _ready() -> void:
	end_reached.connect(on_end_reached)
	lightMeter.value = 100
	gameNode.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _process(delta: float) -> void:
	if gameNode.process_mode == Node.PROCESS_MODE_PAUSABLE:
		lightMeter.value -= .125
	if !fish.onScreen.is_on_screen():
		lightMeter.value -= .125

func _on_new_game_pressed() -> void:
	%MainMenuControl.hide()
	gameNode.process_mode = Node.PROCESS_MODE_PAUSABLE


func _on_quit_pressed() -> void:
	get_tree().quit()

func on_end_reached() -> void:
	gameNode.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	upgrade_menu_control.show()
