extends TileMapLayer

# max of around 30 rooms, approximately 20 for up, 10 for sides
@export var height : int = 20
var turns : int


func _ready() -> void:
	turns = height / 5
	for cell in get_used_cells():
		set_cell(cell,-1)
	var max_rooms = int(height * 1.5)
	var height_separation = height / turns
	var turn_length = max_rooms / 10
	
	var startPos = Vector2.ZERO
	var posArr : Array = [startPos]
	for i in range(turns - 1):
		var lastCorner = posArr[posArr.size()-1]
		if i == turns - 2:
			var endPos = lastCorner - Vector2(0,height_separation)
			posArr.append(endPos)
			continue
		var curCorner = Vector2(lastCorner.x, lastCorner.y - height_separation)
		var nextCorner = Vector2(lastCorner.x + rand_len(turn_length),curCorner.y)
		posArr.append(curCorner)
		posArr.append(nextCorner)

	draw_paths(posArr)
	for pos in posArr:
		if pos == posArr[posArr.size()-1] or pos == posArr[0]:
			set_cell(pos,0,Vector2i(0,0))
		else:
			set_cell(pos,0,Vector2i(2,0))
	await get_tree().create_timer(.1).timeout
	get_tree().get_first_node_in_group("GAMENODE").create_rooms(posArr,posArr[posArr.size()-1], posArr[0])

func rand_len(length : int) -> int:
	var dir : int = 1 if randi() % 2 == 0 else -1
	return (length + (randi() % 2) ) * dir

func draw_paths(positions : Array) -> void:
	for i in range(positions.size() - 1):
		connect_positions(positions[i],positions[i+1])

func connect_positions(start : Vector2, end : Vector2) -> void:
	var dirY = -1
	var dirX = 1 if start.x < end.x else -1
	for y in range(start.y,end.y,dirY):
		set_cell(Vector2(start.x,y),0,Vector2i(4,0))
	for x in range(start.x,end.x,dirX):
		set_cell(Vector2(x,end.y),0,Vector2i(4,0))
