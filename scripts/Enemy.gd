extends KinematicBody2D

var base_health = 100.0
var max_health
var current_health
var ship_scale = 1

onready var sprite = get_node("Emissary")
onready var collision = get_node("CollisionShape2D")
onready var projectile_alert = get_node("Projectile_alert")
# var speed = 100.0

# ****ADMIN REALM****
var STAY_HERE : bool = false

# patrol realm
var sc_traveled = 0
var sc_limit = 5
var turn_count = 0

var dmg = 0
var player_name = "Player"

# engine realm
var max_speed = 300
var speed = 0
var acceleration = 400
var move_direction
var moving = false
var destination = Vector2()
var movement = Vector2()

# interaction with the enemy
var look_to
var enemy_around : bool
var locked_enemy
var enemy_lose_range = 500.0 # Make sure the number is larger than the collision radius

onready var anim_player : AnimationPlayer = get_node("AnimationPlayer")

var rng = RandomNumberGenerator.new()
var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	_scaler()
	moving = true
	rng.randomize()
	timer = 0
	
func _scaler(): # Everything related to ship's scale
	var scale_v = Vector2(ship_scale, ship_scale)
	sprite.scale = scale_v
	collision.scale = scale_v
	projectile_alert.scale = scale_v
	
	max_health = ship_scale * base_health
	current_health = max_health
	max_speed = max_speed - (max_speed * ship_scale / 10)
	# radar modifier realm???
	# enemy_lose_range = enemy_lose_range * ship_scale // not urgent
	
func _damage_effects(): # Random events after damage taken
	var rnum = rng.randi_range(1, 10)
	match rnum:
		1, 2, 3, 4, 5:
			max_speed -= 50
			print("Speed down")
		10:
			current_health = 0
			print("Critical hit")
		_:
			continue
	pass

func _physics_process(delta):
	# follow_player() # Works only if there is a player
	
	if Input.is_action_just_pressed("enemy_stop"):
		STAY_HERE = !STAY_HERE
	if enemy_around:
		if _is_enemy_lost():
			enemy_around = false
			locked_enemy = null
		else:
			look_to = locked_enemy.position # enemy_location
			follow_player()
	else:
		look_to = destination
		patrol(delta)
		
	movement_loop(delta)
	look_at(look_to)
	
	if dmg * delta != 0:
		current_health -= dmg * delta
		if timer == 0:
			_damage_effects()
		if current_health <= 0:
			anim_player.play("fade_out")
			
	timer += delta
	if timer >= 0.5:
		timer = 0

# warning-ignore:unused_argument
func patrol(delta) -> void:
	if sc_traveled >= sc_limit:
		sc_traveled = 0
		# turn
		turn_count += 1
	else:
		sc_traveled += delta
	destination = turn(turn_count)
	
func turn(count) -> Vector2:
	if count % 4 == 0:
		return position + Vector2(1000, 0)
	elif count % 4 == 1:
		return position + Vector2(0, 1000)
	elif count % 4 == 2:
		return position + Vector2(-1000, 0)
	elif count % 4 == 3:
		return position + Vector2(0, -1000)
	else:
		return Vector2(0, 0)

func follow_player() -> void:
	if not enemy_around:
		return
	moving = true
	destination = locked_enemy.position
	look_at(destination)

func movement_loop(delta) -> void:
	if STAY_HERE:
		return
	if moving == false:
		speed = 0
	else:
		speed += acceleration * delta
		if speed > max_speed:
			speed = max_speed
	movement = position.direction_to(destination) * speed
	move_direction = rad2deg(destination.angle_to_point(position))
	if position.distance_to(destination) > 5:
		movement = move_and_slide(movement)
	else:
		moving = false

func _on_Projectile_alert_area_entered(area):
	if area.get_parent().name == "Laser":
		dmg = 100.0
	if area.get_parent().name == "Bullet": # SHOULD WORK MORE ON THAT
		current_health -= 20
		area.get_parent().queue_free()
		print("HIT")

func _on_Projectile_alert_area_exited(area):
	if area.get_parent().name == "Laser":
		dmg = 0

func _on_Detector_area_entered(area):
	enemy_around = true
	locked_enemy = area.get_parent()

func _is_enemy_lost():
	var difference : Vector2 = locked_enemy.position - position
	var length = pow( pow(difference.x, 2) + pow(difference.y, 2), 0.5)
	if length > enemy_lose_range: # Make sure the number is larger than the collision radius
		return true
	else:
		return false
