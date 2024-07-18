extends Control

@onready var saved_panel = $SavedPanel
@onready var current_image = $CurrentPanel/CurrentImage
@onready var queued_image = $QueuedPanel/QueuedImage
@onready var animation_placeholder = $QueuedPanel/AnimationPlaceholder
@onready var saved_image = $SavedPanel/Image

@onready var animation_player = $AnimationPlayer

var current_image_default_pos
var queued_image_default_pos
var saved_image_default_pos

var sin_anim_stage = 0

var fruit_stripe_colours = {
	"grape": {"bg": Color8(81, 70, 89), "stripe": Color8(106, 87, 127, 176)},
	"cluster_grape": {"bg": Color8(81, 70, 89), "stripe": Color8(106, 87, 127, 176)},
	"cherry": {"bg": Color8(85, 67, 78), "stripe": Color8(122, 83, 103, 176)},
	"cherry_bomb": {"bg":Color8(85, 67, 78), "stripe": Color8(122, 83, 103, 176)},
	"strawberry": {"bg": Color8(85, 65, 68), "stripe": Color8(145, 70, 79, 176)}
}

func _ready():
	current_image.position = Vector2(14, 34)
	queued_image.position = Vector2(14, 34)
	animation_placeholder.position = Vector2(178.5, 34)
	saved_image.position = Vector2(19, 36)
	current_image_default_pos = current_image.global_position
	queued_image_default_pos = queued_image.global_position
	saved_image_default_pos = saved_image.global_position


func _process(delta):
	sin_anim_stage += delta * 2
	$CurrentPanel/StripeHolder/Stripe.position.x += sin(sin_anim_stage) / 2


func update_indicators(current, queued):
	set_animation_placeholder(queued)
	animation_player.play("update")
	await animation_player.animation_finished
	set_current(current)
	set_queued(queued)
	animation_placeholder.position = Vector2(178.5, 56)
	current_image.global_position = current_image_default_pos
	queued_image.global_position = queued_image_default_pos


func set_animation_placeholder(fruit_name):
	var queued_image_path = ("res://graphics/fruits/" + fruit_name + ".png")
	animation_placeholder.texture = load(queued_image_path)


func set_current(fruit_name):
	var current_image_path = ("res://graphics/fruits/" + fruit_name + ".png")
	current_image.texture = load(current_image_path)
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($CurrentPanel/StripeBG, "modulate", fruit_stripe_colours[fruit_name]["bg"], 0.2)
	tween.tween_property($CurrentPanel/StripeHolder/Stripe, "modulate", fruit_stripe_colours[fruit_name]["stripe"], 0.2)
	var new_stripe_x = randi_range(-400, -100)
	var new_stripe_y = randi_range(-250, -100)
	var new_stripe_coords = Vector2(new_stripe_x, new_stripe_y)
	tween.tween_property($CurrentPanel/StripeHolder, "position", new_stripe_coords, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func set_queued(fruit_name):
	var queued_image_path = ("res://graphics/fruits/" + fruit_name + ".png")
	queued_image.texture = load(queued_image_path)


func set_saved(fruit_name):
	print(fruit_name)
	if fruit_name == "none":
		saved_image.texture = null
		saved_panel.modulate.a = 0.4
		return
	saved_panel.modulate.a = 1
	var saved_image_path = ("res://graphics/fruits/" + fruit_name + ".png")
	saved_image.texture = load(saved_image_path)


