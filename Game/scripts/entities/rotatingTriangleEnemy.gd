extends RigidBody2D

@export var target: Node2D
@export var dir:float = 0.0 
@export var isForceAdded:bool = false

@export var points:Array[Node2D]	
@export var fixPoint:Node2D

@export var joint:PinJoint2D

@export var isFollowingPlayer = true
@export var triggers:Array[Area2D]

@onready var navAgent:NavigationAgent2D = $NavigationAgent2D

var isPaused = false

var prevPos:Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	#joint.set_physics_process(false)
	#
	await get_tree().process_frame
	var pos = fixPoint.global_position
	fixPoint.get_parent().remove_child(fixPoint)
	get_parent().add_child(fixPoint)
	fixPoint.global_position = pos
	
	if (!isFollowingPlayer):
		$DetectionArea.queue_free()
	
	if (!triggers.is_empty()):
		isPaused = true
		for trigger in triggers:
			trigger.body_entered.connect(func(body:Node2D):
				if body is Player:
					isPaused = false
				)
	#addRotationForce()

func addRotationForce(newDir:float):
	add_constant_force(Vector2(newDir*600, -700))
	add_constant_torque(newDir*100000)

func removeRotationForce(newDir:float):
	add_constant_force(-Vector2(newDir*600, -700))
	add_constant_torque(-newDir*100000)
	
func addRotationImpulse(newDir:float):
	apply_impulse(Vector2(0, -150), Vector2(newDir*500, 200))
	apply_impulse(Vector2(dir*2000, 0), Vector2(0, -100))
	
	#apply_torque_impulse((newDir*100000)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
#func _physics_process(delta):

func tryRotateToPlayer():
	if (isPaused):
		return
	
	var isOnFloor:bool = false
	
	if (prevPos != null and prevPos.distance_squared_to(global_position) < 1*1):
		isOnFloor = true
		
	prevPos = global_position
	
	
	if target != null and isOnFloor:
		navAgent.target_position = target.global_position
		var playerDir = signf(navAgent.get_next_path_position().x - global_position.x)
			
		var p = null
		for point in points:
			if (point.global_position.y > global_position.y and is_equal_approx(playerDir, signf(point.global_position.x - global_position.x))):
				p = point 
				
		if (p != null):
			if (joint != null):
				joint.queue_free()
					
			joint = PinJoint2D.new()
			fixPoint.add_child(joint)
			
			joint.set_node_a(self.get_path())
			joint.set_node_b(fixPoint.get_path())
			joint.disable_collision = false
				
			fixPoint.get_parent().remove_child(fixPoint)
			fixPoint.global_position = p.global_position 
			get_parent().add_child(fixPoint)
			
			apply_central_impulse(Vector2(0, -300000))
			isForceAdded = true
			
			await get_tree().create_timer(0.3).timeout
			
			if (joint != null):
				joint.queue_free()


func _on_timer_timeout():
	tryRotateToPlayer()
