extends Node

@export var entrance:Node2D
@export var exit:Node2D

@export var area:Area2D
@export var boss:GreenBoss

# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(func(body):
		if (body is Player):
			entrance.global_position.x -= 1000
		, CONNECT_ONE_SHOT)

	for child in boss.get_children():
		if (child is Health):
			child.onDeath.connect(func(killer):
				exit.global_position.x -= 2000
				, CONNECT_ONE_SHOT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#func _physics_process(delta):
	
