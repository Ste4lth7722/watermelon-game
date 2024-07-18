extends Control

@onready var game = $"../.."


func _on_exit_pressed():
	game.close_quests()


func play_menu_click_click():
	game.audio_players["menu_click_player"][0].play()


func play_menu_click_release():
	game.audio_players["menu_release_player"][0].play()


func play_action_click_click():
	game.audio_players["action_click_player"][0].play()


func play_action_click_release():
	game.audio_players["action_release_player"][0].play()


