extends CharacterBody2D
class_name GreenBoss

@export var anchor1:Node2D
@export var anchor2:Node2D
@export var centerAnchor:Node2D
@export var flyingEnemies:Array[FlyingEnemy]

@export var target:Node2D
@export var ball:Node2D
var time:float = 0.0

@export var isBerserk:bool = false

@onready var throwFallingEnemies:GreenBossThrowFallingEnemies = $ThrowFallingEnemies
@onready var angularThrowEnemies:GreenBossAngularThrowEnemies = $AngularThrowEnemies
@onready var throwFlyingEnemies:GreenBossThrowFlyingEnemies = $ThrowFlyingEnemies


enum Phase { IDLE, THROW_FALLING_ENEMIES, ANGULAR_THROW_ENEMIES, THROW_FLYING_ENEMIES }

@export var phase = Phase.IDLE
@export var delayBetweenPhases:float = 2.0 

@onready var health:Health = $Health

# UI
@onready var bossUI:Node = $CanvasLayer
@onready var bossProgressBar:ProgressBar = $CanvasLayer/MarginContainer/VBoxContainer/ProgressBar
@onready var bossLabel:RichTextLabel = $CanvasLayer/MarginContainer/VBoxContainer/RichTextLabel

@export var endDialogue:DialogicTimeline

func startThrowFlyingEnemies():
	throwFlyingEnemies.flyingEnemies = flyingEnemies
	throwFlyingEnemies.startPosition = centerAnchor.global_position
	throwFlyingEnemies.Start()

func startThrowFallingEnemies():
	throwFallingEnemies.phase = GreenBossThrowFallingEnemies.Phase.PRE_CHARGE
	throwFallingEnemies.ball = ball
	(throwFallingEnemies.ball as FlyingEnemy).stop()
	
	throwFallingEnemies.set_physics_process(true)
	var d1 = anchor1.global_position.distance_squared_to(global_position) 
	var d2 = anchor2.global_position.distance_squared_to(global_position) 
	if (d1 < d2):
		throwFallingEnemies.startPosition = anchor1.global_position
		throwFallingEnemies.endPosition = anchor2.global_position
	else:
		throwFallingEnemies.startPosition = anchor2.global_position
		throwFallingEnemies.endPosition = anchor1.global_position
		
	throwFallingEnemies.Start()

func startAngularThrow():
	angularThrowEnemies.phase = GreenBossAngularThrowEnemies.Phase.PRE_ATTACK
	angularThrowEnemies.set_physics_process(true)
	angularThrowEnemies.flyingEnemies = flyingEnemies
	angularThrowEnemies.flyingEnemies.shuffle()
	angularThrowEnemies.startPosition = centerAnchor.global_position



func selectNextPhase():
	if (isBerserk):
		match(phase):
			Phase.THROW_FALLING_ENEMIES:
				var potentialNewPhases = [
					Phase.THROW_FALLING_ENEMIES, 
					#Phase.ANGULAR_THROW_ENEMIES, 
					#Phase.THROW_FLYING_ENEMIES,
					]
				return potentialNewPhases.pick_random()
			Phase.ANGULAR_THROW_ENEMIES:
				var potentialNewPhases = [
					Phase.THROW_FALLING_ENEMIES, 
					#Phase.ANGULAR_THROW_ENEMIES, 
					#Phase.THROW_FLYING_ENEMIES,
					]
				return potentialNewPhases.pick_random()
				
	if (phase == Phase.THROW_FLYING_ENEMIES):
		var potentialNewPhases = [
			Phase.THROW_FALLING_ENEMIES, 
			#Phase.ANGULAR_THROW_ENEMIES, 
			#Phase.THROW_FLYING_ENEMIES,
			]
		return potentialNewPhases.pick_random()

	# Select random new Phase
	# that isn't the same as the previous one
	var potentialNewPhases = [
		Phase.THROW_FALLING_ENEMIES, 
		Phase.ANGULAR_THROW_ENEMIES, 
		Phase.THROW_FLYING_ENEMIES,
		]
	potentialNewPhases.erase(phase)
	return potentialNewPhases.pick_random()

func startNextPhase():
	phase = selectNextPhase()
	
	match (phase):
		Phase.THROW_FALLING_ENEMIES:
			startThrowFallingEnemies()
		Phase.ANGULAR_THROW_ENEMIES:
			startAngularThrow()
		Phase.THROW_FLYING_ENEMIES:
			startThrowFlyingEnemies()

func setTarget(newTarget):
	if (target == null):
		target = newTarget
		startNextPhase()

func onPhaseEnd():
	angularThrowEnemies.set_physics_process(false)
	throwFallingEnemies.set_physics_process(false)
	get_tree().create_timer(delayBetweenPhases)
	startNextPhase()

var nbThrownFlyingEnemyInARow:int = 0
func onThrownFlyingEnemy():
	nbThrownFlyingEnemyInARow += 1
	if (nbThrownFlyingEnemyInARow >= 2):
		nbThrownFlyingEnemyInARow = 0
		onPhaseEnd()
	else:
		startThrowFlyingEnemies()

func _ready():
	angularThrowEnemies.skillOwner = self
	angularThrowEnemies.set_physics_process(false)
	angularThrowEnemies.onEnd.connect(onPhaseEnd)
	
	throwFlyingEnemies.skillOwner = self
	throwFlyingEnemies.set_physics_process(false)
	throwFlyingEnemies.onEnd.connect(onThrownFlyingEnemy)
	
	throwFallingEnemies.skillOwner = self
	throwFallingEnemies.set_physics_process(false)
	throwFallingEnemies.onEnd.connect(onPhaseEnd)
	
	await get_tree().process_frame
	
	health.onDamage.connect(func(attacker:Node):
		#if (health.life < health.maxLife * 0.50):
			#isBerserk = true
			#charging = $ChargingBerserk
			#spawnEnemies = $BossSpawnEnemiesBerserk
			#growSpikes = $GrowSpikesBerserk
			
		bossProgressBar.min_value = 0
		bossProgressBar.max_value = health.maxLife
		bossProgressBar.value = health.life
		)
	
	health.onDeath.connect(func(killer:Node):
		SaveManager.currentCheckpoint.hasBeatenGreenBoss = true
		SaveManager.saveLastCheckpoint()
		
		Dialogic.start(endDialogue)
		get_viewport().set_input_as_handled()
		#remove_child(bossUI)
		#get_parent().add_child(bossUI)
		#bossProgressBar.value = 0
		#bossLabel.text = "[center]This is the end of the demo\nThanks for playing![/center]"
		)
	
	#startCharge()
	
	#startAngularThrow()
	#startNextPhase()
	#startThrowFlyingEnemies()

func _physics_process(delta):
	#time += delta
	#ball.global_position += lerp(Vector2(1000, 0), Vector2(-1000, 0), (sin(time) + 1) / 2.0) * delta
	#ball.target = target
	move_and_slide()
