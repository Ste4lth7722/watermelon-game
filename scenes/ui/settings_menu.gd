extends Control

@onready var game = $"../.."
@onready var resolution_dropdown = $ResolutionDropdown
@onready var fullscreen_check_box = $FullscreenCheckBox
@onready var volume_slider = $VolumePanel/VolumeSlider
@onready var scroll_sound_timer = $ScrollSoundTimer
@onready var volume_info = $VolumePanel/VolumeInfo

@onready var master_bus = AudioServer.get_bus_index("Master")

var play_scroll_sounds: bool = false

var pending_settings = {
	"volume": Settings.settings_list["volume"],
	"mute": Settings.settings_list["mute"],
	"resolution_index": Settings.settings_list["resolution_index"],
	"resolution": Settings.settings_list["resolution"],
	"fullscreen": Settings.settings_list["fullscreen"]
}

func _ready():
	resolution_dropdown.selected = pending_settings["resolution_index"]
	fullscreen_check_box.button_pressed = pending_settings["fullscreen"]
	if fullscreen_check_box.button_pressed == true:
		resolution_dropdown.visible = false
	volume_slider.value = pending_settings["volume"]
	enable_scroll_sounds()


func enable_scroll_sounds():
	await get_tree().create_timer(0.01).timeout
	play_scroll_sounds = true


func _on_exit_button_pressed():
	AudioServer.set_bus_mute(master_bus, Settings.settings_list["mute"])
	AudioServer.set_bus_volume_db(master_bus, Settings.settings_list["volume"])
	game.close_settings()


func _on_resolution_dropdown_item_selected(index):
	play_action_click_release()
	match index:
		0:
			pending_settings["resolution_index"] = 0
			pending_settings["resolution"] = Vector2(1152,648)
		1:
			pending_settings["resolution_index"] = 1
			pending_settings["resolution"] = Vector2(1920, 1080)
		2:
			pending_settings["resolution_index"] = 2
			pending_settings["resolution"] = Vector2(2560, 1440)


func _on_fullscreen_check_box_toggled(toggled_on):
	if toggled_on:
		resolution_dropdown.visible = false
	else:
		resolution_dropdown.visible = true
	pending_settings["fullscreen"] = toggled_on


func _on_confirm_settings_button_pressed():
	update_settings_values()
	apply_resolution_settings()
	apply_volume_settings()


func update_settings_values():
	for setting in Settings.settings_list.keys():
		Settings.settings_list[setting] = pending_settings[setting]


func apply_resolution_settings():
	DisplayServer.window_set_size(Settings.settings_list["resolution"])
	if Settings.settings_list["fullscreen"] == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func apply_volume_settings():
	Settings.settings_list["volume"] = pending_settings["volume"]


func _on_volume_slider_value_changed(value):
	if value <= volume_slider.min_value:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
	pending_settings["volume"] = value
	AudioServer.set_bus_volume_db(master_bus, value)
	if not game.audio_players["scroll_player"][0].is_playing() and play_scroll_sounds:
		game.audio_players["scroll_player"][0].play()
	scroll_sound_timer.start()
	volume_info.text = (var_to_str((value - volume_slider.min_value) * (100 / (volume_slider.max_value - volume_slider.min_value))).replace(".0", "") + "% Volume")
	volume_info.position.x = 12 + (volume_slider.size.x * ((value - volume_slider.min_value) / (volume_slider.max_value - volume_slider.min_value)) - (volume_info.size.x * (((value - volume_slider.min_value)) / (volume_slider.max_value - volume_slider.min_value))))
	await scroll_sound_timer.timeout
	game.audio_players["scroll_player"][0].stop()


#region Menu sounds
func play_menu_click_click():
	game.audio_players["menu_click_player"][0].play()


func play_menu_click_release():
	game.audio_players["menu_release_player"][0].play()


func play_action_click_click():
	game.audio_players["action_click_player"][0].play()



func play_action_click_release():
	game.audio_players["action_release_player"][0].play()
#endregion


