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
@onready var meleeAttackPrefab:PackedScene = load("res://prefabs/skills/dashAttack.tscn")

@export var impulseVelocity:Vector2 = Vector2.ZERO
@export var impulseVelocityDamping:float = 10000

var blockXUntilJump = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal onFloorAndMoving()

func _ready():
	set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	set_physics_process(true)

func canRunDialogue():
	if (dialogues.is_empty()):
		return false
	
	if Dialogic.current_timeline != null:
		return false
	
	if (currentDialogueIndex >= dialogues.size()):
		if (!repeatLastDialogue):
			currentDialogueIndex = dialogues.size() - 1
		else:
			return false
			
	return true

func runDialogue():
	if (canRunDialogue()):
		Dialogic.start(dialogues[currentDialogueIndex])
		get_viewport().set_input_as_handled()
		
		if (currentDialogueIndex < dialogues.size()):
			currentDialogueIndex += 1
			
		return true
	else:
		return false
	
func pressJumpOnFloor():
	blockXUntilJump = true
	nextFloorIsJump = 1
	await onFloorAndMoving
	nextFloorIsJump = 2
	pressJump()
	
func pressDoubleJumpOnFloor():
	blockXUntilJump = true
	await pressJumpOnFloor()
	await get_tree().create_timer(jump.jumpDuration+0.1).timeout
	pressJump()
	
func pressLongDoubleJumpOnFloor(dashDirection:Vector2):
	blockXUntilJump = true
	await pressJumpOnFloor()
	await get_tree().create_timer(jump.jumpDuration+0.1).timeout
	
	var dash = func():
		var attack = meleeAttackPrefab.instantiate() as DashAttack
		get_parent().add_child(attack)
		attack.global_position = global_position
		attack.direction = dashDirection
		attack.damages = 0
		attack.setSkillOwner(self)
		
	for i in range(3):
		await get_tree().create_timer(0.1).timeout
		dash.call()

	await get_tree().create_timer(0.1).timeout
	pressJump()
	
	for i in range(3):
		await get_tree().create_timer(0.1).timeout
		dash.call()
	
func pressJump():
	blockXUntilJump = false
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
	
	velocity += impulseVelocity
	
	if (blockXUntilJump):
		velocity.x = 0
	
	move_and_slide()
	
	velocity -= impulseVelocity

	var dampVelocity = impulseVelocity.normalized() * impulseVelocityDamping * delta
	if (dampVelocity.length_squared() < impulseVelocity.length_squared()):
		impulseVelocity -= dampVelocity
	else:
		impulseVelocity = Vector2.ZERO
