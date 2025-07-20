extends Area2D

@export var SPEED : float
@export var RANGE : float

var travelled_distance = 0

func _process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		var cell = body.local_to_map(global_position - body.global_position)
		for x in range(cell.x-1,cell.x+2):
			for y in range(cell.y-1,cell.y+2):
				body.set_cell(Vector2(x,y),-1)
		queue_free()
