extends Area2D
class_name ene_static  

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		body.quitar_vida()
