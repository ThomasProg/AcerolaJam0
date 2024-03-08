extends Node
class_name GreenBossThrowFallingEnemies

@export var startPosition:Vector2
@export var endPosition:Vector2
@export var skillOwner:Node2D
@export var phase:Phase = Phase.PRE_CHARGE
@export var preChargeSpeed:float = 3000
@export var chargeSpeed:float = 2000
@export var preEndDelay:float = 2.0

@export var enemyToSpawn:PackedScene
@export var ball:Node2D
@export var rotationSpeed:float = 2.0  # in radians / s

@onready var timer:Timer = $Timer

enum Phase { PRE_CHARGE, CHARGING, PRE_END, FINISHED }

signal onEnd()
signal onPreCharge()
signal onCharge()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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

var angle:float = 0.0
func Start():
	angle = randf_range(0, 2*PI)

func _physics_process(delta):
	angle += delta * rotationSpeed
	goFastToPosition(ball, skillOwner.global_position + 1000 * Vector2(cos(angle), sin(angle)))
	
	match (phase):
		Phase.PRE_CHARGE:
			var isFinished = goFastToPosition(skillOwner, startPosition, 100, preChargeSpeed, 500)
			if (isFinished):
				timer.start()
				phase = Phase.CHARGING
				onCharge.emit()

		Phase.CHARGING:
			#skillOwner.angularVelocity = rotationSpeed * signf(skillOwner.velocity.x)
			var isFinished = goFastToPosition(skillOwner, endPosition, 100, chargeSpeed, 500)
			
			if (isFinished):
				timer.stop()
				phase = Phase.PRE_END
				await get_tree().create_timer(preEndDelay).timeout
				phase = Phase.FINISHED
				onEnd.emit()


func _on_timer_timeout():
	var newEnemy = enemyToSpawn.instantiate() as FallingEnemy
	skillOwner.get_parent().add_child(newEnemy)
	newEnemy.useGravity = true
	newEnemy.global_position = skillOwner.global_position
