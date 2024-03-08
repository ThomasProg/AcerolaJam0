extends CharacterBody2D
class_name Player

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

@export var impulseVelocity:Vector2 = Vector2.ZERO
@export var impulseVelocityDamping:float = 10000

@export var attackCooldown:float = 0.1
var currentAttackCooldown:float = 0.0

@onready var health:Health = $Health

@onready var camera:Camera2D = $Camera2D
@onready var dialogueTrigger:Area2D = $DialogueTrigger
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer
@onready var ingameMenu: CanvasLayer = $InGameMenu


enum State
{
	IDLE,
	RUN, 
	JUMP,
	FALLING_WITH_JUMP, 
	FALLING,
	IN_AIR,
	#ATTACK
}

@export var state = State.IDLE

@onready var sprite : CanvasItem = $MeshInstance2D
#@export var playerState : PlayerState

@onready var jump: Jump = $Jump

func _ready():
	camera.ignore_rotation = true
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
	
	health.onDeath.connect(func(killer): 
		await get_tree().physics_frame
		SaveManager.loadLastCheckpoint()
	)
	
func _ProcessMovementInputs(delta):
	var isTalking = processInputs()
	
	if (!isTalking and Dialogic.current_timeline == null):
		# Handle Jump.
		if Input.is_action_just_pressed("jump"):
			jump.timeSinceJumpPressed = 0.0
			
		var isJumping = (state == State.JUMP)
			
		state = jump.tryStartJump(state)	

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var axisDirection = Input.get_axis("ui_left", "ui_right")
		if axisDirection:
			direction = signf(axisDirection)
			velocity.x = direction * speed + impulseVelocity.x
		else:
			velocity.x = move_toward(velocity.x, 0, speed) + impulseVelocity.x
			
	else:
		direction = 0
		velocity.x = 0
	
func _physics_process(delta):
	#if Dialogic.current_timeline != null:
		#return
			
	camera.global_scale = Vector2.ONE
			
	state = jump.processJump(delta, state)
		
	_ProcessMovementInputs(delta)
		
	move_and_slide()
	
	var dampVelocity = impulseVelocity.normalized() * impulseVelocityDamping * delta
	if (dampVelocity.length_squared() < impulseVelocity.length_squared()):
		impulseVelocity -= dampVelocity
	else:
		impulseVelocity = Vector2.ZERO

var isAttackReversed = false

#func _ready():
	#availableColors = [PlayerColor.DEFAULT, redColor, greenColor, blueColor]

var blockDialogue = false

var rotateChargeAbility:RotateChargeAbility = null

func processInputs():
	if (Input.is_action_just_pressed("openInGameMenu")):
		ingameMenu.visible = !ingameMenu.visible 
	
	if Input.is_action_just_pressed("talk"):
		var npcs:Array[NPC] = []
		for body in dialogueTrigger.get_overlapping_bodies():
			if body is NPC:
				npcs.push_back(body)
				
		if (!blockDialogue and !npcs.is_empty()):
			npcs.sort_custom(func(a:NPC, b:NPC): 
				return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
				
			var hasRunDialogue = npcs[0].runDialogue()
			if (hasRunDialogue):
				blockDialogue = true
				Dialogic.timeline_ended.connect(func():
					await get_tree().process_frame
					blockDialogue = false
					)
				return true
	
				
		#elif state != State.ATTACK:
	if Dialogic.current_timeline == null:
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("dash"):
			if (currentAttackCooldown < 0.0):
				currentAttackCooldown = attackCooldown
				var attack = meleeAttackPrefab.instantiate() as DashAttack
				get_parent().add_child(attack)
				attack.global_position = global_position
				#attack.isRight = (direction > 0)
				#attack.isReversed = isAttackReversed
				#attack.direction = Vector2(direction, 0)
				if Input.is_action_just_pressed("dash"):
					attack.direction = Vector2(1, 0)
				if Input.is_action_just_pressed("attack"):
					attack.direction = Vector2(-1, 0)
				
				attack.damages = attack.damages * dmgMultiplicator
				#isAttackReversed = !isAttackReversed
				attack.setSkillOwner(self)
				#var previousState = state
				#state = State.ATTACK
				#velocity = Vector2(0,0) + impulseVelocity
				#attack.tree_exiting.connect(func(): state = previousState)
		
		if Input.is_action_just_pressed("rotateChargeAbility"):
			if (rotateChargeAbility == null):
				rotateChargeAbility = RotateChargeAbility.new()
				rotateChargeAbility.skillOwner = self
				add_child(rotateChargeAbility)
				rotateChargeAbility.start()
			else:
				rotateChargeAbility.stop()
				rotateChargeAbility.queue_free()
				rotateChargeAbility = null
		
	#if Input.is_action_just_pressed("changeColor"):
		#currentColorSkillIndex = (currentColorSkillIndex + 1) % (colorSkills.size() + 1)
		#if (currentColorSkill != null):
			#currentColorSkill.onRemoved()
			#currentColorSkill.queue_free()
		#
		#if (currentColorSkillIndex == 0):
			#sprite.modulate = defaultModulate
		#else:
			#currentColorSkill = colorSkills[currentColorSkillIndex - 1].new()
			#currentColorSkill.setSkillOwner(self)

	return false

func _process(delta):
	currentAttackCooldown -= delta
	health.heal(regenerationPerSecond * delta, self)
	
	#processInputs()
		
