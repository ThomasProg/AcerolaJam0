extends CharacterBody2D

@export var chargeAnchor1:Node2D
@export var chargeAnchor2:Node2D

@export var spikesAnchor1:Node2D
@export var spikesAnchor2:Node2D

@export var target:Node2D
@export var isBerserk:bool = false

@onready var charging:Charging = $Charging
@onready var growSpikes:GrowSpikes = $GrowSpikes
@onready var spawnEnemies:BossSpawnEnemies = $BossSpawnEnemies

@onready var health:Health = $Health

# UI
@onready var bossUI:Node = $CanvasLayer
@onready var bossProgressBar:ProgressBar = $CanvasLayer/MarginContainer/VBoxContainer/ProgressBar
@onready var bossLabel:RichTextLabel = $CanvasLayer/MarginContainer/VBoxContainer/RichTextLabel

var angularVelocity:float = 0.0
var angularVelocityDampening:float = 2*PI

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


enum Phase { IDLE, CHARGING, GROW_SPIKES, SPAWN_ROTATING_ENEMIES }

@export var phase = Phase.IDLE
@export var delayBetweenPhases:float = 2.0 

@export var endDialogue:DialogicTimeline

var rotatingEnemies:Array[Node2D] = []

func startCharge():
	charging.phase = Charging.Phase.PRE_CHARGE
	charging.set_physics_process(true)
	
	var d1 = chargeAnchor1.global_position.distance_squared_to(global_position) 
	var d2 = chargeAnchor2.global_position.distance_squared_to(global_position) 
	if (d1 < d2):
		charging.startPosition = chargeAnchor1.global_position
		charging.endPosition = chargeAnchor2.global_position
	else:
		charging.startPosition = chargeAnchor2.global_position
		charging.endPosition = chargeAnchor1.global_position

func startGrowSpikes():
	growSpikes.p1 = spikesAnchor1.global_position
	growSpikes.p2 = spikesAnchor2.global_position
	growSpikes.forceSpikesAround.clear()
	growSpikes.forceSpikesAround.push_back(chargeAnchor1.global_position)
	growSpikes.forceSpikesAround.push_back(chargeAnchor2.global_position)
	growSpikes.forceSpikesAround.push_back(global_position)
	growSpikes.onSpikesGrow.connect(func():
		for rotatingEnemy in rotatingEnemies:
			if (rotatingEnemy != null):
				for child in rotatingEnemy.get_children():
					if (child is Health):
						child.dealDamages(child.life, self)
		rotatingEnemies.clear()
		)
	growSpikes.Start()

func selectNextPhase():
	if (isBerserk):
		match(phase):
			Phase.SPAWN_ROTATING_ENEMIES:
				var potentialNewPhases = [
					Phase.CHARGING, 
					#Phase.GROW_SPIKES, 
					#Phase.SPAWN_ROTATING_ENEMIES,
					]
				return potentialNewPhases.pick_random()
			Phase.GROW_SPIKES:
				var potentialNewPhases = [
					Phase.CHARGING, 
					#Phase.GROW_SPIKES, 
					#Phase.SPAWN_ROTATING_ENEMIES,
					]
				return potentialNewPhases.pick_random()

	# Select random new Phase
	# that isn't the same as the previous one
	var potentialNewPhases = [
		Phase.CHARGING, 
		Phase.GROW_SPIKES, 
		Phase.SPAWN_ROTATING_ENEMIES,
		]
	potentialNewPhases.erase(phase)
	return potentialNewPhases.pick_random()

func startNextPhase():
	phase = selectNextPhase()
	
	match (phase):
		Phase.CHARGING:
			startCharge()
		Phase.GROW_SPIKES:
			startGrowSpikes()
		Phase.SPAWN_ROTATING_ENEMIES:
			spawnEnemies.target = target
			spawnEnemies.onEnemySpawned.connect(func(enemy):
				rotatingEnemies.push_back(enemy)
			)
			spawnEnemies.Start()

func onPhaseEnd():
	get_tree().create_timer(delayBetweenPhases)
	startNextPhase()

func setTarget(newTarget):
	if (target == null):
		target = newTarget
		startNextPhase()

func _ready():
	match SaveManager.currentCheckpoint.difficulty:
		0:
			delayBetweenPhases = 3.0
		1:
			delayBetweenPhases = 2.1
		2:
			delayBetweenPhases = 1.8
	
	var skills:Array[Node] = [
		$Charging, 
		$ChargingBerserk, 
		$BossSpawnEnemies, 
		$BossSpawnEnemiesBerserk,
		$GrowSpikes,
		$GrowSpikesBerserk,
		]
	
	for skill in skills:
		skill.set_physics_process(false)
		skill.skillOwner = self
		skill.onEnd.connect(func(): 
			skill.set_physics_process(false)
			onPhaseEnd()
			)
			
	health.onDamage.connect(func(attacker:Node):
		if (health.life < health.maxLife * 0.50):
			isBerserk = true
			charging = $ChargingBerserk
			spawnEnemies = $BossSpawnEnemiesBerserk
			growSpikes = $GrowSpikesBerserk
			
		bossProgressBar.min_value = 0
		bossProgressBar.max_value = health.maxLife
		bossProgressBar.value = health.life
		)
			
	health.onDeath.connect(func(killer:Node):
		SaveManager.currentCheckpoint.hasBeatenRedBoss = true
		SaveManager.saveLastCheckpoint()
		
		Dialogic.start(endDialogue)
		get_viewport().set_input_as_handled()
		
		for rotatingEnemy in rotatingEnemies:
			if (rotatingEnemy != null):
				rotatingEnemy.queue_free()
				
		rotatingEnemies.clear()
			
		for spike in $GrowSpikes.spikes:
			if (spike != null):
				spike.queue_free()
				
		$GrowSpikes.spikes.clear()
				
		for spikeParticle in $GrowSpikes.spikesParticles:
			spikeParticle.queue_free()
		$GrowSpikes.spikesParticles.clear()
		
		for spike in $GrowSpikesBerserk.spikes:
			if (spike != null):
				spike.queue_free()
				
		$GrowSpikesBerserk.spikes.clear()
		
		for spikeParticle in $GrowSpikesBerserk.spikesParticles:
			spikeParticle.queue_free()
		$GrowSpikesBerserk.spikesParticles.clear()
		
		#remove_child(bossUI)
		#get_parent().add_child(bossUI)
		#bossProgressBar.value = 0
		#bossLabel.text = "[center]This is the end of the demo\nThanks for playing![/center]"
		)


func _physics_process(delta):
	rotate(angularVelocity * delta)
	if (angularVelocityDampening * delta < abs(angularVelocity)):
		angularVelocity -= signf(angularVelocity) * angularVelocityDampening * delta
	else:
		angularVelocity = 0.0
	move_and_slide()
