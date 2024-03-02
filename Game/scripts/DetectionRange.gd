extends Area2D

@export var shouldNotifyOutbool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if (body is Player):
		if ("target" in get_parent()):
			get_parent().target = body


func _on_body_exited(body):
	if (shouldNotifyOutbool and body is Player):
		if ("target" in get_parent()):
			get_parent().target = null
