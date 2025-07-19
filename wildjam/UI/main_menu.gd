extends CanvasLayer

const BOAT = preload("res://Player/Scenes/boat.tscn")

@export var lightMeterMax : float = 100
@export var lightDecayRate : float = .125

@onready var fish : Fish = get_tree().get_first_node_in_group("FISH")
@onready var boat : Boat = get_tree().get_first_node_in_group("BOAT")
@onready var lightMeter: TextureProgressBar = %LightMeter
@onready var gameNode : Node2D = get_tree().get_first_node_in_group("GAMENODE")
@onready var upgrade_menu_control: Control = $UpgradeMenuControl

@onready var prevRight: Sprite2D = %PreviewRight
@onready var prevMiddle: Sprite2D = %PreviewMiddle
@onready var prevLeft: Sprite2D = %PreviewLeft
@onready var itemDesc: RichTextLabel = %ItemDescription
@onready var angerMeter: TextureProgressBar = %AngerMeter
@onready var cost: RichTextLabel = %Cost

signal end_reached

# MAINMENU AND MAIN UI
func _ready() -> void:
	%UpgradeMenu.play("default")
	end_reached.connect(on_end_reached)
	lightMeter.value = lightMeterMax
	angerMeter.value = Global.anger
	gameNode.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _process(delta: float) -> void:
	if gameNode.process_mode == Node.PROCESS_MODE_PAUSABLE:
		lightMeter.value -= lightDecayRate
	if !fish.onScreen.is_on_screen():
		lightMeter.value -= lightDecayRate


func _on_new_game_pressed() -> void:
	%MainMenuControl.hide()
	gameNode.process_mode = Node.PROCESS_MODE_PAUSABLE


func _on_quit_pressed() -> void:
	get_tree().quit()

# UPGRADE MENU

var upgradeInv : Dictionary = {
	Global.UPGRADES.LIGHTCAPACITY : 0,
	Global.UPGRADES.LIGHTPOTENCY : 0,
	Global.UPGRADES.LIGHTPRESERVER : 0,
	Global.UPGRADES.MOVESPEED : 0,
	Global.UPGRADES.STRONGERHULL : 0,
	Global.UPGRADES.BLOWHOLE : 0,
}

var max_frame : int = 5
var min_frame : int = 0
func on_end_reached() -> void:
	if get_tree().get_first_node_in_group("BOAT"):
		Global.boats += 1
		Global.redempCounter -= 1 if Global.anger >= 1 else 0
		Global.anger -= 1 if Global.redempCounter <= 0 else 0
	else:
		Global.anger += 1
		var newBoat = BOAT.instantiate()
		newBoat.global_position = fish.global_position
		newBoat.max_health += 1 if upgradeInv[Global.UPGRADES.STRONGERHULL] >= 1 else 0
		newBoat.health = newBoat.max_health
		owner.add_child(newBoat)
		
		boat = newBoat
	gameNode.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	upgrade_menu_control.show()
	
func _on_upgrade_menu_control_visibility_changed() -> void:
	await get_tree().create_timer(.1).timeout
	prevLeft.frame = max_frame
	prevMiddle.frame = min_frame
	prevRight.frame = min_frame + 1
	show_upgrade_info()
	
func _on_buy_pressed() -> void:
	if can_purchase_and_apply():
		upgradeInv[prevMiddle.frame] += 1 
		Global.money -= int(cost.text)
	show_upgrade_info()

func can_purchase_and_apply() -> bool:
	if Global.money < int(cost.text):
		return false
	
	match prevMiddle.frame:
		Global.UPGRADES.LIGHTCAPACITY:
			lightMeterMax += 50
			lightMeter.value = lightMeterMax
		Global.UPGRADES.LIGHTPOTENCY:
			pass
		Global.UPGRADES.LIGHTPRESERVER:
			lightDecayRate *= .9
		Global.UPGRADES.MOVESPEED:
			fish.SPEED += 25
		Global.UPGRADES.STRONGERHULL:
			if upgradeInv[prevMiddle.frame] >= 1:
				return false
			boat.max_health += 1
			boat.health = boat.max_health
		Global.UPGRADES.BLOWHOLE:
			if upgradeInv[prevMiddle.frame] >= 1:
				return false
	return true

func _on_scroll_right_pressed() -> void:
	prevLeft.frame = prevMiddle.frame
	prevMiddle.frame = prevRight.frame
	prevRight.frame = prevRight.frame + 1 if prevRight.frame < max_frame else min_frame
	show_upgrade_info()


func _on_scroll_left_pressed() -> void:
	prevRight.frame = prevMiddle.frame
	prevMiddle.frame = prevLeft.frame
	prevLeft.frame = prevLeft.frame - 1 if prevLeft.frame > min_frame else max_frame
	show_upgrade_info()

func show_upgrade_info() -> void:
	var cost_increase : int = 15 * upgradeInv[prevMiddle.frame]
	%BoatsSaved.text = str(Global.boats)
	%Money.text = str(Global.money)
	match prevMiddle.frame:
		Global.UPGRADES.LIGHTCAPACITY,Global.UPGRADES.LIGHTPOTENCY,Global.UPGRADES.LIGHTPRESERVER:
			cost.text = str(50 + cost_increase)
		Global.UPGRADES.MOVESPEED,Global.UPGRADES.STRONGERHULL,Global.UPGRADES.BLOWHOLE:
			cost.text = str(150 + cost_increase)
	
	var text : String
	match prevMiddle.frame:
		Global.UPGRADES.LIGHTCAPACITY:
			text = "[b]LIGHT CAPACITY -[/b] Increases the max amount of light the spirit can hold at a time."
		Global.UPGRADES.LIGHTPOTENCY:
			text = "[b]LIGHT POTENCY -[/b] Increases the brightness of the spirit's light. Does not increase consumption of light."
		Global.UPGRADES.LIGHTPRESERVER:
			text = "[b]LIGHT PRESERVER -[/b] Decreases the rate at which the spirit's light is consumed."
		Global.UPGRADES.MOVESPEED:
			text = "[b]FASTER FINS -[/b] Increases the speed at which the spirit can move."
		Global.UPGRADES.STRONGERHULL:
			text = "[b]STRONGER HULL -[/b] Increases the hitpoints of lost boats by 1. One time purchase."
		Global.UPGRADES.BLOWHOLE:
			text = "[b]BLOWHOLE -[/b] Allows the spirit the ability to destroy oncoming projectiles or obstacles at the cost of light. One time purchase."
			text += "\nYou have " + str(upgradeInv[prevMiddle.frame]) + "."
			itemDesc.text = text
	text += "\n\nYou have " + str(upgradeInv[prevMiddle.frame]) + "."
	itemDesc.text = text
