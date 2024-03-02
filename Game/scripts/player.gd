extends CharacterBody2D
class_name Player

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var defaultModulate: Color = Color.WHITE
@export var colorSkills = []
@export var currentColorSkill:Node = null
@export var currentColorSkillIndex:int = 0

@export var speed : float = 1500

@export var trailAnchor : Node2D

var direction : float = 0

@export var meleeAttackPrefab : PackedScene
@export var dmgMultiplicator:float = 1

@export var regenerationPerSecond : float = 0

@export var health:Health

@onready var camera:Camera2D = $Camera2D

enum State
{
	IDLE,
	RUN, 
	JUMP,
	FALLING_WITH_JUMP, 
	FALLING,
	IN_AIR,
	ATTACK
}

@export var state = State.IDLE

@export var sprite : Sprite2D
#@export var playerState : PlayerState

@onready var jump: Jump = $Jump

func _ready():
	colorSkills = [RedPowerUp, GreenPowerUp, BluePowerUp]
	health.onDamage.connect(func(attacker): 
		#defaultModulate = lerp(Color.BLACK, Color.WHITE, health.life / health.maxLife) 
		#if (currentColorSkillIndex == 0):
			#sprite.modulate = defaultModulate
		#)
		sprite.self_modulate = lerp(Color.BLACK, Color.WHITE, health.life / health.maxLife)
	)
	
	health.onHeal.connect(func(healer): 
		#defaultModulate = lerp(Color.BLACK, Color.WHITE, health.life / health.maxLife) 
		#if (currentColorSkillIndex == 0):
			#sprite.modulate = defaultModulate
		#)
		
		sprite.self_modulate = lerp(Color.BLACK, Color.WHITE, health.life / health.maxLife) 
	)
	
	#playerState.onDeath.connect(func(playerState): 
		#direction = 0
		#velocity.x = 0
	#)
	
func _ProcessMovementInputs(delta):
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		jump.timeSinceJumpPressed = 0.0
		
	state = jump.tryStartJump(state)	
	#
	#if state != State.JUMP and jump.durationSinceLastFloorTime < jump.coyotteTime and jump.timeSinceJumpPressed < jump.jumpBufferDuration:
		#jump.durationSinceLastJump = 0
		#velocity.y = - jump.maxJumpSpeed
		#state = State.JUMP

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
func _physics_process(delta):
			
	state = jump.processJump(delta, state)
		
	#if (!playerState.isDead):
	_ProcessMovementInputs(delta)

	move_and_slide()

var isAttackReversed = false

#func _ready():
	#availableColors = [PlayerColor.DEFAULT, redColor, greenColor, blueColor]

func _process(delta):
	health.heal(regenerationPerSecond * delta, self)
	
	if Input.is_action_just_pressed("attack") and state != State.ATTACK:
		var attack = meleeAttackPrefab.instantiate() as MeleeAttack
		add_child(attack)
		attack.setSkillOwner(self)
		attack.isRight = (direction > 0)
		attack.isReversed = isAttackReversed
		attack.damages = attack.damages * dmgMultiplicator
		isAttackReversed = !isAttackReversed
		var previousState = state
		state = State.ATTACK
		velocity = Vector2(0,0)
		attack.tree_exiting.connect(func(): state = previousState)
		
	if Input.is_action_just_pressed("changeColor"):
		currentColorSkillIndex = (currentColorSkillIndex + 1) % (colorSkills.size() + 1)
		if (currentColorSkill != null):
			currentColorSkill.onRemoved()
			currentColorSkill.queue_free()
		
		if (currentColorSkillIndex == 0):
			sprite.modulate = defaultModulate
		else:
			currentColorSkill = colorSkills[currentColorSkillIndex - 1].new()
			currentColorSkill.setSkillOwner(self)
		#sprite.modulate = availableColors[currentColor]
		
