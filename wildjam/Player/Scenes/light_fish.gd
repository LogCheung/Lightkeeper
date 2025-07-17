extends CharacterBody2D
class_name Fish

@export var SPEED : float = 200.0
@export var CAMSPEED : float = 100
@export var extraSpeed : float = 50
@export var currentRoom : Room
@export var currentDirection : Room.DIRECTION

@onready var box: Area2D = $Box
@onready var onScreen: VisibleOnScreenNotifier2D = $OnScreen

signal center_reached

var boat
var cameraMan : CharacterBody2D

func _ready() -> void:
	center_reached.connect(switch_direction)
	boat = get_tree().get_first_node_in_group("BOAT")
	cameraMan = get_tree().get_first_node_in_group("CAMERAMAN")

func _process(delta: float) -> void:
	if !box.get_overlapping_areas().is_empty():
		currentRoom = box.get_overlapping_areas().front().owner
	if !currentRoom:
		return
	
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
	input_vector = input_vector.normalized()
	
	velocity = input_vector * SPEED
	move_and_slide()
func switch_direction() -> void:
	if !currentRoom:
		return
	currentDirection = currentRoom.nextDirection
	pass
