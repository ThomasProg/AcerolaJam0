extends Area2D
class_name Firefly

# Called when the node enters the scene tree for the first time.
func _ready():
	var shader = ($MeshInstance2D as MeshInstance2D).material as ShaderMaterial
	shader.prelo
	#ResourceLoader.load_threaded_request(($MeshInstance2D as MeshInstance2D).material as ShaderMaterial)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
