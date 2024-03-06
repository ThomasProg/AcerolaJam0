extends Node
class_name BossSpawnEnemies

@export var skillOwner:Node2D
@export var phase:Phase = Phase.HINT
@export var target:Node2D
@export var enemySpawnSpeed:float = 3000

@export var enemyPrefab:PackedScene

enum Phase { HINT, SPAWN_ENEMY, FINISHED }

signal onEnemySpawned(enemy)
signal onEnd()

func _ready():
	set_physics_process(false)

func SpawnEnemy(angVelocity:float = 0):
	var spike = enemyPrefab.instantiate() as Node2D
	skillOwner.get_parent().add_child(spike)
	spike.global_position = skillOwner.global_position
	if (spike is RigidBody2D):
		spike.linear_velocity = enemySpawnSpeed * skillOwner.global_position.direction_to(target.global_position)
		spike.angular_velocity = angVelocity
		
	onEnemySpawned.emit(spike)
	return spike
		

func Start():
	phase = Phase.HINT
	set_physics_process(true)
	await get_tree().create_timer(2.0).timeout
	phase = Phase.SPAWN_ENEMY
	
	#var v = 1000
	
	SpawnEnemy(PI*5)
	#SpawnEnemy(Vector2(v, -100), PI)
	#SpawnEnemy(Vector2(-v, -100), PI)
	
	await get_tree().create_timer(1.0).timeout
	onEnd.emit()

func _physics_process(delta):
	skillOwner.angularVelocity = 2*PI
