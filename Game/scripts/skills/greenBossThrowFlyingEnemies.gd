extends Node
class_name GreenBossThrowFlyingEnemies

@export var startPosition:Vector2

@export var rotationSpeed:float = 2*PI # in radians / s
@export var skillOwner:Node2D
@export var phase:Phase = Phase.PRE_ATTACK
@export var preChargeSpeed:float = 3000
@export var chargeSpeed:float = 2000

@export var flyingEnemies:Array[Node2D]
@export var flyingEnemiesRadius:float = 1000
@export var flyingEnemiesAngle:float = 2.0/4.0*PI
var flyingEnemiesTargets:Array[Vector2]
var isFlyingEnemyMoving:Array[bool] = []

@export var preEndDelay:float = 2.0
@export var throwDelay:float = 0.3

enum Phase { PRE_ATTACK, ATTACKING, FINISHED }

signal onEnd()
signal onPreCharge()
signal onCharge()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func goFastToPosition(entity:Node2D, targetPos:Vector2, desiredDistance:float = 100, maxSpeed:float = 3000, maxSpeedDistance:float = 500):
	var speed
	var d = entity.global_position.distance_to(targetPos)
	if (d > maxSpeedDistance):
		speed = maxSpeed
	elif (d < desiredDistance):
		speed = 0
		entity.velocity = Vector2.ZERO
		return true
	else:
		#var ratio = (d - 100)/(500-100)
		var ratio = d/maxSpeedDistance
		speed = lerpf(0, maxSpeed, clampf(ratio, 0.0, 1.0)) 
		
	#entity.velocity = lerp(0.0, speed, min(1.0, d/desiredDistance)) * entity.global_position.direction_to(targetPos)

	entity.velocity = entity.global_position.direction_to(targetPos) * speed
	#skillOwner.global_translate(skillOwner.velocity * get_physics_process_delta_time()) 
	return false

func StopEnemies():
	isFlyingEnemyMoving.resize(flyingEnemies.size())
	for i in range(flyingEnemies.size()):
		isFlyingEnemyMoving[i] = false

func Start():
	phase = GreenBossThrowFlyingEnemies.Phase.PRE_ATTACK
	set_physics_process(true)
	flyingEnemies.shuffle()
	flyingEnemies.erase(skillOwner.ball)
	flyingEnemies.push_front(skillOwner.ball)
	
	StopEnemies()
		
	for i in range(flyingEnemies.size()):
		isFlyingEnemyMoving[i] = true
		await get_tree().create_timer(0.5).timeout

func _physics_process(delta):
	match (phase):
		Phase.PRE_ATTACK:
			var isFinished = goFastToPosition(skillOwner, startPosition, 100, preChargeSpeed, 500)
			
			for i in range(flyingEnemies.size()):
				var flyingEnemy = flyingEnemies[i]
				flyingEnemy.stop()
				#flyingEnemy.velocity = Vector2.ZERO
				
				if (isFlyingEnemyMoving[i]):
					var angle:float = (float(i)/float(flyingEnemies.size()-1)) * flyingEnemiesAngle + (PI-flyingEnemiesAngle)/2
					var hasEnemyFinished = goFastToPosition(flyingEnemy, startPosition + flyingEnemiesRadius * Vector2(cos(angle), sin(angle)), 10, preChargeSpeed, 500)
					isFinished = isFinished and hasEnemyFinished
				else:
					isFinished = false

			if (isFinished):
				for flyingEnemy in flyingEnemies:
					flyingEnemy.velocity = Vector2.ZERO
				skillOwner.velocity = Vector2.ZERO
				
				phase = Phase.ATTACKING
				onCharge.emit()
				
				flyingEnemiesTargets.resize(flyingEnemies.size())
				StopEnemies()
				for i in range(flyingEnemies.size()):
					isFlyingEnemyMoving[i] = true
					# use global coordinates, not local to node
					var space_state = skillOwner.get_world_2d().direct_space_state
					
					var from = flyingEnemies[i].global_position
					var dir = from.direction_to(skillOwner.target.global_position)
					var to = from + dir * 10000
					var query = PhysicsRayQueryParameters2D.create(from, to, 1, [flyingEnemies[i]])
					var result = space_state.intersect_ray(query)
					if (result):
						flyingEnemiesTargets[i] = result.position - dir * flyingEnemies[i].radius
					
					await get_tree().create_timer(throwDelay).timeout
					
				#await get_tree().create_timer(duration).timeout
				#timer.stop()
				await get_tree().create_timer(preEndDelay).timeout
				for flyingEnemy in flyingEnemies:
					flyingEnemy.resume()
				for i in range(flyingEnemies.size()):
					isFlyingEnemyMoving[i] = false
				phase = Phase.FINISHED
				onEnd.emit()
				
		Phase.ATTACKING:
			for i in range(flyingEnemies.size()):
				if (isFlyingEnemyMoving[i]):
					var dist = flyingEnemies[i].global_position.distance_to(flyingEnemiesTargets[i])
					flyingEnemies[i].velocity = lerp(0.0, 3500.0, min(1.0, dist/100)) * flyingEnemies[i].global_position.direction_to(flyingEnemiesTargets[i]) 

