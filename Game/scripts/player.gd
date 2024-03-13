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

@onready var healthProgressBar:ProgressBar = $UI/Health/HBoxContainer/HealthProgressBar

@onready var timeLabel: RichTextLabel = $InGameMenu/VBoxContainer/RichTextLabelTime

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

@onready var sprite : Node2D = $Sprite/MeshInstance2D
#@export var playerState : PlayerState

@onready var jump: Jump = $Jump

@onready var pressSpaceToTalkPrefab:PackedScene = load("res://prefabs/ui/pressSpaceToTalk.tscn")
var pressSpaceToTalk:Node2D = null

var dialogueCooldown:float = 0.5
var delaySinceLastDialogue:float = 0.0

func _ready():
	camera.ignore_rotation = true
	colorSkills = [RedPowerUp, GreenPowerUp, BluePowerUp]
	health.onDamage.connect(func(attacker): 
		#defaultModulate = lerp(Color.BLACK, Color.WHITE, health.life / health.maxLife) 
		#if (currentColorSkillIndex == 0):
			#sprite.modulate = defaultModulate
		#)
		playAnim("damaged")
		
		sprite.self_modulate = lerp(Color.BLACK, Color.WHITE, health.life / health.maxLife)
	
		healthProgressBar.min_value = 0.0
		healthProgressBar.max_value = health.maxLife
		healthProgressBar.value = health.life
	)
	
	health.onHeal.connect(func(healer): 
		#defaultModulate = lerp(Color.BLACK, Color.WHITE, health.life / health.maxLife) 
		#if (currentColorSkillIndex == 0):
			#sprite.modulate = defaultModulate
		#)
		
		sprite.self_modulate = lerp(Color.GRAY, Color.WHITE, health.life / health.maxLife) 
	
		healthProgressBar.min_value = 0.0
		healthProgressBar.max_value = health.maxLife
		healthProgressBar.value = health.life
		
		#healthProgressBar.modulate = Color.GREEN
	)
	
	health.onDeath.connect(func(killer): 
		await get_tree().physics_frame
		SaveManager.loadLastCheckpoint()
	)
	
	match (SaveManager.currentCheckpoint.difficulty):
		0: 
			health.maxLife = 8
		1:
			health.maxLife = 5
		2:
			health.maxLife = 3
			
	health.life = health.maxLife
	
	jump.onJump.connect(func():
		playAnim("jump")
		)
		
	jump.onFloor.connect(func():
		playAnim("onFloor")
		)
	
var axisDirection:float = 0.0
func _ProcessMovementInputs(delta):
	var isTalking = processInputs()
	
	if (!isTalking and Dialogic.current_timeline == null):
		# Handle Jump.
		if Input.is_action_just_pressed("jump") and delaySinceLastDialogue > dialogueCooldown and rotateChargeAbility == null:
			jump.timeSinceJumpPressed = 0.0
			
		#state = jump.tryStartJump(state)	

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		axisDirection = Input.get_axis("ui_left", "ui_right")
			
	else:
		axisDirection = 0.0
	
func getTotalVelocity()->Vector2:
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
	
	var addedVelocity = getTotalVelocity()
	addedVelocity.y = min(addedVelocity.y, 0.0)
	totalScore += (getGlobalCenter() + addedVelocity*0.5).distance_to(hook.global_position)
	
	if (getGlobalCenter().y - hook.global_position.y < - 50):
		totalScore += 3000
		
	return totalScore

func searchForHookTarget() -> HookTarget :
	var hookTargets = get_tree().root.find_children("*", "HookTarget", true, false) as Array[HookTarget]
	
	var space_state = get_world_2d().direct_space_state
	hookTargets = hookTargets.filter(func(target:Node2D):
		# Distance should be close
		if (target.global_position.distance_squared_to(getGlobalCenter()) > target.maxDistance * target.maxDistance):
			return false
		
		# should be reached directly (no wall, ceiling, floor, etc)
		var query = PhysicsRayQueryParameters2D.create(getGlobalCenter(), target.global_position)
		query.collision_mask = 1
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		return result.is_empty()
		)
		
	if (hookTargets.is_empty()):
		return null
			
	hookTargets.sort_custom(func(a:Node2D,b:Node2D): 
			return getHookTargetScore(a) < getHookTargetScore(b)
			)

	return hookTargets[0]

func talkToNPC() -> NPC:
	var npcs:Array[NPC] = []
	for body in dialogueTrigger.get_overlapping_bodies():
		if (body != null):
			if body is NPC:
				npcs.push_back(body)
				
	npcs = npcs.filter(func(npc:NPC): return npc.canRunDialogue())
	
	if (!blockDialogue and !npcs.is_empty()):
		npcs.sort_custom(func(a:NPC, b:NPC): 
			return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
			
		return npcs[0]
			
	return null

func getRelativeCenterOffset() -> Vector2:
	return Vector2(0, -50)
	
func getGlobalCenter() -> Vector2:
	return global_position + getRelativeCenterOffset()

func playAnim(animName:String):
	if (rotateChargeAbility != null):
		return
	animationPlayer.stop()
	animationPlayer.play(animName)

func addRotation(addedRotation:float):
	sprite.rotate(addedRotation)
	($CollisionShape2D as Node2D).rotate(addedRotation)

func setRotation(newRotation:float):
	sprite.rotation = newRotation
	($CollisionShape2D as Node2D).rotation = newRotation

func processInputs():
	if Input.is_action_just_pressed("talk") and delaySinceLastDialogue > dialogueCooldown:
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
				attack.global_position = getGlobalCenter()
				#attack.isRight = (direction > 0)
				#attack.isReversed = isAttackReversed
				#attack.direction = Vector2(direction, 0)
				if Input.is_action_just_pressed("dash"):
					attack.direction = Vector2(1, 0)
				if Input.is_action_just_pressed("attack"):
					attack.direction = Vector2(-1, 0)
					
				playAnim("dash")
						#
				attack.damages = attack.damages * dmgMultiplicator
				#isAttackReversed = !isAttackReversed
				attack.setSkillOwner(self)
				get_parent().add_child(attack)
				
				attack.start()
				
				#var previousState = state
				#state = State.ATTACK
				#velocity = Vector2(0,0) + impulseVelocity
				#attack.tree_exiting.connect(func(): state = previousState)
		
		if SaveManager.currentCheckpoint.hasBeatenRedBoss and Input.is_action_just_pressed("rotateChargeAbility") and grapplingHookAbility == null:
			if (rotateChargeAbility == null):
				rotateChargeAbility = RotateChargeAbility.new()
				rotateChargeAbility.skillOwner = self
				rotateChargeAbility.onEnd.connect(func():
					rotateChargeAbility = null, CONNECT_ONE_SHOT	
					)
				add_child(rotateChargeAbility)
				
				animationPlayer.stop()
				
				rotateChargeAbility.start()
			else:
				rotateChargeAbility.stop()
				
		if SaveManager.currentCheckpoint.hasBeatenGreenBoss and Input.is_action_just_pressed("grapplingHookAbility") and rotateChargeAbility == null:
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

var npcTalkingTo
func _process(delta):
	healthProgressBar.modulate = lerp(Color.WHITE, Color.RED, health.invulnerabilityTimeLeft / health.invulnerabilityDuration)
	
	if (Dialogic.current_timeline == null):
		delaySinceLastDialogue += delta
	else:
		delaySinceLastDialogue = 0.0
		
	timeLabel.text = "[center]Time: %.03f[/center]" % SaveManager.chrono 
	currentAttackCooldown -= delta
	health.heal(regenerationPerSecond * delta, self)
	
	_ProcessMovementInputs(delta)
		
	var npc = talkToNPC()
	if (npcTalkingTo != npc and npc != null):
		npcTalkingTo = npc
		
		if (pressSpaceToTalk != null):
			pressSpaceToTalk.queue_free()
		
		pressSpaceToTalk = pressSpaceToTalkPrefab.instantiate() as Node2D
		pressSpaceToTalk.position = Vector2(0, -100) + Vector2(0, -50) * npcTalkingTo.scale.y
		npcTalkingTo.add_child(pressSpaceToTalk)
	
	if (npc == null and pressSpaceToTalk != null):
		npcTalkingTo = null
		pressSpaceToTalk.queue_free()


func _on_normal_button_pressed():
	SaveManager.setDifficulty(0)


func _on_hard_button_pressed():
	SaveManager.setDifficulty(1)


func _on_impossible_button_pressed():
	SaveManager.setDifficulty(2)
