extends Node2D
class_name Room

const STANDARDEASY = preload("res://TileSet/Resources/StandardEasy.tres")
const STANDARDMED = preload("res://TileSet/Resources/StandardMedium.tres")
const STANDARDHARD = preload("res://TileSet/Resources/StandardHard.tres")
const LIGHTROOM = preload("res://TileSet/Resources/LightRoom.tres")
const PROJECTILE = preload("res://TileSet/Scenes/projectile.tscn")

enum DIRECTION {UP, LEFT, RIGHT}
enum TYPE {
	NONE, EASY, MEDIUM, HARD, LIGHT
}
static var xDim : int = 20
static var yDim : int = 20

@export var gridPos : Vector2
@export var nextRoom : Room
@export var is_corner : bool
@export var is_end : bool
@export var is_start : bool
@export var is_side : bool
@export var nextDirection : DIRECTION
@export var type : TYPE

@onready var tile: TileMapLayer = $Obstacles
@onready var back : TileMapLayer = $Background
@onready var shape: CollisionShape2D = %CollisionShape2D

var topLeft : Vector2
var botRight : Vector2
var botLeft : Vector2
var topRight : Vector2
var center : Vector2
var fish : Fish
var rayCast

var usedTiles : Array
var tSize : Vector2

signal clear_to_start
signal player_entered

func _ready() -> void:
	await clear_to_start
	fish = get_tree().get_first_node_in_group("FISH")
	tSize = tile.tile_set.tile_size
	
	# Set key positions
	topLeft = global_position
	topRight = global_position + Vector2(xDim,0) * Vector2(tSize)
	botRight = global_position + Vector2(xDim,yDim) * Vector2(tSize)
	botLeft = global_position + Vector2(0,yDim) * Vector2(tSize)
	center = global_position + Vector2(xDim/2,yDim/2) * Vector2(tSize)
	
	create_obstacles()
	# Set direction hitbox
	shape.shape.size = back.get_used_rect().size * tile.tile_set.tile_size
	shape.position = back.get_used_rect().get_center() * tile.tile_set.tile_size
	
	# Set direction
	if nextRoom:
		if nextRoom.gridPos.x < gridPos.x:
			nextDirection = DIRECTION.LEFT
		elif nextRoom.gridPos.x > gridPos.x:
			nextDirection = DIRECTION.RIGHT
		else:
			nextDirection = DIRECTION.UP
	create_corner_raycast()
	player_entered.connect(activate_projectiles)
	
func _process(delta: float) -> void:
	if !rayCast:
		return
	if rayCast.get_collider() != null:
		
		if is_end:
			var ui = get_tree().get_first_node_in_group("MAINUI")
			ui.end_reached.emit()
			
		fish.center_reached.emit()
		fish.currentDirection = nextDirection
		pass

func create_corner_raycast() -> void:
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

func create_obstacles() -> void:
	for x in xDim:
		for y in yDim:
			usedTiles.append(back.map_to_local(Vector2(x,y) + (global_position/Vector2(tSize))))
			if is_start:
				tile.set_cell(Vector2(x,y),1,Vector2(0,1),0)
	
	match type:
		TYPE.EASY:
			tile.tile_set = STANDARDEASY
		TYPE.MEDIUM:
			tile.tile_set = STANDARDMED
		TYPE.HARD:
			tile.tile_set = STANDARDHARD
		TYPE.LIGHT:
			tile.tile_set = LIGHTROOM
		TYPE.NONE:
			tile.tile_set = STANDARDEASY
			if is_end:
				tile.set_pattern(Vector2(0,5),tile.tile_set.get_pattern(10))
			return
	var rand = randi() % 10
	tile.set_pattern(Vector2(0,0),tile.tile_set.get_pattern(rand))
	create_projectiles()

func create_projectiles() -> void:
	if type == TYPE.EASY or type == TYPE.NONE:
		return
	var bullet = tile.get_used_cells_by_id(1,Vector2(0,1),1)
	var left = tile.get_used_cells_by_id(1,Vector2(0,1),2)
	var down = tile.get_used_cells_by_id(1,Vector2(0,1),3)
	var right = tile.get_used_cells_by_id(1,Vector2(0,1),4)
	var up = tile.get_used_cells_by_id(1,Vector2(0,1),5)
	
	projectile_helper(bullet,1)
	projectile_helper(left,2)
	projectile_helper(down,3)
	projectile_helper(right,4)
	projectile_helper(up,5)

func projectile_helper(tiles : Array,num : int) -> void:
	var dir : Projectile.DIR
	match num:
		1:
			dir = Projectile.DIR.BULLET
		2:
			dir = Projectile.DIR.LEFT
		3:
			dir = Projectile.DIR.DOWN
		4:
			dir = Projectile.DIR.RIGHT
		5:
			dir = Projectile.DIR.UP
	for cell in tiles:
		var proj = PROJECTILE.instantiate()
		proj.type = dir
		proj.global_position = tile.map_to_local(cell)
		%ProjectileNode.add_child(proj)

func activate_projectiles() -> void:
	var projs = %ProjectileNode.get_children()
	if projs.is_empty():
		return
	for proj : Projectile in projs:
		if proj.active:
			return
		proj.active = true

static func get_room_size() -> Vector2:
	return Vector2(xDim,yDim)
