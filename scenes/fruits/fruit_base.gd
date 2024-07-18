extends RigidBody2D

@onready var playing_scene = $".."
@onready var game = $"../../.."
@onready var fruit_to_spawn_in_cluster = randi_range(6, 10)
@onready var sprite = $"Node2D/Sprite2D"
@onready var animation_player = $AnimationPlayer

var time_to_reset_death_timer = 0

var merge_time: float = 0.075

var merge_started: bool = false
var current_fruit_type: String
var next_fruit_type: String
var points_value: int
var hit_fruit = false
var can_reset_death_timer = false

var exploded = false

var time_existed: float = 0
var id: int

var next_fruit_info = {
	"grape": ["cherry", 1],
	"cherry": ["strawberry", 2],
	"strawberry": ["lemon", 4],
	"lemon": ["orange", 8],
	"orange": ["apple", 16],
	"apple": ["pear", 32],
	"pear": ["mango", 64],
	"mango": ["cantaloupe", 128],
	"cantaloupe": ["watermelon", 256],
	"watermelon": ["grape", 512],
	"cluster_grape": ["cluster_cherry", 512],
	"cluster_cherry": ["cluster_strawberry", 1024],
	"cluster_strawberry": ["watermelon", 2048],
	"cherry_bomb": ["this will never be called", 69420]
}

# For cluster grapes
var time_since_collision: float = 0

func _ready():
	id = playing_scene.add_fruit()
	# If this is the first fruit placed, instantly grants it ability to reset the skyhigh mode death timer.
	if id == 1 and CurrentGameSettings.current_game_settings["sky_high_mode_on"] == true:
		can_reset_death_timer = true
	var groups = get_groups()
	for group in groups:
		if group != "fruit" and group != "cluster_fruit":
			current_fruit_type = group
	next_fruit_type = next_fruit_info[current_fruit_type][0]
	points_value = next_fruit_info[current_fruit_type][1]


func _physics_process(delta):
	if time_existed <= time_to_reset_death_timer:
		time_existed += delta
	else:
		can_reset_death_timer = true
	if hit_fruit:
		time_since_collision += delta
		if time_since_collision >= time_to_reset_death_timer:
			can_reset_death_timer = true
		if is_in_group("cluster_grape"):
			if time_since_collision >= 4 or CurrentGameSettings.current_game_settings["cluster_grape_mania_on"] and time_since_collision >= 1.5:
				explode()
		elif is_in_group("cluster_cherry"):
			if time_since_collision >= 7:
				explode()
		elif is_in_group("cluster_strawberry"):
			if time_since_collision >= 10:
				explode()


func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("fruit"):
		if time_existed >= 0.25:
			hit_fruit = true
	if not area.get_parent().is_in_group("cluster_fruit") or not CurrentGameSettings.current_game_settings["cluster_grape_mania_on"]:
		if area.get_parent().is_in_group(current_fruit_type) and id > area.get_parent().id and not merge_started and not current_fruit_type == "cherry_bomb":
			GlobalStats.fruit_merges += 1
			merge_started = true
			area.get_parent().merge_started = true
			playing_scene.fruit_merged(next_fruit_type)
			var new_pos = (area.global_position + global_position) / 2
			var new_rotation = (global_rotation_degrees + area.global_rotation_degrees) / 2
			
			if merge_started and area.get_parent().merge_started:
				var tweener: Tween = get_tree().create_tween()
				tweener.set_parallel(true)
				tweener.tween_property(self.sprite, "global_position", new_pos, merge_time)
				tweener.tween_property(area.get_parent().sprite, "global_position", new_pos, merge_time)
				tweener.tween_property(self.sprite, "global_rotation_degrees", new_rotation, merge_time)
				tweener.tween_property(area.get_parent().sprite, "global_rotation_degrees", new_rotation, merge_time)
			
			await get_tree().create_timer(merge_time).timeout
			game.audio_players["fruit_merge_player"][0].play()
			var new_fruit_path = ("res://scenes/fruits/" + next_fruit_type + ".tscn")
			var loaded_fruit = load(new_fruit_path).instantiate()
			playing_scene.call_deferred("add_child", loaded_fruit)
			if next_fruit_type == "cluster_cherry" or next_fruit_type == "cluster_strawberry":
				loaded_fruit.time_to_reset_death_timer = 2
			loaded_fruit.global_position = new_pos
			game.modify_score(points_value)
			queue_free()
			if area != null:
				area.get_parent().queue_free()
			else:
				print("error - area's parent is null")


func explode():
	var fruit_to_spawn
	if is_in_group("cluster_grape"):
		fruit_to_spawn = load("res://scenes/fruits/grape.tscn")
		playing_scene.play_cluster_grape_explode(fruit_to_spawn_in_cluster)
	elif is_in_group("cluster_cherry"):
		fruit_to_spawn = load("res://scenes/fruits/cherry.tscn")
		playing_scene.play_cluster_cherry_explode(fruit_to_spawn_in_cluster)
	elif is_in_group("cluster_strawberry"):
		fruit_to_spawn = load("res://scenes/fruits/strawberry.tscn")
		playing_scene.play_cluster_strawberry_explode(fruit_to_spawn_in_cluster)
	
	playing_scene.sky_high_manager.fruit_dropped(fruit_to_spawn_in_cluster)
	for i in range(1, fruit_to_spawn_in_cluster):
		spawn_fruit_from_cluster(fruit_to_spawn)
	queue_free()


func spawn_fruit_from_cluster(fruit_to_spawn):
	var new_fruit = fruit_to_spawn.instantiate()
	playing_scene.add_child(new_fruit)
	new_fruit.start_cooldown_cluster_fruit()
	new_fruit.angular_velocity = randf_range(-25, 25)
	new_fruit.linear_velocity.y = randf_range(-500, -800)
	new_fruit.linear_velocity.x = randf_range(-300, 300)
	new_fruit.global_position = global_position


func _on_area_2d_body_entered(_body):
	if CurrentGameSettings.current_game_settings["sky_high_mode_on"]:
		can_reset_death_timer = true
	hit_fruit = true


func start_cooldown_cluster_fruit():
	set_collision_mask_value(1, false)
	merge_started = true
	await get_tree().create_timer(0.5).timeout
	set_collision_mask_value(1, true)
	merge_started = false


func start_cooldown_spamming():
	pass
	#merge_started_cooldown()
	#fruit_area_cooldown()


#func merge_started_cooldown():
	#merge_started = true
	#await get_tree().create_timer(0.5).timeout
	#merge_started = false


#func fruit_area_cooldown():
	#set_collision_mask_value(1, false)
	#await get_tree().create_timer(0.5).timeout
	#set_collision_mask_value(1, true)


func explode_bomb():
	# ExplosionManager only exists in bomb fruits.
	if not exploded:
		$ExplosionManager.explode()
		exploded = true


