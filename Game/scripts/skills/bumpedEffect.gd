extends Node
class_name BumpedEffect

@export var skillOwner:Node2D
@export var direction:Vector2
@export var speed:float = 1000.0
@export var damping:float = 1000.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	#skillOwner.set_physics_process(false)
	skillOwner.global_position += direction * speed * delta
	speed -= damping * delta
	if (speed < 0.0):
		speed = 0.0
		#skillOwner.set_physics_process(true)

