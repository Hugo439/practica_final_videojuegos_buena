extends Area2D

@onready var ani_moneda = $ani_moneda

func _ready():
	ani_moneda.play("default")


func _on_body_entered(body: Node2D):
	if body.is_in_group("jugadores"):
		body.add_moneda()
		queue_free()
