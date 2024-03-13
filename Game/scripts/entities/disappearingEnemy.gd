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

func appearAnimation():
	var animDuration:float = 0.1
	
	var time = 0
	var lerpAlpha = 0.0
	while (!is_equal_approx(lerpAlpha, 1.0)):
		await get_tree().process_frame
		time += get_process_delta_time()
		lerpAlpha = clamp(time / animDuration, 0.0, 1.0)
		mesh.material.set("shader_parameter/glow", lerpf(1.0, 2.0, lerpAlpha))
	
		scale.x = lerpf(0.9, 1.0, lerpAlpha)
		scale.y = scale.x
	
func disappearAnimation():
	var animDuration:float = 0.1
	
	var time = 0
	var lerpAlpha = 0.0
	while (!is_equal_approx(lerpAlpha, 1.0)):
		await get_tree().process_frame
		time += get_process_delta_time()
		lerpAlpha = clamp(time / animDuration, 0.0, 1.0)
		mesh.material.set("shader_parameter/glow", lerpf(2.0, 1.0, lerpAlpha))
		
		scale.x = lerpf(1.0, 0.9, lerpAlpha)
		scale.y = scale.x
	
func appear():
	isMoving = false
	#mesh.material.set("shader_parameter/glow", 2.0)
	appearAnimation()
	add_child(health)
	add_child(damageArea)
	
func disappear():
	isMoving = true
	#mesh.material.set("shader_parameter/glow", 1.0)
	disappearAnimation()
	remove_child(health)
	remove_child(damageArea)

func getTargetPos()->Vector2:
	if (target.rotateChargeAbility != null):
		return target.getGlobalCenter() + target.impulseVelocity * delay * getDifficultyMultiplier()
	elif (target.grapplingHookAbility != null):
		var targetHook = target.grapplingHookAbility.target as Node2D
		var angle = targetHook.global_position.angle_to_point(target.global_position)
		var radius = target.grapplingHookAbility.initialDistance #targetHook.global_position.distance_to(target.global_position)
		
		var proj:float = -target.velocity.dot(targetHook.global_position.direction_to(target.global_position).orthogonal())
		
		var newAngle = angle + target.velocity.length() / radius *  signf(proj) * delay * getDifficultyMultiplier()
		#var newAngle = angle + 1000.0 / radiusd


		return targetHook.global_position + Vector2.RIGHT.rotated(newAngle) * radius
	
		#return target.getGlobalCenter() + target.grapplingHookAbility.computeRadialVelocity() * delay * getDifficultyMultiplier()
	
	else:
		return target.getGlobalCenter() + Vector2(target.velocity.x * delay * getDifficultyMultiplier(), 0.0)

#func _draw():
	#if (target != null):
		#draw_line(to_local(target.getGlobalCenter()), to_local(getTargetPos()), Color.AQUA, 20)
		##draw_line(target.getGlobalCenter(), Vector2.ZERO, Color.AQUA, 100)
		##draw_line(to_local(target.getGlobalCenter()), to_local(target.getGlobalCenter() + target.getTotalVelocity()), Color.RED, 20)
#
		##if (target.grapplingHookAbility != null):
			##draw_line(to_local(target.getGlobalCenter()), to_local(target.getGlobalCenter() + target.grapplingHookAbility.computeRadialVelocity() * delay * getDifficultyMultiplier()), Color.RED, 20)
#


#func _process(delta):
	#queue_redraw()

func _physics_process(delta):
	velocity = Vector2.ZERO
	if (isMoving):
		if (target != null):
			navAgent.target_position = getTargetPos()
			if (!navAgent.is_target_reachable()):
				navAgent.target_position = target.getGlobalCenter()
			
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

