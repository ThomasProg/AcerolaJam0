extends Node
class_name BossSpawnEnemies

@export var skillOwner:Node2D
@export var phase:Phase = Phase.HINT
@export var target:Node2D
@export var enemySpawnSpeed:float = 3000
@export var hintDuration = 2.0

@export var enemyPrefab:PackedScene

enum Phase { HINT, SPAWN_ENEMY, FINISHED }

signal onEnemySpawned(enemy)
signal onEnd()

var baseScale:Vector2

func _ready():
	set_physics_process(false)
	
	match SaveManager.currentCheckpoint.difficulty:
		0:
			hintDuration = 3.0
		1:
			hintDuration = 2.1
		2:
			hintDuration = 1.8

func SpawnEnemy(angVelocity:float = 0):
	var spike = enemyPrefab.instantiate() as Node2D
	spike.global_position = skillOwner.global_position
	skillOwner.get_parent().add_child(spike)
	if (spike is RigidBody2D):
		spike.linear_velocity = enemySpawnSpeed * skillOwner.global_position.direction_to(target.global_position)
		spike.angular_velocity = angVelocity
		
	onEnemySpawned.emit(spike)
	return spike
		

func Start():
	time = 0.0
	baseScale = skillOwner.scale
	phase = Phase.HINT
	set_physics_process(true)
	await get_tree().create_timer(hintDuration).timeout
	phase = Phase.SPAWN_ENEMY
	
	time = 0.0
	#var v = 1000
	
	SpawnEnemy(PI*5)
	#SpawnEnemy(Vector2(v, -100), PI)
	#SpawnEnemy(Vector2(-v, -100), PI)
	
	await get_tree().create_timer(1.0).timeout
	skillOwner.scale = baseScale
	onEnd.emit()

var time:float = 0.0
func _physics_process(delta):
	time += delta
	
	match (phase):
		Phase.HINT:
			skillOwner.angularVelocity = lerp(0.0, 2*PI * 1.0, time/2.0)
			skillOwner.scale = lerp(baseScale, Vector2(1, 1), time/2.0)
		Phase.SPAWN_ENEMY:
			skillOwner.scale = lerp(Vector2(1, 1), baseScale, min(1.0, time/0.5))
