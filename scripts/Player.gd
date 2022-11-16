extends KinematicBody2D

var velocity = Vector2(1.0, 1.0)

# var ball = preload("res://actors/Laser.tscn")
onready var my_laser = get_node("Laser") # preload("res://actors/Laser.tscn")
onready var cam = get_node("PlayerCam")
onready var engine_beam = get_node("Sprite/EngineBeam")
onready var mg_array = get_tree().get_nodes_in_group("Machine_Guns")
onready var sprite = get_node("Sprite")

var mga_index = 0

var zoom_in_limit = Vector2(0.5, 0.5)
var zoom_out_limit = Vector2(3, 3)

var mid_to_top_px = -54
var is_firing  # terrible

var mg_ready : bool = false

# gunpod realm
var laser_x_scale_spd = 5.0
var laser_y_scale_spd = 1.0
var laser_x_scale_lmt = 10.0

# engine realm
var max_speed = 400
var speed = 0
var acceleration = 500
var brake_force = 200
var move_direction : float
var moving = false
var destination = Vector2()
var movement = Vector2()

# skills realm
var skills = { # value of the key data should be taken from a save file
	"steady": 1,
	"laser"	: 1,
	"bullet": 1,
	"bomb"	: 0
}

# skins realm
var skins = {
	"beholder": preload("res://assets/ships/Beholder.png"),
	"emissary": preload("res://assets/ships/Emissary.png"),
	"spaceship1": preload("res://assets/ships/spaceship-1.png"),
	"spaceship2": preload("res://assets/ships/spaceship-2.png"),
	"spaceship3": preload("res://assets/ships/spaceship-3.png"),
	"spaceship4": preload("res://assets/ships/spaceship-4.png"),
	"spaceship5": preload("res://assets/ships/spaceship-5.png"),
	"spaceship6": preload("res://assets/ships/spaceship-6.png"),
	"spaceship7": preload("res://assets/ships/spaceship-7.png")
	
	
}

func _ready():
	sprite.set_texture(skins["spaceship2"])
	is_firing = true
	not_firing()

# warning-ignore:unused_argument
func _unhandled_input(event):
	if _check_skill("steady") and Input.is_action_pressed("steady"): # stops
		moving = false
	if Input.is_action_pressed("click"): # Change Input with event if there is a problem
		look_at(get_global_mouse_position())
		if not Input.is_action_pressed("steady"):
			moving = true
			destination = get_global_mouse_position()
#	if Input.is_action_pressed("shoot"):
#		firing()
#	if Input.is_action_just_released("shoot"):
#		not_firing()
	if Input.is_action_just_pressed("zoom_in") and cam.zoom > zoom_in_limit:
		cam.zoom -= Vector2(0.1, 0.1) 
	if Input.is_action_just_pressed("zoom_out") and cam.zoom < zoom_out_limit:
		cam.zoom += Vector2(0.1, 0.1) 

func _check_skill(name):
	if not (name in skills):
		push_error("Input " + name + " is not a skill")
		get_tree().quit() # safe exit
	if skills[name] == 1:
		return true
	else:
		return false

	
func firing() -> void:
	if is_firing:
		if my_laser.scale.x < laser_x_scale_lmt:
			my_laser.scale.x += laser_x_scale_spd * get_process_delta_time()
			my_laser.scale.y += laser_y_scale_spd * get_process_delta_time()
		return
	is_firing = true
	my_laser.visible = true
	my_laser.scale.x = 1.0
	my_laser.scale.y = 1.0
	my_laser.get_node("mid_laser/CollisionShape2D").disabled = false
	my_laser.get_node("mid_laser").monitorable = true

func not_firing() -> void:
	if not is_firing:
		return
	is_firing = false
	my_laser.visible = false
	my_laser.scale.x = 0.0
	my_laser.scale.y = 0.0
	my_laser.get_node("mid_laser/CollisionShape2D").disabled = true
	my_laser.get_node("mid_laser").monitorable = false

func movement_loop(delta):
	if moving == false:
		engine_beam.emitting = false
		speed = 0
	else:
		engine_beam.emitting = true
		speed += acceleration * delta
		if speed > max_speed:
			speed = max_speed
		engine_beam.modulate.a = speed / max_speed
		
	movement = position.direction_to(destination) * speed
	move_direction = destination.angle_to_point(position) # rad2deg(destination.angle_to_point(position))
	# print(move_direction)
	if position.distance_to(destination) > 8:
		movement = move_and_slide(movement)
	else:
		moving = false

func _physics_process(delta):
	if Input.is_action_pressed("shoot"):
		firing()
	if Input.is_action_just_released("shoot"):
		not_firing()
	if Input.is_action_pressed("mg_shoot"):
		_mg_fire(delta)
	if Input.is_action_pressed("click"): # Might cause problems in the future
		mg_ready = true
		destination = get_global_mouse_position()
		acceleration = abs(acceleration)
	movement_loop(delta)
	_check_skill("steady")
	
func _mg_fire(delta):
	if mg_array.size() == 0:
		return
	var current_mg = mg_array[mga_index]
	current_mg.mg_ready = true
	
	if current_mg.fire(delta):
		current_mg.mg_ready = false
		if (mga_index + 1) < mg_array.size(): # fired successfully
			mga_index += 1
		else:
			mga_index = 0
	else:
		return
