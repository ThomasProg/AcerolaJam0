extends Node
class_name GrapplingHookAbility

@export var skillOwner:Player
@export var target:HookTarget
@export var zoomSpeed:float = 0.3

@export var cameraZoomMult:float = 0.7

var initialDistance:float

var debugLine:Line2D 

# Called when the node enters the scene tree for the first time.
func _ready():
	#debugLine = MeshInstance2D.new()
	#debugLine.mesh = ImmediateMesh.new()
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	debugLine.clear_points()
	debugLine.default_color = Color.ROYAL_BLUE
	
	debugLine.add_point(skillOwner.getGlobalCenter())
	debugLine.add_point(target.global_position)

func start():
	initialDistance = skillOwner.global_position.distance_to(target.global_position)
	debugLine = Line2D.new()
	skillOwner.get_parent().add_child(debugLine)
	skillOwner.set_physics_process(false)
	skillOwner.cameraZoomer.startTransition(skillOwner.cameraZoomer.defaultZoom * cameraZoomMult * target.zoomMult, 0.2)
	skillOwner.velocity = skillOwner.getTotalVelocity()
	skillOwner.grapplingHookVelocity = Vector2.ZERO
	
	#baseCameraZoom = skillOwner.camera.zoom
	#skillOwner.camera.zoom /= 1.3

	#if (skillOwner.get_parent().get_children().find(debugLine) == -1):
		#skillOwner.get_parent().add_child(debugLine)

func toVec3(v:Vector2):
	return Vector3(v.x, v.y, 0.0)

func stop():
	#skillOwner.camera.zoom *= 1.3
	skillOwner.cameraZoomer.startTransition(skillOwner.cameraZoomer.defaultZoom, 2.0)
	debugLine.queue_free()
	skillOwner.set_physics_process(true)
	
	# @TODO : skillOwner.impulseVelocity.x = skillOwner.velocity.x doesn't work
	#skillOwner.impulseVelocity.y = skillOwner.velocity.y
	#computeRadialVelocity()
	#skillOwner.impulseVelocity = skillOwner.velocity
	skillOwner.grapplingHookVelocity = skillOwner.velocity
	skillOwner.velocity = Vector2.ZERO
	
	#print("impulse:",skillOwner.impulseVelocity)
	#skillOwner.impulseVelocity.x = 2000
	skillOwner.jump.durationSinceLastFallStart = 0
	set_physics_process(false)


func computeRadialVelocity() -> Vector2:
	if (!skillOwner.impulseVelocity.is_zero_approx()):
		skillOwner.velocity += skillOwner.impulseVelocity 
		skillOwner.impulseVelocity = Vector2.ZERO
	
	var targetToOwner = skillOwner.global_position - target.global_position
	if skillOwner.velocity.is_zero_approx() or targetToOwner.length() < 10: return Vector2.ZERO
	
	var angle = targetToOwner.angle_to(skillOwner.velocity)# acos(targetToOwner.dot(skillOwner.velocity) / (targetToOwner.length() * skillOwner.velocity.length()))
	var radialVelocity = cos(angle) * skillOwner.velocity.length()
	
	return - targetToOwner.normalized() * radialVelocity

func _physics_process(delta):


	#if (skillOwner.is_physics_processing()):
		#skillOwner.velocity = skillOwner.velocity
		#skillOwner.set_physics_process(false)
		
	#skillOwner.set_physics_process(false)
	
	skillOwner.velocity += computeRadialVelocity()

	#debugLine.add_point(skillOwner.global_position + 1000 * sin(angle) * skillOwner.velocity)

	#
	#if (skillOwner.global_position.distance_to(target.global_position) > 1000):
		#skillOwner.global_position = target.global_position + targetToOwner.normalized() * 1000
		#
	#velocity += (target.global_position - skillOwner.global_position).normalized() * 15000 * delta
	#
	skillOwner.velocity.y += 1000* 9.8 * delta
	
	#velocity *= 0.975
	
	skillOwner.move_and_slide()
	var targetPosition = target.global_position + target.global_position.direction_to(skillOwner.global_position) * initialDistance
	var motion = targetPosition - skillOwner.global_position
	skillOwner.move_and_collide(motion)
	
	
	#if (skillOwner.direction)
