extends CharacterBody2D
class_name Fish

const BULLET = preload("res://Player/Scenes/bullet.tscn")

@export var SPEED : float = 200.0
@export var CAMSPEED : float = 100
@export var extraSpeed : float = 50
@export var currentRoom : Room
@export var currentDirection : Room.DIRECTION
@export var blowhole : bool

@onready var box: Area2D = $Box
@onready var onScreen: VisibleOnScreenNotifier2D = $OnScreen
@onready var light: PointLight2D = $PointLight2D

signal center_reached
signal blowhole_used

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
	rotation_degrees =angle# rad_to_deg(velocity.angle())
	
	input_vector = input_vector.normalized()
	velocity = input_vector * SPEED
	move_and_slide()
func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept") and blowhole and %BlowholeCD.time_left <= 0:
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
