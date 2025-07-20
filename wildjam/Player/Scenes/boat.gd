extends CharacterBody2D
class_name Boat

@export var SPEED : float = 200
@export var health : int = 3
@export var max_health : int = 3
@onready var anim: AnimationPlayer = $AnimationPlayer

var fish : CharacterBody2D

func _ready() -> void:
	anim.play("damage")
	fish = get_tree().get_first_node_in_group("FISH")

var break_played : bool = false

func _process(delta: float) -> void:
	if health <= 0 and !break_played:
		break_played = true
		$Break.play()
		await $Break.finished
		hide()
	if !fish:
		fish = get_tree().get_first_node_in_group("FISH")
		return
	
	if get_last_slide_collision() and visible:
		if get_last_slide_collision().get_collider() is TileMapLayer:
			health -= 1
			%CollisionShape2D.disabled = true
			$Damage.play()
			%HitboxCD.start()
			

	
	# match sprite
	match health:
		4:
			anim.play("Armor")
		3:
			anim.play("normal")
		2:
			anim.play("damage")
	
	if global_position.distance_to(fish.global_position) < 32:
		return
	velocity = global_position.direction_to(fish.global_position) * SPEED
	var angle = rad_to_deg(global_position.angle_to_point(global_position + velocity))
	rotation_degrees =angle
	move_and_slide()



func _on_hitbox_cd_timeout() -> void:
	%CollisionShape2D.disabled = false
