extends Control

@onready var game = $"../.."
@onready var score_label = $ScoreLabel
@onready var coins_label = $CoinsLabel

var pressed = false

func _ready():
	score_label.text = ("Score: " + var_to_str(game.current_score))
	coins_label.text = ("Coins: " + var_to_str(game.current_coins))

func _on_main_menu_button_pressed():
	if not pressed:
		pressed = true
		game.open_menu_from_game_over()


func _on_quit_button_pressed():
	get_tree().quit()


func play_menu_click_click():
	game.audio_players["menu_click_player"][0].play()


func play_menu_click_release():
	game.audio_players["menu_release_player"][0].play()


