extends Label

@onready var parent = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	parent.update_displayed_title()

