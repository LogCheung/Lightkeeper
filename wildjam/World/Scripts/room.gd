extends Node2D
class_name Room

const STANDARDEASY = preload("res://TileSet/Resources/StandardEasy.tres")
const STANDARDMED = preload("res://TileSet/Resources/StandardMedium.tres")
const STANDARDHARD = preload("res://TileSet/Resources/StandardHard.tres")
const CORNEREASY = preload("res://TileSet/Resources/CornerEasy.tres")
const CORNERDMED = preload("res://TileSet/Resources/CornerMed.tres")
const CORNERHARD = preload("res://TileSet/Resources/CornerHard.tres")

enum DIRECTION {UP, LEFT, RIGHT}

static var xDim : int = 20
static var yDim : int = 20

@export var gridPos : Vector2
@export var nextRoom : Room
@export var is_corner : bool
@export var is_end : bool
@export var is_start : bool
@export var is_side : bool
@export var nextDirection : DIRECTION

@onready var tile: TileMapLayer = $TileMapLayer
@onready var shape: CollisionShape2D = %CollisionShape2D

var topLeft : Vector2
var botRight : Vector2
var botLeft : Vector2
var topRight : Vector2
var center : Vector2
var fish : Fish
var rayCast

var usedTiles : Array
signal clear_to_start

func _ready() -> void:
	await clear_to_start
	fish = get_tree().get_first_node_in_group("FISH")
	var tSize = tile.tile_set.tile_size
	for x in xDim:
		for y in yDim:
			usedTiles.append(tile.map_to_local(Vector2(x,y) + (global_position/Vector2(tSize))))
			#tile.set_cell(Vector2(x,y),1,Vector2(0,1))
	#tile.set_pattern(Vector2(0,0),tile.tile_set.get_pattern(0))
	
	topLeft = global_position
	topRight = global_position + Vector2(xDim,0) * Vector2(tSize)
	botRight = global_position + Vector2(xDim,yDim) * Vector2(tSize)
	botLeft = global_position + Vector2(0,yDim) * Vector2(tSize)
	center = global_position + Vector2(xDim/2,yDim/2) * Vector2(tSize)
	
	shape.shape.size = tile.get_used_rect().size * tile.tile_set.tile_size
	shape.position = tile.get_used_rect().get_center() * tile.tile_set.tile_size
	
	if nextRoom:
		if nextRoom.gridPos.x < gridPos.x:
			nextDirection = DIRECTION.LEFT
		elif nextRoom.gridPos.x > gridPos.x:
			nextDirection = DIRECTION.RIGHT
		else:
			nextDirection = DIRECTION.UP

	if is_corner:
		var ray = RayCast2D.new()
		ray.set_collision_mask_value(1,false)
		ray.set_collision_mask_value(5,true)
		if nextDirection == DIRECTION.UP:
			ray.position = Vector2(xDim/2,0) * Vector2(tSize)
			ray.target_position = Vector2(0,yDim) * Vector2(tSize)
		else:
			ray.position = Vector2(xDim,yDim/2) * Vector2(tSize)
			ray.rotation_degrees = 90
			ray.target_position = Vector2(0,yDim) * Vector2(tSize)
		add_child(ray)
	rayCast = get_children().filter(func(element):return element is RayCast2D)
	rayCast = rayCast.front() if !rayCast.is_empty() else null
	
func _process(delta: float) -> void:
	if !rayCast:
		return
	if rayCast.get_collider() != null:
		
		if is_end:
			var ui = get_tree().get_first_node_in_group("MAINUI")
			ui.end_reached.emit()
			Global.boats += 1
			Global.money += 50
			
		fish.center_reached.emit()
		pass

static func get_room_size() -> Vector2:
	return Vector2(xDim,yDim)
