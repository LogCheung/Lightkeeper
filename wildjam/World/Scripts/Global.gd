extends Node

var money : int = 10
var boats : int = 0
var anger : int = 0
var redempCounter : int = 5
var redempMax : int = 5

enum UPGRADES {
	LIGHTCAPACITY, LIGHTPOTENCY, LIGHTPRESERVER, MOVESPEED, STRONGERHULL,
	BLOWHOLE
}

#const save_location = "res://SaveFile.json"
#
#var contents_to_save : Dictionary = {
	#"save" : null
#}
#
#func save() -> void:
	#var saved_scene : PackedScene= PackedScene.new()
	#saved_scene.pack(get_tree().get_first_node_in_group("WORLD"))
	#contents_to_save["save"] = saved_scene
	#
	#var file = FileAccess.open(save_location,FileAccess.WRITE)
	#file.store_var(contents_to_save.duplicate())
	#file.close()
#
#func _load() -> void:
	#if FileAccess.file_exists(save_location):
		#var file = FileAccess.open(save_location,FileAccess.READ)
		#var data = file.get_var()
		#file.close()
		#
		#var save_data = data.duplicate()
		#contents_to_save.save = save_data.save
		#get_tree().change_scene_to_packed(save_data.save)
