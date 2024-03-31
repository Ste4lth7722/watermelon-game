extends Control

@onready var game = $"../.."

func _on_unpause_button_pressed():
	game.unpause()


func _on_menu_button_pressed():
	game.open_menu()


func _input(event):
	if event.is_action_pressed("pause"):
		game.unpause()
