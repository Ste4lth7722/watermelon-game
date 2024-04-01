extends Control

@onready var game = $"../.."

func _on_exit_pressed():
	game.close_info()
