extends Node

@export var boss: AberrationBoss
@export var positionTarget:Node2D
@export var upperWall:Node2D
@export var bottomWall:Node2D
@export var wallsSpeed:float = 1500
@export var dialogue:DialogicTimeline
@export var wallMoveDirection:Vector2 = Vector2.UP

@export var phaseIndex:int = 0

@export var isSkipped = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)

func start():
	phaseIndex = 0
	set_physics_process(true)
	
	if (isSkipped):
		boss.health.dealDamages(boss.health.maxLife, null)
		boss.runNextPhase()
		phaseIndex = 2

func end():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
		
	match(phaseIndex):
		0:
			if (positionTarget != null and boss.global_position.distance_to(positionTarget.global_position) > 100):
				boss.velocity = 1000 * boss.global_position.direction_to(positionTarget.global_position)
			else:
				phaseIndex = 1
				set_physics_process(false)
				boss.velocity = Vector2.ZERO
				
				Dialogic.start(dialogue)
				get_viewport().set_input_as_handled()
				
				await Dialogic.timeline_ended
				set_physics_process(true)
				boss.runNextPhase()
				phaseIndex = 2
		2:
			if (upperWall != null):
				upperWall.global_position -= delta * wallsSpeed * wallMoveDirection
			if (bottomWall != null):
				bottomWall.global_position += delta * wallsSpeed * wallMoveDirection
