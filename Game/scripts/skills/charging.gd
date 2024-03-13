extends Node
class_name Charging

@export var startPosition:Vector2
@export var endPosition:Vector2
@export var rotationSpeed:float = 2*PI # in radians / s
@export var skillOwner:Node2D
@export var phase:Phase = Phase.PRE_CHARGE
@export var preChargeSpeed:float = 3000
@export var chargeSpeed:float = 2000
@export var hintDuration:float = 1.5

enum Phase { PRE_CHARGE, HINT, CHARGING, FINISHED }

signal onEnd()
signal onPreCharge()
signal onCharge()

# Called when the node enters the scene tree for the first time.
func _ready():
	match SaveManager.currentCheckpoint.difficulty:
		0:
			hintDuration = 1.5
		1:
			hintDuration = 0.7
		2:
			hintDuration = 0.1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func goFastToPosition(targetPos:Vector2, desiredDistance:float = 100, maxSpeed:float = 3000, maxSpeedDistance:float = 500):
	var speed
	var d = skillOwner.global_position.distance_to(targetPos)
	if (d > maxSpeedDistance):
		speed = maxSpeed
	elif (d < desiredDistance):
		speed = 0
		return true
	else:
		#var ratio = (d - 100)/(500-100)
		var ratio = d/maxSpeedDistance
		speed = lerpf(0, maxSpeed, clampf(ratio, 0.0, 1.0)) 
		
	skillOwner.velocity = skillOwner.global_position.direction_to(targetPos) * speed
	#skillOwner.global_translate(skillOwner.velocity * get_physics_process_delta_time()) 
	return false

func _physics_process(delta):
	match (phase):
		Phase.PRE_CHARGE:
			var isFinished = goFastToPosition(startPosition, 100, preChargeSpeed, 500)
			if (isFinished):
				phase = Phase.HINT
				await get_tree().create_timer(hintDuration).timeout
				phase = Phase.CHARGING
				onCharge.emit()

		Phase.HINT:
			skillOwner.velocity = Vector2.ZERO
			skillOwner.angularVelocity = rotationSpeed * signf(skillOwner.global_position.direction_to(endPosition).x)

		Phase.CHARGING:
			skillOwner.angularVelocity = rotationSpeed * signf(skillOwner.velocity.x)
			var isFinished = goFastToPosition(endPosition, 100, chargeSpeed, 500)
			
			if (isFinished):
				phase = Phase.FINISHED
				onEnd.emit()
