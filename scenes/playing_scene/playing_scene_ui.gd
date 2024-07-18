extends Control

#region UI REFERENCES
@onready var score_label = $StatsPanel/ScoreLabel
@onready var coins_label = $StatsPanel/CoinsLabel
@onready var game_over_timer = $GameOverTimer
@onready var game = $"../.."
@onready var drop_indicator = $DropIndicator
@onready var fruit_indicator_holder = $FruitIndicatorHolder
@onready var spam_hint_panel = $SpamHintPanel
@onready var fruit_wheel_panel = $FruitWheelPanel
@onready var open_wheel_panel = $OpenWheelPanelPanel/OpenWheelPanel
@onready var shop_ui = $ShopUI
@onready var fruit_throw_indicator = $DropIndicator/FruitThrowIndicator
#endregion

@onready var animation_player = $AnimationPlayer

signal saved_fruit_ready_animation_finished

var container_left_boundary: Vector2
var container_right_boundary: Vector2
# Fruit radii are modified in other scripts.
var next_fruit_radius: int = 20
var fruit_queue_radius: int = 20
var saved_fruit_radius: int

var shop_open = false


func _ready():
	animation_player.play("RESET")
	fruit_wheel_panel.visible = true 


func _physics_process(_delta):
	if not game.playing_scene.fruit_throw_ready:
		if get_global_mouse_position().x >= game.playing_scene.left_boundary_pos.x + next_fruit_radius and get_global_mouse_position().x <= game.playing_scene.right_boundary_pos.x - next_fruit_radius:
			drop_indicator.position.x = get_global_mouse_position().x
		else:
			if get_global_mouse_position().x < game.playing_scene.left_boundary_pos.x + next_fruit_radius:
				drop_indicator.position.x = game.playing_scene.left_boundary_pos.x + next_fruit_radius
			elif get_global_mouse_position().x > game.playing_scene.right_boundary_pos.x - next_fruit_radius:
				drop_indicator.position.x = game.playing_scene.right_boundary_pos.x - next_fruit_radius


func update_fruit_panels(next_fruit_name: String, queued_fruit_name: String, saved_fruit_name = null):
	fruit_indicator_holder.update_indicators(next_fruit_name, queued_fruit_name)
	if saved_fruit_name != null:
		fruit_indicator_holder.set_saved(saved_fruit_name)


func update_drop_indicator(fruit_to_show: String, droppable: bool, currently_spamming: bool):
	drop_indicator.update_droppable(droppable, currently_spamming, fruit_to_show)


func _on_pause_button_pressed():
	game.pause()


func play_menu_click_click():
	game.audio_players["menu_click_player"][0].play()


func play_menu_click_release():
	game.audio_players["menu_release_player"][0].play()


func play_action_click_click():
	game.audio_players["action_click_player"][0].play()


func play_action_click_release():
	game.audio_players["action_release_player"][0].play()


func mute_scene_clicks():
	print("a")
	game.playing_scene.listening_for_clicks = false


func unmute_scene_clicks():
	game.playing_scene.listening_for_clicks = true


func _on_clear_spam_hint_pressed():
	game.spam_hint_dismissed = true
	game.playing_scene.listening_for_clicks = true
	spam_hint_panel.visible = false


func _on_minimise_wheel_panel_pressed():
	fruit_wheel_panel.mouse_filter = MOUSE_FILTER_IGNORE
	fruit_wheel_panel.visible = false


func _on_open_wheel_panel_pressed():
	fruit_wheel_panel.mouse_filter = MOUSE_FILTER_STOP
	fruit_wheel_panel.visible = true


func toggle_shop():
	shop_open = !shop_open
	if shop_open:
		open_shop()
	else:
		close_shop()


func open_shop():
	mute_scene_clicks()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(shop_ui, "position:y", 178, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func close_shop():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(shop_ui, "position:y", 496, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.05).timeout
	unmute_scene_clicks()


func _on_use_saved_pressed():
	if game.playing_scene.saved_fruit != null:
		game.playing_scene.begin_ready_saved_fruit()


func start_saved_fruit_ready_animation():
	animation_player.play("ready_saved_fruit")


func saved_fruit_ready_animation_finishing():
	fruit_indicator_holder.saved_image.modulate.a = 0
	game.playing_scene.finish_ready_saved_fruit()


