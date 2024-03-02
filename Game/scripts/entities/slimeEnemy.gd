extends CharacterBody2D

@export var target: Node2D
@export var speed: float = 500

@onready var navAgent: NavigationAgent2D = $NavigationAgent2D

var startLinkPos:Vector2
var endLinkPos:Vector2

var jumpDirection:Vector2 = Vector2.ZERO

@onready var jump: Jump = $Jump
@onready var timer: Timer = $Timer

@export var state = Player.State.IDLE

enum SlimeState { DEFAULT, BEFORE_LINK, IN_LINK }

@export var slimeState:SlimeState = SlimeState.DEFAULT

# Called when the node enters the scene tree for the first time.
func _ready():
	navAgent.path_desired_distance = 100.0
	navAgent.target_desired_distance = 4.0

	set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	set_physics_process(true)
	
	navAgent.link_reached.connect(func(dict):
		slimeState = SlimeState.BEFORE_LINK
		startLinkPos = dict.position
		endLinkPos = dict.link_exit_position
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
var nextPos:Vector2 = Vector2.ZERO
	
func computeNextDirection():
	navAgent.target_position = target.global_position
	
	if navAgent.is_navigation_finished():
		return Vector2.ZERO
	
	match (slimeState):
		SlimeState.DEFAULT:
			nextPos = navAgent.get_next_path_position()
		SlimeState.BEFORE_LINK:
			nextPos = startLinkPos
		SlimeState.IN_LINK:
			nextPos = endLinkPos

	var dir = (nextPos - global_position)
	dir.y = 0
	dir = dir.normalized()
	dir *= speed
	return dir

func _physics_process(delta):	
	state = jump.tryStartJump(state)
		
	state = jump.processJump(delta, state)
	
	if (!is_on_floor()):

		if (target != null): 
			velocity.x = jumpDirection.x
			if (slimeState == SlimeState.DEFAULT):
				var nextDirection = computeNextDirection()
				var diff = nextPos - global_position
				
				if (abs(velocity.x*delta) > abs(diff.x)):
					velocity.x = diff.x
					
			if (slimeState == SlimeState.BEFORE_LINK):
				var diff = startLinkPos - global_position
				if (abs(velocity.x * delta) > abs(diff.x)):
					velocity.x = diff.x

			if (slimeState == SlimeState.IN_LINK):
				var diff = endLinkPos - global_position
				if (abs(velocity.x * delta) > abs(diff.x)):
					velocity.x = diff.x				
					
			#else:
			#velocity.x = jumpDirection.x
			
			
			#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
			#velocity.y += gravity * delta
	else:
		velocity.x = 0
		
	move_and_slide()
	
	if (is_on_floor() and target != null):
		if (timer.time_left <= 0):
			timer.start(-1)

func tryToJump():
	if (target == null):
		return
	
	if (is_on_floor()):
		jump.timeSinceJumpPressed = 0.0
		jumpDirection = computeNextDirection()
		move_and_slide()
		
		match (slimeState):
			SlimeState.BEFORE_LINK:
				slimeState = SlimeState.IN_LINK 
			SlimeState.IN_LINK:
				slimeState = SlimeState.DEFAULT 


func _on_timer_timeout():
	tryToJump()
	
func _on_detection_area_body_entered(body):
	if (body is Player):
		target = body
		if (timer.time_left <= 0):
			tryToJump()
			
