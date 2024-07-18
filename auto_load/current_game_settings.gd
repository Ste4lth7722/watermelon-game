extends Node

@export var default_game_settings = {
	"cluster_grape_mania_on" = false,
	"sky_high_mode_on" = false,
	"cluster_grapes_enabled" = true,
	"cherry_bombs_enabled" = true
}

@export var current_game_settings = {}

func _ready():
	reset_settings()


func reset_settings():
	for setting in default_game_settings:
		current_game_settings[setting] = default_game_settings[setting]
		#print(current_game_settings[setting])

