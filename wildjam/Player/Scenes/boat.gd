extends CharacterBody2D
class_name Boat

@export var SPEED : float = 200
@export var health : int = 2
@export var max_health : int = 2

var fish : CharacterBody2D

func _ready() -> void:
	fish = get_tree().get_first_node_in_group("FISH")

func _process(delta: float) -> void:
	if health <= 0:
		queue_free()
	if !fish:
		fish = get_tree().get_first_node_in_group("FISH")
		return
	
	if global_position.distance_to(fish.global_position) < 32:
		return
	velocity = global_position.direction_to(fish.global_position) * SPEED
	var angle = rad_to_deg(global_position.angle_to_point(global_position + velocity))
	rotation_degrees =angle
	move_and_slide()
