extends Area2D
class_name LinkEnemySub

@export var accSpeed: float = 3000
@export var velocityDecreaseRate: float = 0.9
@export var target: Node2D
@export var velocity: Vector2 = Vector2.ZERO
@export var radius = 100
var isStopped:bool = false

@onready var navAgent: NavigationAgent2D = $NavigationAgent2D

var previousPosition:Vector2

func _ready():
	resume()
	
func stop():
	isStopped = true
	if (navAgent.velocity_computed.is_connected(onVelocityComputed)):
		navAgent.velocity_computed.disconnect(onVelocityComputed)
	
func resume():
	isStopped = false
	navAgent.velocity_computed.connect(onVelocityComputed)

func _physics_process(delta):
	if (!isStopped):
		if (target != null):
			velocity = (target.global_position - global_position).normalized() * accSpeed		
			navAgent.target_position = target.global_position
		else:
			velocity -= velocity * delta * velocityDecreaseRate
				
		navAgent.set_velocity(velocity)


func onVelocityComputed(safe_velocity):
	velocity = safe_velocity
	previousPosition = global_position 
	global_position += velocity * get_physics_process_delta_time()
