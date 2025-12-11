extends CharacterBody2D
class_name Fish

const BULLET = preload("res://Player/Scenes/bullet.tscn")

@export var SPEED : float = 120
@export var CAMSPEED : float = 75
@export var extraSpeed : float = 50
@export var currentRoom : Room
@export var currentDirection : Room.DIRECTION
@export var blowhole : bool

@onready var box: Area2D = $Box
@onready var onScreen: VisibleOnScreenNotifier2D = $OnScreen
@onready var light: PointLight2D = $PointLight2D
@onready var anim: AnimationPlayer = $AnimationPlayer

signal center_reached
signal blowhole_used
signal light_collected
signal new_night

var boat
var cameraMan : CharacterBody2D
var using_blowhole : bool = false

func _ready() -> void:
	new_night.connect(on_new_night)
	center_reached.connect(switch_direction)
	boat = get_tree().get_first_node_in_group("BOAT")
	cameraMan = get_tree().get_first_node_in_group("CAMERAMAN")

func _process(delta: float) -> void:
	if !box.get_overlapping_areas().is_empty():
		currentRoom = box.get_overlapping_areas().front().owner
	else:
		print(box.get_overlapping_areas())
	if !currentRoom:
		return
	currentRoom.player_entered.emit()
	var input_vector = Vector2.RIGHT
	match currentDirection:
		Room.DIRECTION.UP:
			cameraMan.velocity = Vector2.UP * CAMSPEED
		Room.DIRECTION.LEFT:
			cameraMan.velocity = Vector2.LEFT * CAMSPEED
		Room.DIRECTION.RIGHT:
			cameraMan.velocity = Vector2.RIGHT * CAMSPEED
	cameraMan.move_and_slide()
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	
	var angle = rad_to_deg(global_position.angle_to_point(global_position + input_vector * SPEED))
	rotation_degrees =angle
	
	input_vector = input_vector.normalized()
	velocity = input_vector * SPEED
	catch_light()
	move_and_slide()
	
	if !using_blowhole:
		if blowhole:
			anim.play("upgraded")
		else:
			anim.play("normal")
	
func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept") and blowhole and %BlowholeCD.time_left <= 0:
		anim.play("blowhole")
		using_blowhole = true
		var bullet = BULLET.instantiate()
		bullet.rotation = rotation
		bullet.global_position = global_position
		get_parent().add_child(bullet)
		blowhole_used.emit()
		%BlowholeCD.start()
		
		
func switch_direction() -> void:
	if !currentRoom:
		return
	currentDirection = currentRoom.nextDirection

func blowhole_finished() -> void:
	using_blowhole = false

func catch_light() -> void:
	var cell = currentRoom.tile.local_to_map(global_position - currentRoom.global_position)
	var lightCells = currentRoom.tile.get_used_cells_by_id(1,Vector2(0,15))
	lightCells.append_array(currentRoom.tile.get_used_cells_by_id(1,Vector2(0,16)))
	lightCells.append_array(currentRoom.tile.get_used_cells_by_id(1,Vector2(0,17)))
	lightCells.append_array(currentRoom.tile.get_used_cells_by_id(1,Vector2(0,18)))
	if lightCells.has(cell):
		# changes are made in the ui script
		light_collected.emit()
		currentRoom.tile.set_cell(cell,-1)
	pass

func on_new_night() -> void:
	if Global.nights < 3:
		SPEED = 125
		CAMSPEED = 85
	elif Global.nights < 6:
		SPEED = 140
		CAMSPEED = 100
	elif Global.nights > 6:
		SPEED = 155
		CAMSPEED = 115
	boat.SPEED = SPEED - 20
