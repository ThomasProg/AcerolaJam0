extends Node
class_name Jump

@export var characterBody: CharacterBody2D

@export var jumpBufferDuration = 0.25
var timeSinceJumpPressed : float = jumpBufferDuration

@export var jumpVelocityCurve : Curve
@export var jumpDuration : float = 0.3
@export var maxJumpSpeed : float = 850
var durationSinceLastJump : float = 0

@export var fallingWithJumpCurve : Curve

@export var fallingCurve : Curve
@export var fallDurationUntilMaxSpeed : float = 2
@export var maxFallingSpeed : float = 5000
var durationSinceLastFallStart : float = 0

@export var coyotteTime = 0.1
var durationSinceLastFloorTime : float = 0

@export var nbMaxAirJumps:int = 0
@export var nbAirJumpsLeft:int = 0

@export var jumpSpeedScale:float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func tryStartJump(state):
	if (characterBody.is_on_floor()):
		nbAirJumpsLeft = nbMaxAirJumps
	
	if state != Player.State.JUMP and durationSinceLastFloorTime < coyotteTime and timeSinceJumpPressed < jumpBufferDuration:
		durationSinceLastJump = 0
		characterBody.velocity.y = - maxJumpSpeed
		state = Player.State.JUMP
		timeSinceJumpPressed = jumpBufferDuration
		
	if (!characterBody.is_on_floor() and timeSinceJumpPressed < jumpBufferDuration and nbAirJumpsLeft > 0):
		durationSinceLastJump = 0
		characterBody.velocity.y = - maxJumpSpeed
		state = Player.State.JUMP
		nbAirJumpsLeft -= 1
		timeSinceJumpPressed = jumpBufferDuration
		
	return state

func processJump(delta, state):
	
	timeSinceJumpPressed += delta
	durationSinceLastFloorTime += delta
	
	#if (state == Player.State.ATTACK):
		#return state
	
	# Add the gravity.
	if (not characterBody.is_on_floor()) or (state == Player.State.JUMP):
		durationSinceLastJump += delta

		#if (characterBody.velocity.y < 0):
		if (state == Player.State.JUMP):
			if (state != Player.State.JUMP):
				state = Player.State.IN_AIR
			var y = jumpSpeedScale * jumpVelocityCurve.sample(durationSinceLastJump / jumpDuration * jumpSpeedScale)
			characterBody.velocity.y = -y * maxJumpSpeed / jumpDuration
			if (characterBody.velocity.y >= 0):
				state = Player.State.IN_AIR
#			position.y += (y - lastY) * maxJumpSpeed
		
		else:
			if (state != Player.State.FALLING) and (state != Player.State.FALLING_WITH_JUMP):
				state = Player.State.FALLING_WITH_JUMP
				durationSinceLastFallStart = 0
			else:
				durationSinceLastFallStart += delta
				
			if (state == Player.State.FALLING_WITH_JUMP) && !Input.is_action_pressed("jump"): 
				state = Player.State.FALLING
				#durationSinceLastFallStart = 0
			
			
			#var usedCurve = fallingWithJumpCurve
			#if (state == Player.State.FALLING):
			var usedCurve = fallingCurve

			var y = usedCurve.sample(clamp(durationSinceLastFallStart / fallDurationUntilMaxSpeed, 0.0, 1.0))
			characterBody.velocity.y = y * maxFallingSpeed
	else:
		durationSinceLastFloorTime = 0
		if (characterBody.velocity.x == 0):
			state = Player.State.IDLE
		else:
			state = Player.State.RUN

	return state
