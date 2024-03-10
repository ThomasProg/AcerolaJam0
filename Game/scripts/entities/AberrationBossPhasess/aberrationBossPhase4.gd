extends Node

@export var boss: AberrationBoss
@export var isSkipped = true

@export var duration:float = 3.0
@onready var timer = $Timer
var time = 0.0

@export var enemyPrefabs:Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	
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
	var enemy = (enemyPrefabs.pick_random() as PackedScene).instantiate() as Node2D
	
	enemy.global_position = boss.target.global_position + Vector2(0, -5000)

	boss.get_parent().add_child(enemy)
