extends CharacterBody2D

@export var gravity_scale = 2
@export var speed = 300
@export var acceleration = 400
@export var friction = 5000
@export var jump_force = -700
@export var air_acceleration = 2500
@export var air_friction = 1200
@export var contador_scene: PackedScene # Arrastra la escena "contador.tscn" en el editor
@export var monedas_máximas = 7

@onready var canvas_layer = $CanvasLayer
@onready var label = $CanvasLayer2/lbl
@onready var fondo_label = $CanvasLayer2/fondo
@onready var ani_player = $ani_player
@onready var tiempo = $Timer
@onready var audio_muerte = $audio_player
@onready var contador: Control = $CanvasLayer/contador # Referencia al contador
@onready var posicion_inicial = position  # Guarda la posición de inicio

# Contador de monedas
var monedas: int = 0
# Contador de vidas
var vidas: int = 3
# Diccionario para manejar múltiples contadores
var contadores = {}
# Colores
var azul: Color = Color(0, 0, 1, 1) # Azul (RGB)
var blanco: Color = Color(1, 1, 1, 1) # Blanco (RGB)
var negro: Color = Color(0, 0, 0, 1) # Negro (RGB)
var rojo: Color = Color(1, 0, 0, 1) # Rojo (RGB)

# Agregamos al player al grupo de jugadores
func _ready() -> void:
	add_to_group("jugadores")
	# Instanciar diferentes contadores
	contadores["monedas"] = instanciar_contador("monedas","res://contador/img/000_0045_coin.png", Vector2(0, 0))
	contadores["vidas"] = instanciar_contador("vidas","res://contador/img/000_0065_heart.png", Vector2(0, 50))


func instanciar_contador(nombre: String, image_path: String, position_offset: Vector2) -> Control:
	var nuevo_contador = contador_scene.instantiate()
	nuevo_contador.image_path = image_path  # Asignamos la imagen
	nuevo_contador.position = position_offset
	canvas_layer.add_child(nuevo_contador)
	if nombre == "vidas":
		nuevo_contador.actualizar(3)  # Establecer en 3 si son vidas
	else:
		nuevo_contador.actualizar(0)  # Establecer en 0 si es cualquier otra cosa
	return nuevo_contador


func apply_gravity(delta):
	if not is_on_floor():
		velocity+=get_gravity() * delta * gravity_scale


func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed*input_axis, acceleration*delta)


func apply_friction(input_axis: float, delta: float) -> void:
	if is_on_floor():
		var objetivo_velocidad: float = 0.0 if input_axis == 0 else velocity.x
		velocity.x = move_toward(velocity.x, objetivo_velocidad, friction * delta * 0.5)


func handle_jump():
	if is_on_floor():
		if Input.is_action_pressed("saltar"):
			velocity.y = jump_force


func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed*input_axis, air_acceleration *delta)


func update_animation(input_axis):
	if input_axis !=0:
		# velocidad de la animación será dependiente de la velocidad
		ani_player.speed_scale = velocity.length()/100
		ani_player.flip_h = (input_axis<0)
		ani_player.play("run")
	elif not is_on_floor():
		ani_player.play("jump")
	else:
		ani_player.speed_scale=1
		ani_player.play("idle")

# Función para agregar monedas y actualizar el contador correspondiente
func add_moneda():
	monedas += 1
	if contadores.has("monedas"):
		contadores["monedas"].actualizar(monedas)
	control_monedas()

func control_monedas():
	if (monedas == monedas_máximas):
		label.text = "¡YOU WIN!"
		label.visible = true
	   # Cambiar el color del texto del Label a azul
		label.modulate = blanco
		# Cambiar el color del fondo a azul
		fondo_label.visible = true
		fondo_label.set_color(azul) # Azul (RGB)
		# Desactivar el movimiento del jugador
		set_physics_process(false)

		# Esperar 3 segundos y reiniciar el nivel
		await get_tree().create_timer(3.0).timeout
		# Cargar la escena del menú
		get_tree().change_scene_to_file("res://menu/menu.tscn") 

# Función para quitar vidas y actualizar el contador correspondiente
func quitar_vida():
	vidas -= 1
	if contadores.has("vidas"):
		contadores["vidas"].actualizar(vidas)
		# desactivo las físicas
	set_physics_process(false)
	ani_player.play("death")
	audio_muerte.play()
	tiempo.start()
	await tiempo.timeout
	control_vidas()

# Función que controla cuando el jugador llega a 0 vidas
func control_vidas():
	# Si las vidas llegan a 0, mostrar "Game Over"
	if vidas <= 0:
		label.text = "¡GAME OVER!"
		label.visible = true
		# Cambiar el color del texto del Label a rojo
		label.modulate = rojo  # Rojo (RGB) 
		fondo_label.visible = true
		# Configurar el fondo en negro
		fondo_label.set_color(negro)  # Negro (RGB)
		# Desactivar el movimiento del jugador
		set_physics_process(false)

		# Esperar 3 segundos y reiniciar el nivel
		await get_tree().create_timer(3.0).timeout
		# Cargar la escena del menú
		get_tree().change_scene_to_file("res://menu/menu.tscn")  
	else:
		# Si aún tiene vidas, volver a la posición inicial
		set_physics_process(true)
		position = posicion_inicial
		# Efecto de parpadeo cuando pierde vida
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", rojo, 0.2)  # Rojo
		tween.tween_property(self, "modulate", blanco, 0.2)  # Normal


func _physics_process(delta: float) -> void:
	var input_axis = Input.get_axis("mover_izquierda","mover_derecha")
	apply_gravity(delta)
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	handle_jump()
	handle_air_acceleration(input_axis, delta)
	update_animation(input_axis)
	move_and_slide()
