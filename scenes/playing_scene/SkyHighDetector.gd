extends Area2D

@onready var playing_scene = $".."

var enabled: bool = false
var scanning: bool = false

func enable():
	enabled = true


func _physics_process(_delta):
	if enabled and scanning:
		if not has_overlapping_bodies():
			playing_scene.death_timer_active = true
		elif has_overlapping_bodies():
			for body in get_overlapping_bodies():
				if body.can_reset_death_timer:
					playing_scene.death_timer_active = false


func fruit_dropped(times: int):
	if enabled and global_position.y <= 626:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "global_position:y", global_position.y + 0.5 * times, 0.5)
	if not scanning:
		scanning = true


func fruit_merged(fruit_to_be_merged):
	if enabled:
		if fruit_to_be_merged == "watermelon":
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(self, "global_position:y", global_position.y + 40, 0.5)
		else:
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(self, "global_position:y", global_position.y - 4, 0.5)
