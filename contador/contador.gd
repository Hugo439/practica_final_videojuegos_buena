extends Control

@export var image_path: String = ""

@onready var label = $hbox/lbl_contador
@onready var image = $hbox/imagen

func _ready():
	if image_path:
		image.texture = load(image_path)

func actualizar(valor:int):
	label.text = str(valor)
