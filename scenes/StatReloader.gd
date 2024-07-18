extends Node

@export var refresh_rate: int = 5

var time = 0


func _physics_process(delta):
	time += delta
	if time > refresh_rate:
		time = 0
		refresh_stats()


func refresh_stats():
	GlobalStats.refresh()


