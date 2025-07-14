extends CharacterBody2D

@export var SPEED : float = 250.0
@onready var cam: Camera2D = $Camera2D

func _process(delta: float) -> void:
	var input_vector = Vector2.RIGHT
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	velocity = input_vector * SPEED
	move_and_slide()
