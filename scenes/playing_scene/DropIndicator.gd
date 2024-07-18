extends Control

@onready var image = $"ImageHolder/Image"
@onready var image_holder = $"ImageHolder"
@onready var fruit_throw_indicator = $FruitThrowIndicator


var alpha_tween

signal left_click_released

var fruit_positioning_settings = {
	"grape": [Vector2(40, 40), Vector2(-20, -20)],
	"cluster_grape": [Vector2(128, 128),Vector2(-64, -64)],
	"cherry": [Vector2(84, 84),Vector2(-42, -60)],
	"cherry_bomb": [Vector2(84, 84),Vector2(-42, -60)],
	"strawberry": [Vector2(68, 68),Vector2(-33, -37)]
}


func _ready():
	modulate.a = 0.7


func _process(_delta):
	print(global_position)
	fruit_throw_indicator.rotation = global_position.angle_to(get_local_mouse_position())


func update_image_only(fruit_to_show: String):
	image.texture = load("res://graphics/fruits/" + fruit_to_show + ".png")
	image.size = fruit_positioning_settings[fruit_to_show][0]
	image.position = fruit_positioning_settings[fruit_to_show][1]


func update_droppable(droppable: bool, currently_spamming: bool, fruit_to_show: String):
	#if droppable and not currently_spamming and not Input.is_action_pressed("drop_fruit"):
		#animation_player.stop()
		#animation_player.play("drop_ready")
	#if currently_spamming:
	#	image_holder.position.y = 0
	#else:
		#await left_click_released
		#update_image_only(fruit_to_show)
		#image_holder.position.y = -120
	update_image_only(fruit_to_show)
	if droppable and not currently_spamming:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 0.7, 0.3).set_trans(Tween.TRANS_QUAD)
	else:
		modulate.a = 0.2


#func spamming_stopped():
	#animation_player.play("spamming_stopped")


#func _input(event):
	#if Input.is_action_just_released("drop_fruit"):
		#left_click_released.emit()


