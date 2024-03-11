extends Node

@export var boss: AberrationBoss
@export var isSkipped = true

@export var duration:float = 3.0
@onready var timer = $Timer
var time = 0.0

@export var enemyPrefabs:Array[PackedScene]
var spawnedEnemies:Array[Node2D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	start()
	
func start():
	set_process(true)
	await get_tree().create_timer(duration).timeout
	timer.start()
	#boss.runNextPhase()
	
func end():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	boss.meshInstance.material.set("shader_parameter/glow", lerp(5.0, 1.0, clamp(time / duration, 0.0, 1.0)))

func _physics_process(delta):
	pass


func _on_timer_timeout():
	spawnedEnemies = spawnedEnemies.filter(func(previousEnemy:Node2D):
		if (previousEnemy == null):
			return false
		
		if (boss.target.global_position.x - previousEnemy.global_position.x > 9000):
			previousEnemy.queue_free()
			return false
		
		return true
		)
	
	var enemy = (enemyPrefabs.pick_random() as PackedScene).instantiate() as Node2D
	
	enemy.global_position = boss.target.global_position + boss.target.velocity*0.8 +  Vector2(0, -5000)
	
	var bumpedEffect = BumpedEffect.new()
	bumpedEffect.skillOwner = enemy
	bumpedEffect.speed = 4000
	bumpedEffect.damping = 4000.0
	bumpedEffect.direction = Vector2.DOWN
	enemy.add_child(bumpedEffect)
	spawnedEnemies.push_back(enemy)

	boss.get_parent().add_child(enemy)
