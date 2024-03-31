extends Node2D

@onready var game = $"../.."

@export var min_wait_time: float = 0.45

var fruit_spawn_cooldown: float = 10
var next_fruit_to_drop
var next_fruit_name: String

func _ready():
	next_fruit_to_drop = pick_fruit()

func _physics_process(delta):
	fruit_spawn_cooldown += delta


func _input(event):
	if event.is_action_pressed("drop_fruit"):
		if get_global_mouse_position().x >= 817 and get_global_mouse_position().x <= 1743 and fruit_spawn_cooldown > min_wait_time:
			fruit_spawn_cooldown = 0
			add_child(next_fruit_to_drop)
			next_fruit_to_drop.global_position.x = get_global_mouse_position().x + randi_range(-3, 3)
			next_fruit_to_drop.global_position.y = 40
			next_fruit_to_drop = pick_fruit()
			game.update_drop_indicator(next_fruit_name)
	if Input.is_action_just_pressed("pause"):
		game.pause()


func pick_fruit():
	var fruit_num
	
	fruit_num = randi_range(1, 100)
	
	if fruit_num <= 70:
		next_fruit_name = "grape"
		return load("res://scenes/fruits/grape.tscn").instantiate()
	elif fruit_num <= 90:
		next_fruit_name = "cherry"
		return load("res://scenes/fruits/cherry.tscn").instantiate()
	else:
		next_fruit_name = "strawberry"
		return load("res://scenes/fruits/strawberry.tscn").instantiate()


