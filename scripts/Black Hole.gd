extends Node2D

class_name Black_Hole

export var brother_hole: PackedScene
export var boundary = 100

var bro_exists = false

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if brother_hole:
		bro_exists = true
	set_posit()
	set_sprite()
	
func check_bro():
	if brother_hole.name == "Black_Hole":
		print("yoo")
	else:
		push_error("Exported scene is not eligible to be a brother_hole.")
	pass

func set_posit():
	position.x += rng.randi_range(-boundary, boundary)
	position.y += rng.randi_range(-boundary, boundary)


# Can be added detailed different textures/animations
func set_sprite():
	get_node("Sprite").texture = load("res://assets/planets/hole.png")


func _on_Area2D_area_entered(area):
	if !bro_exists: return
	
	
