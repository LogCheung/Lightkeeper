extends CharacterBody2D
class_name Fish

@export var SPEED : float = 250.0
@export var currentRoom : Room

@onready var box: Area2D = $Box

signal center_reached

func _process(delta: float) -> void:
	var input_vector = Vector2.RIGHT
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	velocity = input_vector * SPEED
	move_and_slide()
	
	if !box.get_overlapping_areas().is_empty():
		currentRoom = box.get_overlapping_areas().front().owner
	#if currentRoom and global_position.distance_to(currentRoom.center) < 10:
		#if currentRoom.is_corner:
			#center_reached.emit()
