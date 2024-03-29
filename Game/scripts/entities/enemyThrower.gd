extends Node2D

@export var instantiated: PackedScene
@export var amount: int = 10
@export var onDuration:float = 2.0
@export var offDuration:float = 2.0
@export var force:float = 100.0
@export var maxSpeed:float = 3000.0
@export var initialDelay:float = 0.0
@export var deltaAngle:float = 60 # Degrees
@export var target:Node2D = null
@export var threwDmg:float = 0.25

@onready var timer:Timer=$Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(initialDelay).timeout
	timer.start(onDuration + offDuration)
	throwEnemies()

func throwEnemies():
	for i in range(amount):
		var newEnemy = instantiated.instantiate() as FallingEnemy
		newEnemy.useGravity = true
		var direction:Vector2 = Vector2(0, 1)
		if (target != null):
			direction = target.global_position - global_position
		
		newEnemy.velocity = direction.rotated(deg_to_rad(-deltaAngle)).slerp(direction.rotated(deg_to_rad(deltaAngle)), randf())
		
		newEnemy.velocity = newEnemy.velocity.normalized() * force
		newEnemy.maxSpeed = maxSpeed
		
		if ("dmg" in newEnemy):
			newEnemy.dmg = threwDmg
		
		newEnemy.skillOwner = self
		
		add_child(newEnemy)
		await get_tree().create_timer(onDuration / amount).timeout


func _on_timer_timeout():
	throwEnemies()
