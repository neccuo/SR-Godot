extends "res://scripts/Spawner.gd"

class_name Mob_Spawner

export var enemy_scene : PackedScene
export var spawn_range = 500

# *****ADMIN REALM*****
var STAY : bool = false

func _ready():
	boundary = spawn_range

# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("enemy_stop"):
		STAY = !STAY
	if _spawn_check():
		_spawner(2)


func _spawn_check():
	if get_tree().get_nodes_in_group("enemies").size() == 1:
		return true
	return false
	

func _spawner(spawn_count):
	for _i in range(spawn_count):
		var enemy = enemy_scene.instance()
		enemy.position.x += rng.randi_range(-boundary, boundary)
		enemy.position.y += rng.randi_range(-boundary, boundary)
		enemy.STAY_HERE = STAY
		
		enemy.ship_scale = rand_range(1, 3)
		enemy.add_to_group("enemies")
		get_parent().add_child(enemy)
		print("Enemy spawned in (", int(enemy.position.x), ", ", int(enemy.position.y), ")")
		
