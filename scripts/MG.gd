extends Node2D

export var bullet_scene : PackedScene
export var bullet_range : float
export var rate_of_fire : float # bullet per second
export var bullet_speed : float

onready var ship : Node2D = get_parent()

var mg_ready = false
# export var ship : PackedScene

# onready var ship = get_node("Player")

var timer = 0.0

func _ready():
	$AudioStreamPlayer2D.max_distance = bullet_range
	pass

#func _process(delta):
#	timer += delta
#	if !ship.mg_ready:
#		return
#	if Input.is_action_pressed("mg_shoot") and timer > (1 / rate_of_fire):
#		timer = 0.0
#		fire()
#
func _process(delta):
	if mg_ready:
		timer += delta

# warning-ignore:unused_argument
func fire(delta):
	if !ship.mg_ready or timer <= (1 / rate_of_fire):
		return false
	timer = 0.0
	var bullet = bullet_scene.instance()
	bullet.z_index = z_index
	ship.get_parent().add_child(bullet) # bullets are children of the level
	#print(ship.move_direction)
	bullet.bullet_range = bullet_range
	bullet.global_position = self.global_position
	#bullet.direction = (get_global_mouse_position() - global_position).normalized() * bullet_speed
	#print(ship.move_direction)
	bullet.direction = Vector2(cos(ship.move_direction), sin(ship.move_direction))* bullet_speed
	print(ship.move_direction)
	bullet.rotation = bullet.direction.angle()
	$AudioStreamPlayer2D.seek(5.3)
	# $AudioStreamPlayer2D.stream_paused = true
	return true

#func _unhandled_input(event):
#	if event.is_action_pressed("mg_shoot"):
#		var bullet = bullet_scene.instance()
#		get_parent().add_child(bullet)
#		bullet.global_position = self.global_position
#		bullet.direction = (get_global_mouse_position() - global_position).normalized()
#		bullet.rotation = bullet.direction.angle()
