extends Control

@onready var game = $"../.."

func _on_unpause_button_pressed():
	game.unpause()


func _on_menu_button_pressed():
	game.open_menu_from_pause()


func _input(event):
	if event.is_action_pressed("pause"):
		game.unpause()


func play_menu_click_click():
	game.audio_players["menu_click_player"][0].play()


func play_menu_click_release():
	game.audio_players["menu_release_player"][0].play()


