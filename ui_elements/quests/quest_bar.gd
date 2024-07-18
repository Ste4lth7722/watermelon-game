extends Control

@onready var progress_bar = $ProgressBar
@onready var title_label = $Title
@onready var quantity_label = $Quantity

@export var title: String = "Enter title here.."
@export var quantity: float = 100
@export var stat_to_check: String = "Enter stat to check for here.."


func _ready():
	title_label.text = title
	progress_bar.max_value = quantity
	var stat_value = GlobalStats.get(stat_to_check)
	progress_bar.value = stat_value
	quantity_label.text = (var_to_str(stat_value) + "/" + var_to_str(quantity).replace(".0",  ""))


