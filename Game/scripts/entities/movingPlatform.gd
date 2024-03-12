extends MeshInstance2D
class_name MovingPlatform

@export var trigger:Area2D
@export var speed:float = 200.0
@export var pathFollow2D:PathFollow2D
@onready var body:AnimatableBody2D = $AnimatableBody2D

var isMoving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if (trigger != null):
		trigger.body_entered.connect(func(body): startMoving(), CONNECT_ONE_SHOT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func startMoving():
	isMoving = true
	
func _physics_process(delta):
	if (isMoving):
		pathFollow2D.progress += speed * delta
		body.global_position = global_position 
