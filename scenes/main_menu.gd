extends Control

@onready var game = $"../.."
@onready var game_length_info = $LengthPanel/LengthInfo
@onready var game_length_slider = $LengthPanel/LengthSlider
@onready var scroll_sound_timer = $LengthPanel/ScrollSoundTimer
@onready var new_info_hint_panel = $NewInfoHintPanel

@export var slider_multiplier: float = 5


func _ready():
	Engine.time_scale = 1
	CurrentGameSettings.reset_settings()
	update_setting_display()


func _on_start_pressed():
	var death_barrier_height = -((game_length_slider.value - 100) * slider_multiplier) + 133
	game.start_game(death_barrier_height)


func _on_info_pressed():
	game.open_info()


func _on_exit_pressed():
	play_menu_click_release()
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()


func _on_settings_button_pressed():
	game.open_settings()


func _on_length_slider_value_changed(value):
	if not game.audio_players["scroll_player"][0].is_playing():
		game.audio_players["scroll_player"][0].play()
	scroll_sound_timer.start()
	game_length_info.text = ("Length of Game: " + var_to_str(value).replace(".0", "") + "%")
	await scroll_sound_timer.timeout
	game.audio_players["scroll_player"][0].stop()

#region Sound Players
func play_menu_click_click():
	game.audio_players["menu_click_player"][0].play()


func play_menu_click_release():
	game.audio_players["menu_release_player"][0].play()


func play_action_click_click():
	game.audio_players["action_click_player"][0].play()


func play_action_click_release():
	game.audio_players["action_release_player"][0].play()
#endregion

func _on_cluster_grape_mania_checkbox_toggled(toggled_on):
	$FineTuneOptionsPanel/EnableClusterGrapes.visible = !toggled_on
	$FineTuneOptionsPanel/EnableClusterGrapesInfo.visible = !toggled_on
	CurrentGameSettings.current_game_settings["cluster_grape_mania_on"] = toggled_on
	if toggled_on:
		CurrentGameSettings.current_game_settings["cluster_grapes_enabled"] = true
	else:
		CurrentGameSettings.current_game_settings["cluster_grapes_enabled"] = $FineTuneOptionsPanel/EnableClusterGrapes.button_pressed


func _on_sky_high_mode_checkbox_toggled(toggled_on):
	if toggled_on:
		$LengthPanel.visible = false
	else:
		$LengthPanel.visible = true
	CurrentGameSettings.current_game_settings["sky_high_mode_on"] = toggled_on


func _on_enable_cluster_grapes_toggled(toggled_on):
	$GameOptionsMenu/ClusterGrapeManiaCheckbox.visible = toggled_on
	$GameOptionsMenu/ClusterGrapeManiaInfo.visible = toggled_on
	if toggled_on:
		CurrentGameSettings.current_game_settings["cluster_grape_mania_on"] = $GameOptionsMenu/ClusterGrapeManiaCheckbox.button_pressed
		$FineTuneOptionsPanel/EnableClusterGrapesInfo.text = "Cluster Grapes - Enabled"
	else:
		CurrentGameSettings.current_game_settings["cluster_grape_mania_on"] = false
		$FineTuneOptionsPanel/EnableClusterGrapesInfo.text = "Cluster Grapes - Disabled"
	CurrentGameSettings.current_game_settings["cluster_grapes_enabled"] = toggled_on


func _on_enable_cherry_bombs_toggled(toggled_on):
	if toggled_on:
		$FineTuneOptionsPanel/EnableCherryBombsInfo.text = "Cherry Bombs - Enabled"
	else:
		$FineTuneOptionsPanel/EnableCherryBombsInfo.text = "Cherry Bombs - Disabled"
	CurrentGameSettings.current_game_settings["cherry_bombs_enabled"] = toggled_on


func _on_close_new_info_hint_panel_button_pressed():
	game.new_info_hint_dismissed = true
	new_info_hint_panel.visible = false


func update_setting_display():
	game_length_slider.value = 100
	$GameOptionsMenu/ClusterGrapeManiaCheckbox.button_pressed = CurrentGameSettings.current_game_settings["cluster_grape_mania_on"]
	$GameOptionsMenu/SkyHighModeCheckbox.button_pressed = CurrentGameSettings.current_game_settings["sky_high_mode_on"]
	$FineTuneOptionsPanel/EnableClusterGrapes.button_pressed = CurrentGameSettings.current_game_settings["cluster_grapes_enabled"]
	$FineTuneOptionsPanel/EnableCherryBombs.button_pressed = CurrentGameSettings.current_game_settings["cherry_bombs_enabled"]


func _on_stats_button_pressed():
	game.open_stats()


func _on_quests_button_pressed():
	game.open_quests()


