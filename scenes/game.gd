extends Node2D

@onready var scene_container = $SceneContainer
@onready var control_container = $ControlContainer
@onready var playing_scene_preload = preload("res://scenes/playing_scene/playing_scene.tscn")

var playing_scene
var playing_scene_ui
var current_score = 0

func modify_score(amount: int):
	current_score += amount
	var new_text = ("Score: " + var_to_str(current_score))
	playing_scene_ui.points_label.text = new_text

func start_game():
	control_container.get_child(0).queue_free()
	
	var playing_scene_to_load = playing_scene_preload.instantiate()
	scene_container.add_child(playing_scene_to_load)
	playing_scene = playing_scene_to_load
	
	var playing_scene_ui_to_load = load("res://scenes/playing_scene/playing_scene_ui.tscn").instantiate()
	control_container.add_child(playing_scene_ui_to_load)
	playing_scene_ui = playing_scene_ui_to_load


func pause():
	playing_scene.get_tree().paused = true
	var pause_menu_to_load = load("res://scenes/pause_menu.tscn").instantiate()
	control_container.add_child(pause_menu_to_load)


func unpause():
	$ControlContainer/PauseMenu.queue_free()
	# Below ensures that the game does not listen for input when escape is pressed to leave pause menu.
	await get_tree().create_timer(0.01).timeout
	get_tree().paused = false


func open_menu():
	scene_container.get_child(0).queue_free()
	for child in control_container.get_children():
		child.queue_free()
	get_tree().paused = false
	var to_load = load("res://scenes/main_menu.tscn").instantiate()
	control_container.add_child(to_load)


func update_drop_indicator(fruit_name: String):
	var next_fruit_picture_path = ("res://graphics/fruits/" + fruit_name + ".png")
	playing_scene_ui.drop_indicator.texture = load(next_fruit_picture_path)
	if fruit_name == "grape":
		playing_scene_ui.drop_indicator.size = Vector2(52, 52)
		playing_scene_ui.drop_indicator.position = Vector2(0, 0)
	elif fruit_name == "cherry":
		playing_scene_ui.drop_indicator.size = Vector2(90, 90)
		playing_scene_ui.drop_indicator.position = Vector2(-20, -36)
	elif fruit_name == "strawberry":
		playing_scene_ui.drop_indicator.size = Vector2(80, 80)
		playing_scene_ui.drop_indicator.position = Vector2(0, 0)
