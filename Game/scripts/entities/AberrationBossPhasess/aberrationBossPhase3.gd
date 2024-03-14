extends Node

@export var boss: AberrationBoss
@export var pathFollow:PathFollow2D
@export var damageWall:Node2D

@export var triggersParent:Node2D
@export var triggers:Array[AberrationBossTriggerPhase3]

@export var minSpeed:float = 1000.0
@export var maxSpeed:float = 5000.0
@export var defaultSpeedMultiplier:float = 1.0
@export var maxWallSpeed:float = 4000.0

@export var playerMinDist:float = 3000.0
@export var playerMaxDist:float = 6000.0
@export var playerMaxDistOffset:float = 1000.0

@export var wallMaxDist:float = 2000.0
@export var wallDirection:Vector2 = Vector2.RIGHT

@export var isOnX:bool = true
@export var isAxisReversed:bool = false

@export var isSkipped = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	
	for child in triggersParent.get_children():
		triggers.push_back(child)

func start():
	pathFollow.progress = 0
	set_physics_process(true)
	boss.health.heal(boss.health.maxLife * 100, self)
	
	for trigger in triggers:
		trigger.boss = boss
		
	SaveManager.tryChangeMusic(SaveManager.aberrationBossRoomMusic)
		
	if (isSkipped):
		pathFollow.progress_ratio = 1.0
		set_physics_process(false)
		boss.global_position = pathFollow.global_position
		boss.runNextPhase()
	
func end():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if (boss.target == null):
		return
		
	var speed:float = boss.target.speed * defaultSpeedMultiplier
	
	#var playerDistance:float = boss.global_position.distance_to(boss.target.global_position + boss.target.getTotalVelocity())
	var playerDistance:float 
	if (isOnX):
		playerDistance = boss.global_position.x + 2000.0 - (boss.target.global_position.x + boss.target.getTotalVelocity().x)
	else:
		playerDistance = boss.global_position.y - (boss.target.global_position.y)
	
	if (isAxisReversed):
		playerDistance *= -1.0
	
	playerDistance = max(0.0, playerDistance)
	
	if (playerDistance < playerMinDist):
		speed = lerp(speed, maxSpeed, clamp(1.0 - playerDistance/playerMinDist, 0, 1.0))

	if (playerDistance > playerMaxDist):
		speed = lerp(speed, minSpeed, clamp((playerDistance - playerMaxDist)/playerMaxDistOffset, 0, 1.0))
	
	boss.global_position = pathFollow.global_position
	
	var wallSpeed:float = boss.target.speed * defaultSpeedMultiplier
	var wallPlayerDistance:float = damageWall.global_position.distance_to(boss.target.global_position)
	
	if (isOnX):
		wallPlayerDistance -= 250*damageWall.scale.x
	else:
		wallPlayerDistance -= 250*damageWall.scale.y
	
	if (wallPlayerDistance > wallMaxDist):
		wallSpeed = lerp(wallSpeed, maxWallSpeed, clamp((wallPlayerDistance - wallMaxDist)/wallMaxDist, 0, 1.0))
	
	damageWall.global_position += delta * wallSpeed * wallDirection
	
	#damageWall.global_position = boss.global_position + (6000 + damageWall.scale.x * 250) * Vector2.LEFT 
	
	pathFollow.progress += speed * delta

	if (is_equal_approx(pathFollow.progress_ratio, 1.0)):
		set_physics_process(false)
		boss.runNextPhase()
