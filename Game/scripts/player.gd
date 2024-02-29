extends CharacterBody2D
class_name Player

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var defaultModulate: Color = Color.WHITE
@export var colorSkills = []
@export var currentColorSkill:Node = null
@export var currentColorSkillIndex:int = 0

@export var speed : float = 3000

@export var jumpVelocityCurve : Curve
@export var jumpDuration : float = 0.3
@export var maxJumpSpeed : float = 850
var durationSinceLastJump : float = 0

@export var fallingWithJumpCurve : Curve

@export var fallingCurve : Curve
@export var fallDurationUntilMaxSpeed : float = 3
@export var maxFallingSpeed : float = 5000
var durationSinceLastFallStart : float = 0

@export var coyotteTime = 0.1
var durationSinceLastFloorTime : float = 0

@export var trailAnchor : Node2D

var direction : float = 0

@export var meleeAttackPrefab : PackedScene
@export var dmgMultiplicator:float = 1

@export var regenerationPerSecond : float = 0

@export var health:Health

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

@export var jumpBufferDuration = 0.13
var timeSinceJumpPressed : float = jumpBufferDuration

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
		timeSinceJumpPressed = 0.0
		
	if state != State.JUMP and durationSinceLastFloorTime < coyotteTime and timeSinceJumpPressed < jumpBufferDuration:
		durationSinceLastJump = 0
		velocity.y = - maxJumpSpeed
		state = State.JUMP

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
func _physics_process(delta):
	
	timeSinceJumpPressed += delta
	durationSinceLastFloorTime += delta
	
	if (state == State.ATTACK):
		return
	
	# Add the gravity.
	if ((not is_on_floor())):
		durationSinceLastJump += delta
		if (velocity.y >= 0):
			if (state != State.FALLING) and (state != State.FALLING_WITH_JUMP):
				state = State.FALLING_WITH_JUMP
				durationSinceLastFallStart = 0
			else:
				durationSinceLastFallStart += delta
				
			if (state == State.FALLING_WITH_JUMP) && !Input.is_action_pressed("jump"): 
				state = State.FALLING
				durationSinceLastFallStart = 0
			
			
			var usedCurve = fallingWithJumpCurve
			if (state == State.FALLING):
				usedCurve = fallingCurve

			var y = usedCurve.sample(durationSinceLastFallStart / fallDurationUntilMaxSpeed)
			velocity.y = y * maxFallingSpeed
		else:
			if (state != State.JUMP):
				state = State.IN_AIR
			var y = jumpVelocityCurve.sample(durationSinceLastJump / jumpDuration)
			velocity.y = -y * maxJumpSpeed / jumpDuration
#			position.y += (y - lastY) * maxJumpSpeed
	else:
		durationSinceLastFloorTime = 0
		if (velocity.x == 0):
			state = State.IDLE
		else:
			state = State.RUN
		
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
		
