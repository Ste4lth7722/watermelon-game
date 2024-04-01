extends Node2D

@onready var game = $"../.."

@export var min_wait_time: float = 0.45

var left_boundary_pos: Vector2
var right_boundary_pos: Vector2

var current_timer: float = 0
var game_over_time: int = 7
var show_timer_time: int = 5

var fruit_spawn_cooldown: float = 10
var fruit_droppable: bool

var fruit_queue: Node
var fruit_queue_name: String
var next_fruit_to_drop: Node
var next_fruit_name: String
var fruit_radius: int

func _ready():
	fruit_queue = load("res://scenes/fruits/grape.tscn").instantiate()
	next_fruit_to_drop = load("res://scenes/fruits/grape.tscn").instantiate()
	next_fruit_name = "grape"
	fruit_queue_name = "grape"
	left_boundary_pos = $BoundaryLeft.position
	right_boundary_pos = $BoundaryRight.position


func _physics_process(delta):
	check_if_fruit_over_limit(delta)
	if fruit_droppable == false:
		fruit_spawn_cooldown += delta
	if fruit_spawn_cooldown > min_wait_time:
		fruit_droppable = true
		game.update_drop_indicators(next_fruit_name, fruit_droppable, fruit_queue_name)
		fruit_spawn_cooldown = 0


func _input(event):
	if event.is_action_pressed("drop_fruit"):
		if fruit_droppable:
			fruit_droppable = false
			add_child(next_fruit_to_drop)
			next_fruit_to_drop.global_position = game.get_fruit_drop_pos()
			print(next_fruit_to_drop.global_position)
			next_fruit_to_drop = fruit_queue
			next_fruit_name = fruit_queue_name
			fruit_queue = pick_fruit()
			game.update_drop_indicators(next_fruit_name, fruit_droppable, fruit_queue_name)
	if Input.is_action_just_pressed("pause"):
		game.pause()


func pick_fruit():
	var fruit_num
	
	fruit_num = randi_range(1, 100)
	
	if fruit_num <= 65:
		fruit_queue_name = "grape"
		game.playing_scene_ui.fruit_radius = 20
		return load("res://scenes/fruits/grape.tscn").instantiate()
	elif fruit_num <= 85:
		fruit_queue_name = "cherry"
		game.playing_scene_ui.fruit_radius = 25
		return load("res://scenes/fruits/cherry.tscn").instantiate()
	else:
		fruit_queue_name = "strawberry"
		game.playing_scene_ui.fruit_radius = 35
		return load("res://scenes/fruits/strawberry.tscn").instantiate()


func check_if_fruit_over_limit(delta):
	if $FruitDetector.has_overlapping_bodies():
		current_timer -= delta
	else:
		game.playing_scene_ui.game_over_timer.visible = false
		current_timer = game_over_time
	if current_timer < show_timer_time:
		game.playing_scene_ui.game_over_timer.visible = true
		game.playing_scene_ui.game_over_timer.text = var_to_str(ceil(current_timer)).replace(".0","")
	if current_timer <= 0:
		get_tree().quit()


