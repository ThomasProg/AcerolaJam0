extends Node
class_name GreenBossAngularThrowEnemies

@export var startPosition:Vector2

@export var rotationSpeed:float = 2*PI # in radians / s
@export var skillOwner:Node2D
@export var phase:Phase = Phase.PRE_ATTACK
@export var preChargeSpeed:float = 3000
@export var chargeSpeed:float = 2000

@export var enemyToSpawn:PackedScene
@export var flyingEnemies:Array[Node2D]
@export var flyingEnemiesRadius:float = 2000

@export var nbEnemies:int = 60
@export var threwEnemiesAngle:float = 3.0/4.0*PI
@export var threwEnemiesSpeed:float = 2000
@export var flyingEnemiesAngle:float = 2.0/4.0*PI

@export var duration:float = 1.5
@export var preEndDelay:float = 2.0

@onready var timer:Timer = $Timer

enum Phase { PRE_ATTACK, ATTACKING, FINISHED }

signal onEnd()
signal onPreCharge()
signal onCharge()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(onTimeout)


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
		
	entity.velocity = entity.global_position.direction_to(targetPos) * speed
	#skillOwner.global_translate(skillOwner.velocity * get_physics_process_delta_time()) 
	return false

func _physics_process(delta):
	match (phase):
		Phase.PRE_ATTACK:
			var isFinished = goFastToPosition(skillOwner, startPosition, 100, preChargeSpeed, 500)
			for i in range(flyingEnemies.size()):
				var angle:float = (float(i)/float(flyingEnemies.size()-1)) * flyingEnemiesAngle + (PI-flyingEnemiesAngle)/2
		
				var flyingEnemy = flyingEnemies[i]
				if (flyingEnemy == null):
					continue
				flyingEnemy.stop()
				var hasEnemyFinished = goFastToPosition(flyingEnemy, startPosition + flyingEnemiesRadius * Vector2(cos(angle), sin(angle)), 10, preChargeSpeed, 500)
				isFinished = hasEnemyFinished and isFinished

			if (isFinished):
				for flyingEnemy in flyingEnemies:
					flyingEnemy.velocity = Vector2.ZERO
				phase = Phase.ATTACKING
				skillOwner.velocity = Vector2.ZERO
				onCharge.emit()
				await get_tree().physics_frame
				timer.start()
				
				
				await get_tree().create_timer(duration).timeout
				timer.stop()
				await get_tree().create_timer(preEndDelay).timeout
				for flyingEnemy in flyingEnemies:
					flyingEnemy.resume()
				phase = Phase.FINISHED
				onEnd.emit()


func onTimeout():
	for i in range(nbEnemies):
		var angle:float = (float(i)/float(nbEnemies)) * threwEnemiesAngle + (PI-threwEnemiesAngle)/2
		
		var newEnemy = enemyToSpawn.instantiate() as FallingEnemy
		newEnemy.useGravity = false
		newEnemy.global_position = skillOwner.global_position
		newEnemy.velocity = threwEnemiesSpeed * Vector2(cos(angle), sin(angle))
		skillOwner.get_parent().add_child(newEnemy)
