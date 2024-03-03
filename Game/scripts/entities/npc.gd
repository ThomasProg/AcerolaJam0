extends CharacterBody2D
class_name NPC

@export var target: Node2D
@export var maxSpeed:float = 1000
@export var walkJumpSpeed:float = 150
@export var normalJumpSpeed:float = 850
@export var nextFloorIsJump:int = 0

@export var state = Player.State.IDLE

@export var dialogues: Array[DialogicTimeline]
@export var currentDialogueIndex:int = 0
@export var repeatLastDialogue:bool = false

@onready var jump: Jump = $Jump
@onready var navAgent: NavigationAgent2D = $NavigationAgent2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal onFloorAndMoving()

func runDialogue():
	if (dialogues.is_empty()):
		return false
	
	if Dialogic.current_timeline != null:
		return false
	
	if (currentDialogueIndex >= dialogues.size()):
		if (repeatLastDialogue):
			currentDialogueIndex = dialogues.size() - 1
		else:
			return false
	
	Dialogic.start(dialogues[currentDialogueIndex])
	get_viewport().set_input_as_handled()
	
	if (currentDialogueIndex < dialogues.size()):
		currentDialogueIndex += 1
		
	return true
	
func pressJumpOnFloor():
	nextFloorIsJump = 1
	await onFloorAndMoving
	nextFloorIsJump = 2
	pressJump()
	
func pressDoubleJumpOnFloor():
	await pressJumpOnFloor()
	await get_tree().create_timer(jump.jumpDuration+0.1).timeout
	pressJump()
	
func pressJump():
	jump.maxJumpSpeed = normalJumpSpeed
	jump.timeSinceJumpPressed = 0.0

func _physics_process(delta):
	if (target != null):
		navAgent.target_position = target.global_position
		
		if navAgent.is_navigation_finished():
			velocity.x = 0.0
		else:
			var dir = (navAgent.get_next_path_position() - global_position)
			dir.y = 0.0
			dir = dir.normalized()
			velocity.x = maxSpeed * dir.x
	else:
		velocity.x = 0.0

	state = jump.tryStartJump(state)
	state = jump.processJump(delta, state)
		
	if (is_on_floor() and abs(velocity.x) > 0.1):
		onFloorAndMoving.emit()
		if (nextFloorIsJump == 0):
			jump.maxJumpSpeed = walkJumpSpeed
			jump.timeSinceJumpPressed = 0.0

	if (!is_on_floor() and nextFloorIsJump == 2):
		nextFloorIsJump = 0

	move_and_slide()
