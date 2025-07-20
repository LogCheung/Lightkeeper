extends Area2D
class_name Projectile

enum DIR {
	BULLET, DOWN, LEFT, RIGHT, UP
}

@export var type : DIR
@export var SPEED : float = 100
@export var RANGE : float = 150
@export var active : bool

@onready var sprite: Sprite2D = %Sprite2D
@onready var colShape: CollisionShape2D = %CollisionShape2D

var dir : Vector2 = Vector2.DOWN
var fish : Fish

func _ready() -> void:
	await get_tree().create_timer(.2).timeout
	fish = get_tree().get_first_node_in_group("FISH")
	match type:
		DIR.BULLET:
			sprite.frame = 1
			RANGE = 100
			dir = global_position.direction_to(fish.global_position)
		DIR.DOWN, DIR.UP:
			sprite.frame = 2
			dir = Vector2.DOWN if type == DIR.DOWN else Vector2.UP
		DIR.LEFT:
			sprite.frame = 0
			dir = Vector2.LEFT
		DIR.RIGHT:
			sprite.frame = 0
			sprite.flip_h = true
			dir = Vector2.RIGHT
	
var travelled_distance = 0

func _process(delta: float) -> void:
	if !active:
		return
	if type == DIR.BULLET:
		dir = global_position.direction_to(fish.global_position)
	position += dir * SPEED * delta
	travelled_distance += SPEED * delta
	
	if travelled_distance > RANGE:
		queue_free()
