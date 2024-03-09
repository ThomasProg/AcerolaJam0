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

@export var grapplingHookVelocity:Vector2 = Vector2.ZERO

@export var impulseVelocity:Vector2 = Vector2.ZERO
@export var impulseVelocityDamping:float = 10000

@export var attackCooldown:float = 0.1
var currentAttackCooldown:float = 0.0

@onready var health:Health = $Health

@onready var camera:Camera2D = $Camera2D
@onready var cameraZoomer:CameraZoomManager = $Camera2D/CameraZoomer
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

@onready var pressSpaceToTalkPrefab:PackedScene = load("res://prefabs/ui/pressSpaceToTalk.tscn")
var pressSpaceToTalk:Node2D = null

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
	
var axisDirection:float = 0.0
func _ProcessMovementInputs(delta):
	var isTalking = processInputs()
	
	if (!isTalking and Dialogic.current_timeline == null):
		# Handle Jump.
		if Input.is_action_just_pressed("jump") and rotateChargeAbility == null:
			jump.timeSinceJumpPressed = 0.0
			
		#state = jump.tryStartJump(state)	

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		axisDirection = Input.get_axis("ui_left", "ui_right")
			
	else:
		direction = 0
		velocity.x = 0
	
func getTotalVelocity():
	return velocity + grapplingHookVelocity + impulseVelocity
	
func _physics_process(delta):
	camera.global_scale = Vector2.ONE
			
	state = jump.processJump(delta, state)
		
	if axisDirection:
		direction = signf(axisDirection)
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	state = jump.tryStartJump(state)	
	
	
	velocity += grapplingHookVelocity + impulseVelocity
	
	move_and_slide()
	
	velocity -= impulseVelocity + grapplingHookVelocity
	
	var dampVelocity2 = grapplingHookVelocity.normalized() * impulseVelocityDamping * delta
	if (dampVelocity2.length_squared() < grapplingHookVelocity.length_squared()):
		grapplingHookVelocity -= dampVelocity2
	else:
		grapplingHookVelocity = Vector2.ZERO
		
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
var grapplingHookAbility:GrapplingHookAbility = null

func getHookTargetScore(hook:Node2D):
	var totalScore:float = 0.0
	totalScore += (global_position + getTotalVelocity()*0.5).distance_to(hook.global_position)
	
	if (global_position.y - hook.global_position.y < - 50):
		totalScore += 3000
		
	return totalScore

func searchForHookTarget() -> HookTarget :
	var hookTargets = get_tree().root.find_children("*", "HookTarget", true, false) as Array[HookTarget]
	
	var space_state = get_world_2d().direct_space_state
	hookTargets = hookTargets.filter(func(target:Node2D):
		var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
		query.collision_mask = 1
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		return result.is_empty()
		)
			
	
	hookTargets.sort_custom(func(a:Node2D,b:Node2D): 
			return getHookTargetScore(a) < getHookTargetScore(b)
			)
			
	var usedHook = null
	# Until the distance is correct
	for hook in hookTargets:
		if (hook.global_position.distance_to(global_position) < hook.maxDistance):
			usedHook = hook
			break

	return usedHook

func talkToNPC() -> NPC:
	var npcs:Array[NPC] = []
	for body in dialogueTrigger.get_overlapping_bodies():
		if body is NPC:
			npcs.push_back(body)
			
	if (!blockDialogue and !npcs.is_empty()):
		npcs.sort_custom(func(a:NPC, b:NPC): 
			return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
			
		return npcs[0]
			
	return null

func processInputs():
	if (Input.is_action_just_pressed("openInGameMenu")):
		if (ingameMenu.visible):
			ingameMenu.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		else:
			ingameMenu.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("talk"):
		var npc = talkToNPC()
		if (npc != null):
			var hasRunDialogue = npc.runDialogue()
			if (hasRunDialogue):
				blockDialogue = true
				Dialogic.timeline_ended.connect(func():
					await get_tree().process_frame
					blockDialogue = false
					)
				return true

			
		#elif state != State.ATTACK:
	if Dialogic.current_timeline == null:
		if rotateChargeAbility == null and (Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("dash")):
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
		
		if Input.is_action_just_pressed("rotateChargeAbility") and grapplingHookAbility == null:
			if (rotateChargeAbility == null):
				rotateChargeAbility = RotateChargeAbility.new()
				rotateChargeAbility.skillOwner = self
				add_child(rotateChargeAbility)
				rotateChargeAbility.start()
			else:
				rotateChargeAbility.stop()
				rotateChargeAbility.queue_free()
				rotateChargeAbility = null
				
		if Input.is_action_just_pressed("grapplingHookAbility") and rotateChargeAbility == null:
			if (grapplingHookAbility == null):
				var usedHook = searchForHookTarget() 
						
				if (usedHook != null):
					grapplingHookAbility = GrapplingHookAbility.new()
					grapplingHookAbility.target = usedHook
					grapplingHookAbility.skillOwner = self
					add_child(grapplingHookAbility)
					grapplingHookAbility.start()
			else:
				grapplingHookAbility.stop()
				grapplingHookAbility.queue_free()
				grapplingHookAbility = null
				
		
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
	
	_ProcessMovementInputs(delta)
		
	var npc = talkToNPC()
	if (npc != null and pressSpaceToTalk == null):
		pressSpaceToTalk = pressSpaceToTalkPrefab.instantiate() as Node2D
		npc.add_child(pressSpaceToTalk)
		pressSpaceToTalk.global_position = npc.global_position + Vector2(0, -100) + Vector2(0, -50) * npc.scale.y
	
	if (npc == null and pressSpaceToTalk != null):
		pressSpaceToTalk.queue_free()
