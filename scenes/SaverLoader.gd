class_name SaverLoader
extends Node


func save_game():
	var file = FileAccess.open("user://savegame.data", FileAccess.WRITE)
	file.store_var(GlobalStats.fruit_merges)
	file.close()


func load_game():
	var file = FileAccess.open("user://savegame.data", FileAccess.READ)
	if file != null:
		GlobalStats.fruit_merges = file.get_var()
		file.close()
	else:
		save_game()


