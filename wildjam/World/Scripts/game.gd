extends Node2D

const ROOM = preload("res://World/room.tscn")

@onready var layout: TileMapLayer = %Layout
@onready var roomsNode: Node2D = %RoomsNode
@onready var colShapesNode: Node2D = %ColShapesNode

var fish : Fish
func _ready() -> void:
	await ready
	#get_window().content_scale_size = DisplayServer.window_get_size() / Vector2i(6,3)
	fish = get_tree().get_first_node_in_group("FISH")

func create_rooms(cornerArray : Array, endPos : Vector2) -> void:
	var usedCells = layout.get_used_cells()
	var roomSize = Room.get_room_size()
	var prevRoom : Room = null
	var cornerRoomArray : Array[Room]
	
	for cell in usedCells:
		var room = ROOM.instantiate()
		room.gridPos = cell
		if cornerArray.has(Vector2(cell)):
			room.is_corner = true
			room.is_end = true if endPos == Vector2(cell) else false
			cornerRoomArray.append(room)
		
		room.global_position = Vector2(cell) * roomSize * Vector2(16,16)
		roomsNode.add_child(room)
		
		if prevRoom == null: # is starting room
			prevRoom = room
			prevRoom.clear_to_start.emit()
		else:
			prevRoom.nextRoom = room
			prevRoom.clear_to_start.emit()
			prevRoom = room
	prevRoom.clear_to_start.emit()
	create_limit_polygon(cornerRoomArray)
	fish.global_position = cornerRoomArray.front().center
	%Camera.global_position = cornerRoomArray.front().center

func create_limit_polygon(corRoomArray : Array[Room]) -> void:
	for i in range(corRoomArray.size() - 1):
		var limPoints : Array = []
		var curRoom = corRoomArray[i]
		var nextRoom = corRoomArray[i+1] # next corner not just next room
		if nextRoom.global_position.x < curRoom.global_position.x:
			limPoints.append(curRoom.topRight)
			limPoints.append(nextRoom.topLeft)
			limPoints.append(nextRoom.botLeft)
			limPoints.append(curRoom.botRight)
		elif nextRoom.global_position.x > curRoom.global_position.x:
			limPoints.append(curRoom.topLeft)
			limPoints.append(nextRoom.topRight)
			limPoints.append(nextRoom.botRight)
			limPoints.append(curRoom.botLeft)
		else:
			limPoints.append(curRoom.botLeft)
			limPoints.append(nextRoom.topLeft)
			limPoints.append(nextRoom.topRight)
			limPoints.append(curRoom.botRight)
		
		var area = Area2D.new()
		var colShape = CollisionShape2D.new()
		var shape = ConvexPolygonShape2D.new()
		shape.points = limPoints
		colShape.shape = shape
		area.add_child(colShape)
		area.collision_layer = 0
		area.collision_mask = 1
		colShapesNode.add_child(area)
	
	var limShapes = colShapesNode.get_children()
	for area : Area2D in limShapes:
		area.body_entered.connect(area_entered.bind(area))
	%PhanCam.set_limit_target(limShapes.front().get_children().front().get_path())
	
	
func area_entered(body : Node2D, area : Area2D) -> void:
	await fish.center_reached
	if body.is_in_group("CAMERAMAN"):
		%PhanCam.set_limit_target(area.get_children().front().get_path())
