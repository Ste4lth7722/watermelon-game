extends Control

@onready var game = $"../.."
@onready var info_container = $InfoContainer
@onready var info_page = $InfoContainer/BasicGameInfo

var info_page_names = {
	"0": "dev_notes",
	"1": "patch_notes",
	"2": "basic_info",
	"3": "special_fruits",
	"4": "special_modes"
}

func _on_exit_pressed():
	game.close_info()


func play_menu_click_click():
	game.audio_players["menu_click_player"][0].play()


func play_menu_click_release():
	game.audio_players["menu_release_player"][0].play()


func play_action_click_click(_junk_value):
	game.audio_players["action_click_player"][0].play()


func play_action_click_release(_junk_value):
	game.audio_players["action_release_player"][0].play()


func _on_tab_bar_tab_changed(tab):
	var info_page_path = ("res://scenes/ui/info_pages/" + var_to_str(info_page_names[var_to_str(tab)]) + ".tscn").replace('"', '')
	print(info_page_path)
	var info_page_to_load = load(info_page_path).instantiate()
	info_page.queue_free()
	info_container.add_child(info_page_to_load)
	info_page_to_load.anchors_preset = PRESET_FULL_RECT
	info_page = info_page_to_load



