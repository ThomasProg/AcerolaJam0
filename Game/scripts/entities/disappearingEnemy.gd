extends CharacterBody2D

@export var target:Node2D
@export var speed:float = 8000.0
@export var delay:float = 0.4
@export var appearTime:float = 1.0

@onready var health:Health = $Health
@onready var navAgent:NavigationAgent2D = $NavigationAgent2D
@onready var mesh:MeshInstance2D = $MeshInstance2D
@onready var damageArea:Area2D = $DamageArea

var targetPosition:Vector2
var isMoving:bool = false

func getDifficultyMultiplier() -> float:
	match SaveManager.currentCheckpoint.difficulty:
		0:
			return 1.1
		1: 
			return 1.0
		2:
			return 0.9
	
	return 1.0

func _ready():
	disappear()

func appear():
	isMoving = false
	mesh.material.set("shader_parameter/glow", 2.0)
	add_child(health)
	add_child(damageArea)
	
func disappear():
	isMoving = true
	mesh.material.set("shader_parameter/glow", 1.0)
	remove_child(health)
	remove_child(damageArea)

func getTargetPos()->Vector2:
	return target.getGlobalCenter() + Vector2(target.velocity.x * delay * getDifficultyMultiplier(), 0.0)

func _physics_process(delta):
	velocity = Vector2.ZERO
	if (isMoving):
		if (target != null):
			navAgent.target_position = getTargetPos()
			if (navAgent.is_target_reachable() and getTargetPos().distance_to(global_position) > speed * delta + 50):
			#if (!navAgent.is_target_reached()):
				velocity = global_position.direction_to(navAgent.get_next_path_position()) * speed			
				navAgent.set_velocity(velocity)

				move_and_slide()
				
			else: # reached
				isMoving = false
				await get_tree().create_timer(delay*getDifficultyMultiplier()).timeout
				appear()
				await get_tree().create_timer(appearTime*getDifficultyMultiplier()).timeout
				disappear()

