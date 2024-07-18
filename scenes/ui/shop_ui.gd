extends Control

@onready var playing_scene_ui = $".."
@onready var game = $"../../.."


func play_action_click():
	playing_scene_ui.play_menu_click_click()


func play_action_release():
	playing_scene_ui.play_menu_click_release()


func _on_close_shop_pressed():
	playing_scene_ui.toggle_shop()


func _on_save_fruit_pressed():
	if game.current_coins >= 10:
		game.remove_coins(10)
		game.playing_scene.save_fruit()


func _on_throw_fruit_pressed():
	if game.current_coins >= 100:
		game.remove_coins(100)
		game.playing_scene.prepare_fruit_throw()


