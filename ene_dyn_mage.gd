extends CharacterBody2D

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@export var speed = 100
@export var tiempo_recuperacion = 3.0  # Tiempo en segundos antes de que el enemigo pueda volver a dañar

var jugadores_golpeados = []  # Lista de jugadores que ya fueron golpeados
@onready var ani_ene_dyn = $ani_ene_dyn
# Variable para indicar si vamos hacia delante (1) o atrás (-1)
var sentido = 1

func _ready() -> void:
	ani_ene_dyn.play("walk")


func _on_ene_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores") and body.vidas > 0:
		if not jugadores_golpeados.has(body):
			body.quitar_vida()
			jugadores_golpeados.append(body)
			# Llamamos a la función para remover al jugador después del tiempo de recuperación
			remover_despues_de_tiempo(body)


func remover_despues_de_tiempo(body: Node2D) -> void:
	await get_tree().create_timer(tiempo_recuperacion).timeout
	jugadores_golpeados.erase(body)  # quitamos al jugador de la lista, para que pueda volver a ser dañado


func _physics_process(delta: float) -> void:
	# Establecemos la velocidad
	velocity.y += gravity * delta
	if is_on_wall():
		sentido = -sentido
		
	## Si el detector delantero está detectando suelo y vamos en esa dirección
	if sentido ==1 && $detectorIzquierdo.is_colliding():
		velocity.x = speed
		ani_ene_dyn.flip_h = false
	else:
		sentido = -1
	
	## Si el detector trasero está detectando suelo y vamos en esa dirección
	if sentido == -1 && $detectorDerecho.is_colliding():
		velocity.x = -speed
		ani_ene_dyn.flip_h = true
	else:
		sentido = 1

	# Refrescamos el juego
	move_and_slide()
