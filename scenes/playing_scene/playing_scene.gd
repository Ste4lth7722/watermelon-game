extends Node2D

@onready var game = $"../.."
@onready var max_height_detector = $MaxHeightDetector
@onready var sky_high_manager = $SkyHighManager

@export var min_wait_time: float = 0.45

var left_boundary_pos: Vector2
var right_boundary_pos: Vector2

var current_timer: float = 0
var game_over_time: int = 6
var show_timer_time: int = 5
var game_ended: bool = false

var time_held: float = 0
var spam_time_threshold: float = 0.85
var spamming: bool = false

#region Fruit Info
var fruit_spawn_cooldown: float = 10
var fruit_droppable: bool
var listening_for_clicks: bool = true

var saved_fruit: Node
var saved_fruit_name: String
var releasing_saved: bool = false
var fruit_queue: Node
var fruit_queue_name: String
var next_fruit_to_drop: Node
var next_fruit_name: String
#endregion

# Chance variables are 1/x. so, a chance of 25 is a 1 in 25 chance of getting that fruit, a 4% chance.
var cherry_bomb_chance: int = 30
var cluster_grape_chance: int = 25
var fruit_counter: int = 0
var death_timer_active: bool = false

var fruit_throw_ready = false

func add_fruit() -> int:
	fruit_counter += 1
	return(fruit_counter)


func _ready():
	sky_high_manager.visible = false
	game.current_score = 0
	game.current_coins = 0
	next_fruit_to_drop = load("res://scenes/fruits/grape.tscn").instantiate()
	fruit_queue = load("res://scenes/fruits/grape.tscn").instantiate()
	next_fruit_name = "grape"
	fruit_queue_name = "grape"
	saved_fruit_name = "none"
	left_boundary_pos = $BoundaryLeft.position
	right_boundary_pos = $BoundaryRight.position


func _physics_process(delta):
	check_if_death_timer_active(delta)
	if fruit_droppable == false:
		fruit_spawn_cooldown += delta
	if fruit_spawn_cooldown > min_wait_time:
		fruit_droppable = true
		game.audio_players["fruit_ready_player"][0].play()
		#game.playing_scene_ui.update_fruit_panels(next_fruit_name, fruit_queue_name, saved_fruit_name)
		game.playing_scene_ui.update_drop_indicator(next_fruit_name, fruit_droppable, spamming)
		fruit_spawn_cooldown = 0
	#if not sky_high_enabled:
	if Input.is_action_pressed("drop_fruit") and listening_for_clicks:
		time_held += delta
	else:
		time_held = 0
	if time_held >= spam_time_threshold:
		game.playing_scene_ui.update_fruit_panels(next_fruit_name, fruit_queue_name)
		time_held -= 0.35
		spamming = true
		drop_fruit()
		


func _input(event):
	if event.is_action_pressed("drop_fruit") and listening_for_clicks:
		if fruit_droppable:
			fruit_droppable = false
			drop_fruit()
	if Input.is_action_just_released("drop_fruit"):
		if spamming:
			#game.playing_scene_ui.drop_indicator.spamming_stopped()
			fruit_droppable = false
			game.playing_scene_ui.update_fruit_panels(next_fruit_name, fruit_queue_name)
			spamming = false
	if Input.is_action_just_pressed("open_shop"):
		game.playing_scene_ui.toggle_shop()
	if Input.is_action_just_pressed("pause"):
		game.pause()


func drop_fruit():
	generate_drop_sound()
	if releasing_saved == true:
		release_saved_fruit()
		return
	add_child(next_fruit_to_drop)
	# Only fruits dropped have a reset timer because of the below line.
	next_fruit_to_drop.time_to_reset_death_timer = 2
	if spamming:
		next_fruit_to_drop.start_cooldown_spamming()
	next_fruit_to_drop.global_position = game.get_fruit_drop_pos()
	next_fruit_to_drop = fruit_queue
	next_fruit_name = fruit_queue_name
	game.playing_scene_ui.next_fruit_radius = game.playing_scene_ui.fruit_queue_radius
	fruit_queue = pick_fruit()
	game.playing_scene_ui.update_fruit_panels(next_fruit_name, fruit_queue_name)
	game.playing_scene_ui.update_drop_indicator(next_fruit_name, fruit_droppable, spamming)
	sky_high_manager.fruit_dropped(1)


func pick_fruit():
	var fruit_num = randi_range(1, 100)
	if fruit_num <= 65:
		var cluster_grape_roll = randi_range(1, cluster_grape_chance)
		if cluster_grape_roll <= 1 and CurrentGameSettings.current_game_settings["cluster_grapes_enabled"] or CurrentGameSettings.current_game_settings["cluster_grape_mania_on"]:
			fruit_queue_name = "cluster_grape"
			game.playing_scene_ui.fruit_queue_radius = 40
			return load("res://scenes/fruits/cluster_grape.tscn").instantiate()
		else:
			fruit_queue_name = "grape"
			game.playing_scene_ui.fruit_queue_radius = 20
			return load("res://scenes/fruits/grape.tscn").instantiate()
	elif fruit_num <= 85:
		var cherry_bomb_roll = randi_range(1, cherry_bomb_chance)
		if cherry_bomb_roll <= 1 and CurrentGameSettings.current_game_settings["cherry_bombs_enabled"]:
			fruit_queue_name = "cherry_bomb"
			game.playing_scene_ui.fruit_queue_radius = 25
			return load("res://scenes/fruits/cherry_bomb.tscn").instantiate()
		else:
			fruit_queue_name = "cherry"
			game.playing_scene_ui.fruit_queue_radius = 25
			return load("res://scenes/fruits/cherry.tscn").instantiate()
	else:
		fruit_queue_name = "strawberry"
		game.playing_scene_ui.fruit_queue_radius = 35
		return load("res://scenes/fruits/strawberry.tscn").instantiate()


func check_if_death_timer_active(delta):
	if CurrentGameSettings.current_game_settings["sky_high_mode_on"] == false:
		var bodies: int = 0
		for body in max_height_detector.get_overlapping_bodies():
			if body.can_reset_death_timer:
				bodies += 1
				break
		if bodies == 0:
			death_timer_active = false
		else:
			death_timer_active = true
	
	if death_timer_active:
		current_timer -= delta
	else:
		game.playing_scene_ui.game_over_timer.visible = false
		current_timer = game_over_time
	if current_timer < show_timer_time:
		game.playing_scene_ui.game_over_timer.visible = true
		game.playing_scene_ui.game_over_timer.text = var_to_str(ceil(current_timer)).replace(".0","")
	if current_timer <= 0:
		if not game_ended:
			game_ended = true
			game.audio_players["game_over_player"][0].play()
			game.show_game_over()
			get_tree().paused = true


func set_death_barrier(value: int):
	max_height_detector.position.y = value


func generate_drop_sound():
	match next_fruit_name:
		"grape": game.audio_players["fruit_drop_player"][0].pitch_scale = randf_range(1.25, 1.35)
		"cherry": game.audio_players["fruit_drop_player"][0].pitch_scale = randf_range(0.95, 1.05)
		"strawberry": game.audio_players["fruit_drop_player"][0].pitch_scale = randf_range(0.7, 0.8)
		"cluster_grape": game.audio_players["fruit_drop_player"][0].pitch_scale = randf_range(0.55, 0.65)
	game.audio_players["fruit_drop_player"][0].play()


func play_cluster_grape_explode(spawned_count):
	for i in spawned_count:
		await get_tree().create_timer(0.05).timeout
		game.audio_players["cluster_grape_explode_player"][0].play()


func play_cluster_cherry_explode(spawned_count):
	for i in spawned_count:
		await get_tree().create_timer(0.05).timeout
		game.audio_players["cluster_cherry_explode_player"][0].play()


func play_cluster_strawberry_explode(spawned_count):
	for i in spawned_count:
		await get_tree().create_timer(0.05).timeout
		game.audio_players["cluster_strawberry_explode_player"][0].play()


func enable_sky_high():
	game_over_time = 4
	show_timer_time = 3
	sky_high_manager.visible = true
	max_height_detector.visible = false
	sky_high_manager.enable()


func fruit_merged(next_fruit_type):
	sky_high_manager.fruit_merged(next_fruit_type)


func save_fruit():
	game.playing_scene_ui.fruit_indicator_holder.saved_image.modulate.a = 1
	game.playing_scene_ui.saved_fruit_radius = game.playing_scene_ui.next_fruit_radius
	saved_fruit_name = next_fruit_name
	saved_fruit = next_fruit_to_drop
	next_fruit_name = fruit_queue_name
	next_fruit_to_drop = fruit_queue
	fruit_queue = pick_fruit()
	game.playing_scene_ui.update_fruit_panels(next_fruit_name, fruit_queue_name, saved_fruit_name)
	game.playing_scene_ui.update_drop_indicator(next_fruit_name, fruit_droppable, spamming)


func begin_ready_saved_fruit():
	releasing_saved = true
	game.playing_scene_ui.start_saved_fruit_ready_animation()


func finish_ready_saved_fruit():
	print(saved_fruit_name)
	game.playing_scene_ui.update_fruit_panels(next_fruit_name, fruit_queue_name, saved_fruit_name)
	game.playing_scene_ui.update_drop_indicator(saved_fruit_name, fruit_droppable, spamming)
	game.playing_scene_ui.next_fruit_radius = game.playing_scene_ui.saved_fruit_radius


func release_saved_fruit():
	releasing_saved = false
	add_child(saved_fruit)
	# Only fruits dropped have a reset timer because of the below line. <-- [what does this mean? ill keep it in but still]
	saved_fruit.time_to_reset_death_timer = 2
	saved_fruit.global_position = game.get_fruit_drop_pos()
	saved_fruit_name = "none"
	saved_fruit = null
	game.playing_scene_ui.update_fruit_panels(next_fruit_name, fruit_queue_name, saved_fruit_name)
	game.playing_scene_ui.update_drop_indicator(next_fruit_name, fruit_droppable, spamming)
	sky_high_manager.fruit_dropped(1)



func prepare_fruit_throw():
	fruit_throw_ready = true
	game.playing_scene_ui.fruit_throw_indicator.visible = true
	print("Fruit prepared to throw: " + var_to_str(next_fruit_name))
	## Add power arrow, and add extra velocity in direction arrow points when dropped



func throw_fruit():
	fruit_throw_ready = false
	game.playing_scene_ui.fruit_throw_indicator.visible = false


