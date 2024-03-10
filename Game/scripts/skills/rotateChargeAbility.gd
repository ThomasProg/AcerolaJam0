extends Node
class_name RotateChargeAbility

@export var skillOwner:Player
#@export var angularAcceleration:float = PI # in degrees/s
@export var angularSpeed:float = 4*PI # in degrees/s

@export var direction:float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
	
func onDamage(attacker:Node2D):
	if (attacker is AberrationArea):
		return
	
	var bumpedEffect = BumpedEffect.new()
	bumpedEffect.skillOwner = attacker
	bumpedEffect.speed = 3000.0
	bumpedEffect.damping = 3000.0
	bumpedEffect.direction = skillOwner.global_position.direction_to(attacker.global_position)
	attacker.add_child(bumpedEffect)
	stop()

func start():
	for child in skillOwner.get_children():
		if (child is Health):
			child.onDamage.connect(onDamage)

func stop():
	skillOwner.scale = Vector2.ONE
	skillOwner.rotation = 0
	set_physics_process(false)
	for child in skillOwner.get_children():
		if (child is Health):
			if (child.onDamage.is_connected(onDamage)):
				child.onDamage.disconnect(onDamage)

func _physics_process(delta):
	direction = skillOwner.direction
	
	skillOwner.scale += Vector2.ONE * delta * 1.0
	skillOwner.scale.x = min(skillOwner.scale.x, 3.0)
	skillOwner.scale.y = min(skillOwner.scale.y, 3.0)
	#
	skillOwner.rotation += delta * angularSpeed * direction
	
	if (skillOwner.get_last_slide_collision()):
		var ortho:Vector2 = -skillOwner.get_last_slide_collision().get_normal().orthogonal()
		skillOwner.impulseVelocity = ortho * (direction * lerp(1000, 1500, angularSpeed/(4*PI)))
		skillOwner.velocity.y = 0
		skillOwner.jump.durationSinceLastFallStart = 0
