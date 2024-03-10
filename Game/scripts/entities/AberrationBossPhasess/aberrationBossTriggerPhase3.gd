extends Area2D
class_name AberrationBossTriggerPhase3

@export var enemyToSpawn:PackedScene
@export var direction = Vector2.RIGHT
@export var speed = 8000

var boss:AberrationBoss

func spawnEnemy():
	await get_tree().process_frame
	var enemy = enemyToSpawn.instantiate() as Node2D
	enemy.position = boss.global_position
	boss.get_parent().add_child(enemy)
	
	var bumpedEffect = BumpedEffect.new()
	bumpedEffect.skillOwner = enemy
	bumpedEffect.speed = speed
	bumpedEffect.damping = 8000.0
	bumpedEffect.direction = direction.normalized() #boss.velocity.normalized()
	enemy.add_child(bumpedEffect)

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(func(body):
		spawnEnemy()
		, CONNECT_ONE_SHOT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

