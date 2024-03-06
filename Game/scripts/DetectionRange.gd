extends Area2D

@export var shouldNotifyOut:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if (body is Player):
		if (get_parent().has_method("setTarget")):
			get_parent().setTarget(body)
		elif ("target" in get_parent()):
			get_parent().target = body


func _on_body_exited(body):
	if (shouldNotifyOut and body is Player):
		if (get_parent().has_method("setTarget")):
			get_parent().setTarget(null)
		elif ("target" in get_parent()):
			get_parent().target = null
