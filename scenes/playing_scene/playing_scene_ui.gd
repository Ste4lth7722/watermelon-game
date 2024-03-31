extends Control

@onready var points_label = $PointsLabel
@onready var game = $"../.."
@onready var drop_indicator_holder = $DropIndicatorHolder
@onready var drop_indicator = $DropIndicatorHolder/DropIndicator


func _physics_process(_delta):
	if get_global_mouse_position().x >= 817 and get_global_mouse_position().x <= 1743:
		drop_indicator_holder.position = Vector2(get_global_mouse_position().x - 25, 20)


func _on_pause_button_pressed():
	game.pause()
