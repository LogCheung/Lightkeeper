extends Node2D

const ROOM = preload("res://World/room.tscn")

@export var continuing : bool = false

@onready var layout: TileMapLayer = %Layout
@onready var roomsNode: Node2D = %RoomsNode
@onready var colShapesNode: Node2D = %ColShapesNode
@onready var walls: TileMapLayer = %Walls

var usedRoomTiles : Array
var fish : Fish
var wallTiles : Array

func _ready() -> void:
	await ready
	fish = get_tree().get_first_node_in_group("FISH")

func create_rooms(cornerArray : Array, endPos : Vector2,startPos : Vector2) -> void:
	for tile in usedRoomTiles:
		walls.set_cell(tile,0,Vector2(0,0))
	usedRoomTiles.clear()
	if continuing:
		for child in roomsNode.get_children():
			child.queue_free()
		for child in colShapesNode.get_children():
			child.queue_free()
	var usedCells = layout.get_used_cells()
	var roomSize = Room.get_room_size()
	var prevRoom : Room = null
	var cornerRoomArray : Array[Room]
	
	var roomCounter : int = 0
	for cell in usedCells:
		roomCounter += 1
		var room = ROOM.instantiate()
		room.gridPos = cell
		if cornerArray.has(Vector2(cell)):
			room.is_corner = true
			room.is_end = true if endPos == Vector2(cell) else false
			room.is_start = true if startPos == Vector2(cell) else false
			cornerRoomArray.append(room)
		
		# room difficulty
		var rand = randi() % 100 + 1
		if roomCounter % 2 == 0:
			room.type = Room.TYPE.LIGHT
		elif rand <= 45:
			room.type = Room.TYPE.EASY
		elif rand <= 80:
			room.type = Room.TYPE.MEDIUM
		elif rand <= 100:
			room.type = Room.TYPE.HARD
		
		room.global_position = Vector2(cell) * roomSize * Vector2(16,16)
		roomsNode.add_child(room)
		
		if room.is_end or room.is_start:
			room.type = Room.TYPE.NONE
		
		if prevRoom == null: # is starting room
			prevRoom = room
			prevRoom.clear_to_start.emit()
			usedRoomTiles.append_array(prevRoom.usedTiles)
		else:
			prevRoom.nextRoom = room
			prevRoom.clear_to_start.emit()
			usedRoomTiles.append_array(prevRoom.usedTiles)
			prevRoom = room
		
	prevRoom.clear_to_start.emit()
	usedRoomTiles.append_array(prevRoom.usedTiles)
	
	for tile in usedRoomTiles:
		walls.set_cell(tile,-1)
	
	cornerRoomArray = sort_corner_rooms(cornerRoomArray,cornerArray)
	create_limit_polygon(cornerRoomArray)
	fish.new_night.emit()
	fish.global_position = cornerRoomArray.front().center
	fish.boat.global_position = fish.global_position + Vector2(0,64)
	fish.boat.visible = true
	%Camera.global_position = cornerRoomArray.front().center

func sort_corner_rooms(corRoomArray : Array[Room], trueArray : Array) -> Array[Room]:
	var newArray : Array[Room] = []
	for pos in trueArray:
		for room : Room in corRoomArray:
			if room.gridPos == pos:
				newArray.append(room)
	return newArray

func create_limit_polygon(corRoomArray : Array[Room]) -> void:
	for child in colShapesNode.get_children():
		child.queue_free()
	for i in range(corRoomArray.size() - 1):
		var limPoints : Array = []
		var curRoom = corRoomArray[i]
		var nextRoom = corRoomArray[i+1] # next corner not just next room
		print(curRoom.gridPos)
		print(nextRoom.gridPos)
		print(" ")
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
	print("---------")
	
	var limShapes = colShapesNode.get_children()
	for area : Area2D in limShapes:
		if area.body_entered.is_connected(body_entered):
			continue
		area.body_entered.connect(body_entered.bind(area))
	%PhanCam.set_limit_target(limShapes.front().get_children().front().get_path())
	
	
func body_entered(body : Node2D, area : Area2D) -> void:
	await fish.center_reached
	if body.is_in_group("CAMERAMAN"):
		if is_instance_valid(area):
			%PhanCam.set_limit_target(area.get_children().front().get_path())
