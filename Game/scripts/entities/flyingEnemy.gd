extends Node2D
class_name FlyingEnemy

@export var accSpeed: float = 50
@export var velocityDecreaseRate: float = 0.9
@export var target: Node2D
@export var velocity: Vector2 = Vector2.ZERO
@export var radius = 100
var isMovingOnItsOwn:bool = true

@onready var navAgent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	resume()
	
func stop():
	isMovingOnItsOwn = false
	if (navAgent.velocity_computed.is_connected(onVelocityComputed)):
		navAgent.velocity_computed.disconnect(onVelocityComputed)
	
func resume():
	isMovingOnItsOwn = true
	navAgent.velocity_computed.connect(onVelocityComputed)

func _physics_process(delta):
	if (isMovingOnItsOwn):
		if (target != null):
			velocity += (target.global_position - global_position).normalized() * accSpeed		
			navAgent.target_position = target.global_position
		else:
			velocity -= velocity * delta * velocityDecreaseRate
				
		navAgent.set_velocity(velocity)
				
		#global_position += velocity * delta
	else:
		global_position += velocity * delta

func onVelocityComputed(safe_velocity):
	velocity = safe_velocity
	global_position += velocity * get_physics_process_delta_time()
