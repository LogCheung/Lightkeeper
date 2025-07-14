extends Node2D

const ROOM = preload("res://World/room.tscn")

@onready var layout: TileMapLayer = %Layout
@onready var roomsNode: Node2D = $RoomsNode

func create_rooms() -> void:
	var usedCells = layout.get_used_cells()
	var roomSize = Room.get_room_size()
	for cell in usedCells:
		var room = ROOM.instantiate()
		room.gridPos = cell
		
		room.global_position = Vector2(cell) * roomSize * Vector2(16,16)
		roomsNode.add_child(room)
