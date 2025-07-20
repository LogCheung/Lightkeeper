extends Area2D
class_name Projectile

enum DIR {
	BULLET, DOWN, LEFT, RIGHT, UP
}

@export var type : DIR
@export var SPEED : float = 75
@export var RANGE : float = 150
@export var active : bool

@onready var sprite: Sprite2D = %Sprite2D
@onready var colShape: CollisionShape2D = %CollisionShape2D
@onready var sound: AudioStreamPlayer2D = $Wave
@onready var player_hit: AudioStreamPlayer2D = $PlayerHit

var dir : Vector2 = Vector2.DOWN
var fish : Fish

func _ready() -> void:
	await get_tree().create_timer(.2).timeout
	fish = get_tree().get_first_node_in_group("FISH")
	match type:
		DIR.BULLET:
			sprite.frame = 1
			RANGE = 75
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
var played : bool = false
func _process(delta: float) -> void:
	if !active:
		return
	if !played:
		sound.play()
		played = true
	if type == DIR.BULLET:
		dir = global_position.direction_to(fish.global_position)
	position += dir * SPEED * delta
	travelled_distance += SPEED * delta
	
	if travelled_distance > RANGE:
		queue_free()
	
	if !get_overlapping_bodies().is_empty():
		if get_overlapping_bodies().front() is Fish:
			var ui = get_tree().get_first_node_in_group("MAINUI")
			ui.lightMeter.value -= 10
			player_hit.play()
			queue_free()
		if get_overlapping_bodies().front() is Boat:
			get_overlapping_bodies().front().health -= 1
			queue_free()
