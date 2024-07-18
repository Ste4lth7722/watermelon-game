extends Node2D

@onready var scene_container = $SceneContainer
@onready var control_container = $ControlContainer
@onready var background = $ControlContainer/Background
@onready var game_over_scene = preload("res://scenes/ui/game_over_screen.tscn")

#region Audio Players
@onready var audio_players = {
	"fruit_ready_player" = [$AudioPlayers/FruitSoundsNormal/FruitReadyPlayer],
	"fruit_drop_player" = [$AudioPlayers/FruitSoundsNormal/FruitDropPlayer],
	"fruit_merge_player" = [$AudioPlayers/FruitSoundsNormal/FruitMergePlayer],
	"cluster_grape_explode_player" = [$AudioPlayers/FruitSoundsSpecial/ClusterGrapeExplodePlayer],
	"cluster_cherry_explode_player" = [$AudioPlayers/FruitSoundsSpecial/ClusterCherryExplodePlayer],
	"cluster_strawberry_explode_player" = [$AudioPlayers/FruitSoundsSpecial/ClusterStrawberryExplodePlayer],
	"cherry_bomb_countdown_player" = [$"AudioPlayers/FruitSoundsSpecial/CherryBombCountdownPlayer"],
	"cherry_bomb_explosion_player" = [$"AudioPlayers/FruitSoundsSpecial/CherryBombExplosionPlayer"],
	"game_over_player" = [$AudioPlayers/UIPlayers/GameOverPlayer],
	"action_click_player" = [$AudioPlayers/UIPlayers/ActionClickPlayer],
	"action_release_player" = [$AudioPlayers/UIPlayers/ActionReleasePlayer],
	"menu_click_player" = [$AudioPlayers/UIPlayers/MenuClickPlayer],
	"menu_release_player" = [$AudioPlayers/UIPlayers/MenuReleasePlayer],
	"scroll_player" = [$AudioPlayers/UIPlayers/ScrollPlayer]
}
#endregion

@onready var saver_loader = $Utilities/SaverLoader

var new_info_hint_dismissed: bool = false
var spam_hint_dismissed: bool = false

var is_loading: bool = false
var pause_opened: bool = false

#region UI reference variables
var transition_layer: Node
var playing_scene: Node
var playing_scene_ui: Node
var info_ui: Node
var stats_ui: Node
var quests_ui: Node
var main_menu: Node
var settings_menu: Node
var pause_menu: Node
var game_over_screen: Node
#endregion

var current_score = 0
var current_coins = 0

var height_set_of_barrier


func _ready():
	get_tree().auto_accept_quit = false
	saver_loader.load_game()


func modify_score(amount: int):
	current_score += amount
	current_coins += amount
	var new_score_text = ("Score: " + var_to_str(current_score))
	var new_coins_text = ("Coins: " + var_to_str(current_coins))
	playing_scene_ui.score_label.text = new_score_text
	playing_scene_ui.coins_label.text = new_coins_text


func remove_coins(amount: int):
	current_coins -= amount
	var new_coins_text = ("Coins: " + var_to_str(current_coins))
	playing_scene_ui.coins_label.text = new_coins_text


func start_game(height_of_barrier: int):
	is_loading = true
	height_set_of_barrier = height_of_barrier
	var transition_layer_to_load = load("res://scenes/transition_layer.tscn").instantiate()
	control_container.add_child(transition_layer_to_load)
	transition_layer = transition_layer_to_load


func begin_loading():
	control_container.get_child(1).queue_free()
	var playing_scene_to_load = load("res://scenes/playing_scene/playing_scene.tscn").instantiate()
	scene_container.add_child(playing_scene_to_load)
	playing_scene = playing_scene_to_load
	playing_scene.set_death_barrier(height_set_of_barrier)
	#if CurrentGameSettings.current_game_settings["cluster_grape_mania_on"]:
	#	playing_scene.enable_cluster_grape_mania()
	if CurrentGameSettings.current_game_settings["sky_high_mode_on"]:
		playing_scene.enable_sky_high()
	if not CurrentGameSettings.current_game_settings["cluster_grapes_enabled"]:
		playing_scene.disable_cluster_grapes()
	if not CurrentGameSettings.current_game_settings["cherry_bombs_enabled"]:
		playing_scene.disable_cherry_bombs()
	
	var playing_scene_ui_to_load = load("res://scenes/playing_scene/playing_scene_ui.tscn").instantiate()
	control_container.add_child(playing_scene_ui_to_load)
	playing_scene_ui = playing_scene_ui_to_load
	playing_scene_ui.spam_hint_panel.visible = !spam_hint_dismissed


func finish_loading():
	transition_layer.queue_free()
	is_loading = false


func pause():
	if not pause_opened and not is_loading:
		pause_opened = false
		var pause_menu_to_load = load("res://scenes/pause_menu.tscn").instantiate()
		control_container.add_child(pause_menu_to_load)
		pause_menu = pause_menu_to_load
		if playing_scene != null:
			playing_scene.get_tree().paused = true


func unpause():
	if $ControlContainer/PauseMenu != null:
		$ControlContainer/PauseMenu.queue_free()
	# Below ensures that the game does not listen for input when escape is pressed to leave pause menu.
	await get_tree().create_timer(0.01).timeout
	get_tree().paused = false
	pause_opened = false

func open_menu_from_pause():
	pause_menu.queue_free()
	playing_scene.queue_free()
	playing_scene_ui.queue_free()
	var main_menu_to_load = load("res://scenes/main_menu.tscn").instantiate()
	control_container.add_child(main_menu_to_load)
	main_menu_to_load.new_info_hint_panel.visible = !new_info_hint_dismissed
	main_menu = main_menu_to_load
	get_tree().paused = false


func open_menu_from_game_over():
	playing_scene.queue_free()
	playing_scene_ui.queue_free()
	game_over_screen.queue_free()
	var main_menu_to_load = load("res://scenes/main_menu.tscn").instantiate()
	control_container.add_child(main_menu_to_load)
	main_menu_to_load.new_info_hint_panel.visible = !new_info_hint_dismissed
	main_menu = main_menu_to_load
	get_tree().paused = false


func update_camera_zoom():
	var vp_width = 0
	if Settings.fullscreen == true:
		vp_width = DisplayServer.screen_get_size().x
	else:
		vp_width = Settings.resolution.x
	var scale_factor_x = 1152 / vp_width
	$Camera2D.zoom = Vector2(scale_factor_x, scale_factor_x)


func open_info():
	var info_ui_to_load = load("res://scenes/ui/info.tscn").instantiate()
	control_container.add_child(info_ui_to_load)
	info_ui = info_ui_to_load


func open_stats():
	var stats_ui_to_load = load("res://scenes/ui/stats_menu.tscn").instantiate()
	control_container.add_child(stats_ui_to_load)
	stats_ui = stats_ui_to_load


func open_quests():
	var quests_ui_to_load = load("res://scenes/ui/quests.tscn").instantiate()
	control_container.add_child(quests_ui_to_load)
	quests_ui = quests_ui_to_load


func close_info():
	info_ui.queue_free()


func close_stats():
	stats_ui.queue_free()


func close_quests():
	quests_ui.queue_free()


func get_fruit_drop_pos():
	var pos_to_return: Vector2 = Vector2(0, 0)
	pos_to_return.x = playing_scene_ui.drop_indicator.global_position.x
	pos_to_return.y = playing_scene_ui.drop_indicator.global_position.y
	return pos_to_return


func show_game_over():
	#var game_over_screen_to_load = load("res://scenes/ui/game_over_screen.tscn").instantiate()
	var game_over_screen_to_load = game_over_scene.instantiate()
	control_container.add_child(game_over_screen_to_load)
	game_over_screen = game_over_screen_to_load


func open_settings():
	var settings_to_load = load("res://scenes/ui/settings_menu.tscn").instantiate()
	control_container.add_child(settings_to_load)
	settings_menu = settings_to_load


func close_settings():
	settings_menu.queue_free()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		saver_loader.save_game()
		get_tree().quit()


