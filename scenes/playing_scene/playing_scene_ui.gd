extends Control

@onready var points_label = $PointsLabel
@onready var game_over_timer = $GameOverTimer
@onready var game = $"../.."
@onready var drop_indicator_holder = $DropIndicatorHolder
@onready var drop_indicator = $DropIndicatorHolder/DropIndicator
@onready var next_up_indicator = $NextUpIndicator

var container_left_boundary: Vector2
var container_right_boundary: Vector2
var fruit_radius: int = 20

func _physics_process(_delta):
	# Absolute piece of shit, the values in the Vector2 somehow center the fruit on the mouse. Please leave them
	if get_global_mouse_position().x >= game.playing_scene.left_boundary_pos.x + fruit_radius and get_global_mouse_position().x <= game.playing_scene.right_boundary_pos.x - fruit_radius:
		drop_indicator_holder.position = Vector2(get_global_mouse_position().x - 18, 27)
	else:
		if get_global_mouse_position().x < game.playing_scene.left_boundary_pos.x + fruit_radius:
			drop_indicator_holder.position = Vector2(game.playing_scene.left_boundary_pos.x + fruit_radius - 18, 27)
		elif get_global_mouse_position().x > game.playing_scene.right_boundary_pos.x - fruit_radius:
			drop_indicator_holder.position = Vector2(game.playing_scene.right_boundary_pos.x - fruit_radius - 18, 27)


func _on_pause_button_pressed():
	game.pause()


