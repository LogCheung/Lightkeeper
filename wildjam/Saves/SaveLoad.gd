extends Node

const save_location = "user://Saves/SaveFile.tres"

var SaveFileData : SaveDataResource = SaveDataResource.new()

func _save(scene : PackedScene):
	# Save global values
	SaveFileData.money = Global.money
	SaveFileData.boats = Global.boats
	SaveFileData.anger = Global.anger
	SaveFileData.nights = Global.nights
	SaveFileData.redempCounter = Global.redempCounter
	SaveFileData.upgradeInv = Global.upgradeInv.duplicate()
	
	SaveFileData.gameScene = scene
	
	ResourceSaver.save(SaveFileData,save_location)
	
func _load() :
	if FileAccess.file_exists(save_location):
		SaveFileData = ResourceLoader.load(save_location).duplicate(true)
		
		Global.money = SaveFileData.money
		Global.boats = SaveFileData.boats
		Global.anger = SaveFileData.anger
		Global.nights = SaveFileData.nights
		Global.redempCounter = SaveFileData.redempCounter
		Global.upgradeInv = SaveFileData.upgradeInv.duplicate()
	
		get_tree().change_scene_to_packed(SaveFileData.gameScene)
