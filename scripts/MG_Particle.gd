extends KinematicBody2D

const speed = 200
var direction = Vector2.ZERO

var distance = 0.0
var bullet_range : float

func _ready():
	pass

func _process(delta):
	var collision_status = move_and_collide((direction) * speed * delta)
	distance += speed * delta 
	if collision_status != null or distance >= bullet_range:
		
		#if collision_status.health:
		#	collision_status.get_parent().health -= 5
		#	print("-5")
		queue_free()
