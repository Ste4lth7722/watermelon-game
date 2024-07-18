extends Control

@onready var game = $"../.."


func _ready():
	refresh_stats()


func play_menu_click_click():
	game.audio_players["menu_click_player"][0].play()


func play_menu_click_release():
	game.audio_players["menu_release_player"][0].play()


func refresh_stats():
	$StatsContainer/FruitMerges.text = ("Fruit Merges: " + var_to_str(GlobalStats.fruit_merges))


func _on_exit_button_pressed():
	game.close_stats()


