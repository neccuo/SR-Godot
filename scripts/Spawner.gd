extends Node2D

class_name Spawner


var boundary = 500 # Default value, change it freely

var rng = RandomNumberGenerator.new()

func _ready(): # Inevitable
	rng.randomize()	
	

# SHOULD CHANGE WITH POLY
func _spawn_check():
	pass
	

func _spawner(spawn_count):
	pass
