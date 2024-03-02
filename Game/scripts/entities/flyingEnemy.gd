extends Node2D

@export var accSpeed: float = 50
@export var velocityDecreaseRate: float = 0.9
@export var target: Node2D
@export var velocity: Vector2 = Vector2.ZERO

@onready var navAgent: NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta):
	if (target != null):
		velocity += (target.global_position - global_position).normalized() * accSpeed		
		navAgent.target_position = target.global_position
	else:
		velocity -= velocity * delta * velocityDecreaseRate
			
	navAgent.set_velocity(velocity)
			
	#global_position += velocity * delta


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	global_position += velocity * get_physics_process_delta_time()
