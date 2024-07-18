extends Area2D

@onready var game = $"../../../.."
@onready var playing_scene = $"../.."
@onready var explosion_fx = $"../ExplosionFX"

var explosion_strength: int = 550


func _ready():
	game.audio_players["cherry_bomb_countdown_player"][0].play()
	await game.audio_players["cherry_bomb_countdown_player"][0].finished
	explode()


func explode():
	game.audio_players["cherry_bomb_explosion_player"][0].play()
	var explosion_fx_to_load = load("res://scenes/fx/explosion_fx.tscn").instantiate()
	playing_scene.add_child(explosion_fx_to_load)
	explosion_fx_to_load.global_position = get_parent().global_position
	explosion_fx_to_load.emitting = true
	for body in get_overlapping_bodies():
		if body is RigidBody2D:
			var force = (body.global_position - global_position).normalized()
			force *= explosion_strength
			for i in range(1 , 3):
				body.apply_central_impulse(force)
	get_parent().queue_free()
