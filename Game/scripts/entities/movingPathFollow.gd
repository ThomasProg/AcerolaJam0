extends PathFollow2D
class_name MovingPathFollow

@export var trigger:Area2D
@export var speed:float = 200.0

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
		progress += speed * delta
