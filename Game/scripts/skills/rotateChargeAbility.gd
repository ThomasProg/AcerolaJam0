extends Node
class_name RotateChargeAbility

@export var skillOwner:Player
#@export var angularAcceleration:float = PI # in degrees/s
@export var angularSpeed:float = 4*PI # in degrees/s

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
	
var bumped = null
var bumpedDir:Vector2
	
func start():
	for child in skillOwner.get_children():
		if (child is Health):
			child.onDamage.connect(func(attacker:Node2D): 
				attacker.set_physics_process(false)
				bumped = attacker
				bumped.velocity = bumpedDir * 1000.0
				bumpedDir = skillOwner.global_position.direction_to(attacker.global_position)
				stop(), CONNECT_ONE_SHOT)

func stop():
	skillOwner.scale = Vector2.ONE
	skillOwner.rotation = 0
	set_physics_process(false)

func _physics_process(delta):
	#angularSpeed += delta * angularAcceleration
	#angularSpeed = clamp(angularSpeed, 0.0, 4*PI)
	
	if (bumped is CharacterBody2D):
		bumped.move_and_slide()
	
	skillOwner.scale += Vector2.ONE * delta * 1.0
	#skillOwner.scale += Vector2.ONE * delta * skillOwner.scale
	#skillOwner.scale.x = min(skillOwner.scale.x, 2.0)
	#skillOwner.scale.y = min(skillOwner.scale.y, 2.0)
	#
	skillOwner.rotation += delta * angularSpeed
	skillOwner.impulseVelocity.x = lerp(1000, 1500, angularSpeed/(4*PI))



