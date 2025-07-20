extends CanvasLayer

const BOAT = preload("res://Player/Scenes/boat.tscn")

@export var lightMeterMax : float = 100
@export var lightDecayRate : float = .222222

@onready var fish : Fish = get_tree().get_first_node_in_group("FISH")
@onready var boat : Boat = get_tree().get_first_node_in_group("BOAT")
@onready var lightMeter: TextureProgressBar = %LightMeter
@onready var gameNode : Node2D = get_tree().get_first_node_in_group("GAMENODE")
@onready var upgrade_menu_control: Control = $UpgradeMenuControl
@onready var main_menu_control: Control = %MainMenuControl

@onready var prevRight: Sprite2D = %PreviewRight
@onready var prevMiddle: Sprite2D = %PreviewMiddle
@onready var prevLeft: Sprite2D = %PreviewLeft
@onready var itemDesc: RichTextLabel = %ItemDescription
@onready var angerMeter: TextureProgressBar = %AngerMeter
@onready var cost: RichTextLabel = %Cost
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var angerLose: Control = %AngerLose
@onready var lightLose: Control = %LightLose

signal end_reached

var maxLightScale = Vector2(5.0,5.0)

# MAINMENU AND MAIN UI
func _ready() -> void:
	%UpgradeMenu.play("default")
	end_reached.connect(on_end_reached)
	
	lightMeter.value = lightMeterMax
	angerMeter.value = Global.anger
	fish.light.scale = maxLightScale
	fish.blowhole_used.connect(on_blowhole_used)
	
	gameNode.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _process(delta: float) -> void:
	if gameNode.process_mode == Node.PROCESS_MODE_PAUSABLE:
		#lightMeter.value -= lightDecayRate
		if !fish.onScreen.is_on_screen():
			lightMeter.value -= lightDecayRate
		
		if lightMeter.value <= 0.0:
			gameNode.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
			anim.play("GameOverLight")
			return
	
	fish.light.scale = Vector2(2.0,2.0) + (Vector2(0.03,.03) * lightMeter.value)

func on_blowhole_used() -> void:
	lightMeter.value -= 15 
	pass

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
		if Global.anger == 0:
			Global.redempCounter = Global.redempMax
	else:
		Global.anger += 1
		Global.redempCounter = 5
		if Global.anger >= 3:
			gameNode.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
			anim.play("GameOverAnger")
			return
		var newBoat = BOAT.instantiate()
		newBoat.global_position = fish.global_position
		newBoat.max_health += 1 if upgradeInv[Global.UPGRADES.STRONGERHULL] >= 1 else 0
		newBoat.health = newBoat.max_health
		owner.add_child(newBoat)
		
		boat = newBoat
	
	# creating new level assuming they will continue
	gameNode.layout.height += 1
	create_level()
	gameNode.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	upgrade_menu_control.show()
func create_level() -> void:
	lightMeter.value = lightMeterMax
	gameNode.layout._ready()
	gameNode.continuing = true
	
func _on_upgrade_menu_control_visibility_changed() -> void:
	await get_tree().create_timer(.1).timeout
	if upgrade_menu_control.visible:
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
			lightMeterMax += 25
			lightMeter.value = lightMeterMax
		Global.UPGRADES.LIGHTPOTENCY:
			maxLightScale += Vector2(.25,.25)
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
			fish.blowhole = true
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
	var cost_increase : int = 2 * upgradeInv[prevMiddle.frame]
	%BoatsSaved.text = str(Global.boats)
	%Money.text = str(Global.money)
	match prevMiddle.frame:
		Global.UPGRADES.LIGHTCAPACITY,Global.UPGRADES.LIGHTPOTENCY,Global.UPGRADES.LIGHTPRESERVER:
			cost.text = str(5 + cost_increase)
		Global.UPGRADES.MOVESPEED,Global.UPGRADES.STRONGERHULL,Global.UPGRADES.BLOWHOLE:
			cost.text = str(15 + cost_increase)
	
	var text : String
	match prevMiddle.frame:
		Global.UPGRADES.LIGHTCAPACITY:
			text = "[b]LIGHT CAPACITY -[/b] Increases the max amount of light the spirit can hold at a time."
		Global.UPGRADES.LIGHTPOTENCY:
			text = "[b]LIGHT POTENCY -[/b] Increases the brightness of the spirit's light and light gained per spark."
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
	
	angerMeter.value = Global.anger

func _on_continue_pressed() -> void:
	# new level created once player reaches end
	anim.play("ShopToGame")
	await anim.animation_finished
	upgrade_menu_control.hide()
	upgrade_menu_control.modulate.a8 = 255
	_on_new_game_pressed()

# Lose MENUS
func _on_quit_title_anger_pressed() -> void:
	angerLose.hide()
	main_menu_control.show()

func _on_quit_title_light_pressed() -> void:
	lightLose.hide()
	main_menu_control.show()

func _on_new_game_anger_pressed() -> void:
	angerLose.hide()
	Global.money = 0
	Global.boats = 0
	Global.anger = 0
	Global.redempCounter = 5
	Global.redempMax = 5
	gameNode.layout.height = 20
	create_level()
	main_menu_control.show()

func _on_new_game_light_pressed() -> void:
	lightLose.hide()
	Global.money = 0
	Global.boats = 0
	Global.anger = 0
	Global.redempCounter = 5
	Global.redempMax = 5
	gameNode.layout.height = 20
	create_level()
	main_menu_control.show()

# Pause Menu/ Saves
func _on_save_pressed() -> void:
	Global.save()

func _on_load_pressed() -> void:
	Global._load()

func _input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		gameNode.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		%Pause.show()

func _on_resume_pressed() -> void:
	gameNode.process_mode = Node.PROCESS_MODE_PAUSABLE
	%Pause.hide()
	

func _on_settings_pressed() -> void:
	pass

func _on_quit_pause_pressed() -> void:
	get_tree().quit()
