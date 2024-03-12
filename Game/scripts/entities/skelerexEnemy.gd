extends CharacterBody2D

@export var target:Node2D

@export var maxSpeed:float = 2300.0
@export var speed:float = 1800.0
@export var healSpeed:float = 3.0


@onready var health:Health = $Health
@onready var navAgent:NavigationAgent2D = $NavigationAgent2D
@onready var mesh:MeshInstance2D = $MeshInstance2D
@onready var damageArea:Area2D = $DamageArea

func onHealthUpdate():
	speed = lerp(0.0, maxSpeed, health.life / health.maxLife)
	mesh.material.set("shader_parameter/glow", lerp(1.0, 2.0, speed / maxSpeed))
	

func _ready():
	health.onDamage.connect(func(attacker): onHealthUpdate())
	health.onHeal.connect(func(attacker): onHealthUpdate())

func getTargetPos()->Vector2:
	return target.getGlobalCenter()

func _process(delta):
	health.heal(delta * healSpeed, self)

func _physics_process(delta):
	velocity = Vector2.ZERO

	if (target != null):
		navAgent.target_position = getTargetPos()
		if (navAgent.is_target_reachable() and getTargetPos().distance_to(global_position) > speed * delta + 50):
		#if (!navAgent.is_target_reached()):
			velocity = global_position.direction_to(navAgent.get_next_path_position()) * speed			
			navAgent.set_velocity(velocity)

			move_and_slide()
			


