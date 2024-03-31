extends Control

@onready var game = $"../.."

func _on_start_pressed():
	game.start_game()


func _on_exit_pressed():
	get_tree().quit()
