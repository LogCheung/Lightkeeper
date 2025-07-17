extends CharacterBody2D

@export var SPEED : float = 200

var fish : CharacterBody2D

func _ready() -> void:
	fish = get_tree().get_first_node_in_group("FISH")

func _process(delta: float) -> void:
	if !fish:
		fish = get_tree().get_first_node_in_group("FISH")
		return
	
	if global_position.distance_to(fish.global_position) < 32:
		return
	velocity = global_position.direction_to(fish.global_position) * SPEED
	
	move_and_slide()
