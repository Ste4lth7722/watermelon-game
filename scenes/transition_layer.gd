extends Control

var fruit_counter: int = 0

@onready var game = $"../.."

func add_fruit() -> int:
	fruit_counter += 1
	return(fruit_counter)


func finish_loading():
	game.finish_loading()

func transition_fills():
	game.begin_loading()
