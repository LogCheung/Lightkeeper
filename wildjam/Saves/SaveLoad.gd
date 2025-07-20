extends Node

const save_location = "res://Saves/SaveFile.tres"

var SaveFileData : SaveDataResource = SaveDataResource.new()

func save(saveScene : PackedScene):
	SaveFileData.scene = saveScene
	ResourceSaver.save(SaveFileData,save_location)
	
func _load() :
	if FileAccess.file_exists(save_location):
		SaveFileData = ResourceLoader.load(save_location).duplicate(true)
	get_tree().change_scene_to_packed(SaveFileData.scene)
