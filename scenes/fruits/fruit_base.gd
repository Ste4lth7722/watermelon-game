extends RigidBody2D

@onready var playing_scene = $".."
@onready var game = $"../../.."

var merge_started: bool = false
var current_fruit_type: String
var next_fruit_type: String
var points_value: int

func _ready():
	current_fruit_type = get_groups()[0]
	get_next_fruit_info()


func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group(current_fruit_type) and not merge_started:
		area.get_parent().merge_started = true
		merge_started = true
		var new_fruit_path = ("res://scenes/fruits/" + next_fruit_type + ".tscn")
		var loaded_fruit = load(new_fruit_path).instantiate()
		playing_scene.call_deferred("add_child", loaded_fruit)
		loaded_fruit.global_position = area.global_position
		game.modify_score(points_value)
		queue_free()
		area.get_parent().queue_free()


func get_next_fruit_info():
	match current_fruit_type:
		"grape":
			next_fruit_type = "cherry"
			points_value = 1
		"cherry":
			next_fruit_type = "strawberry"
			points_value = 2
		"strawberry":
			next_fruit_type = "lemon"
			points_value = 4
		"lemon":
			next_fruit_type = "orange"
			points_value = 8
		"orange":
			next_fruit_type = "apple"
			points_value = 16
		"apple":
			next_fruit_type = "pear"
			points_value = 32
		"pear":
			next_fruit_type = "pineapple"
			points_value = 64
		"pineapple":
			next_fruit_type = "cantaloupe"
			points_value = 128
		"cantaloupe":
			next_fruit_type = "watermelon"
			points_value = 256
		"watermelon":
			next_fruit_type = "grape"
			points_value = 512


