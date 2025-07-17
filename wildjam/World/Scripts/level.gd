extends TileMapLayer

# max of around 30 rooms, approximately 20 for up, 10 for sides
@export var height : int = 20
@export var turns : int = 4


func _ready() -> void:
	var max_rooms = int(height * 1.5)
	var height_separation = height / turns
	var turn_length = max_rooms / 10
	
	var startPos = Vector2.ZERO
	# 1 2 3 4 5 6 7
	var cornerOnePos = Vector2(startPos.x, startPos.y - height_separation)
	var cornerTwoPos = Vector2(startPos.x + rand_len(turn_length), cornerOnePos.y)
	var cornerThreePos = Vector2(cornerTwoPos.x,cornerTwoPos.y - height_separation)
	var cornerFourPos = Vector2(cornerTwoPos.x + rand_len(turn_length), cornerThreePos.y)
	var cornerFivePos = Vector2(cornerFourPos.x,cornerFourPos.y - height_separation)
	var cornerSixPos = Vector2(cornerFourPos.x + rand_len(turn_length), cornerFivePos.y)
	var endPos  = cornerSixPos - Vector2(0,height_separation)
	
	var posArr : Array = [startPos,cornerOnePos,cornerTwoPos,cornerThreePos,cornerFourPos
	,cornerFivePos,cornerSixPos,endPos]
	
	draw_paths(posArr)
	for pos in posArr:
		if pos == startPos or pos == endPos:
			set_cell(pos,0,Vector2i(0,0))
		else:
			set_cell(pos,0,Vector2i(2,0))
	
	await get_tree().create_timer(.1).timeout
	get_tree().get_first_node_in_group("GAMENODE").create_rooms(posArr,endPos)

func rand_len(len : int) -> int:
	var dir : int = 1 if randi() % 2 == 0 else -1
	return (len + (randi() % 2) ) * dir

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
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
