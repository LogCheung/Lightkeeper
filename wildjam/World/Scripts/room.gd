extends Node2D
class_name Room

static var xDim : int = 20
static  var yDim : int = 20

@export var gridPos : Vector2
@onready var tile: TileMapLayer = $TileMapLayer

func _ready() -> void:
	for x in xDim:
		for y in yDim:
			tile.set_cell(Vector2(x,y),0,Vector2(0,0))

static func get_room_size() -> Vector2:
	return Vector2(xDim,yDim)
