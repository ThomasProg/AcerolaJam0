extends Node

@export var boss: AberrationBoss
@export var speed:float = 500

@export var isSkipped = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func start():
	if (isSkipped):
		boss.health.dealDamages(boss.health.maxLife, null)
		boss.runNextPhase()
		return
		
	set_physics_process(true)
	boss.health.onDeath.connect(func(killer:Node):
		boss.velocity = Vector2.ZERO
		boss.runNextPhase()
		, CONNECT_ONE_SHOT)
	
func end():
	queue_free()

func target():
	return boss.target

func _physics_process(delta):
	if (target() == null):
		return
		
	boss.velocity = speed * boss.global_position.direction_to(target().global_position)
