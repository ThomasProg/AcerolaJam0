extends Area2D

@export var pikeUpTime:float = 1.0
@export var pikeDownTime:float = 1.0
@export var minScale:float = 1.0
@export var maxScale:float = 2.0
@export var activationRatio:float = 0.0

@onready var animPlayer:AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var r = pikeUpTime + pikeDownTime
	
	if (r > pikeDownTime):
		activationRatio = 1.0
	else:
		activationRatio = 0.0
	
	await get_tree().create_timer(randf() * r).timeout
	
	if (r > pikeDownTime):
		#animPlayer.play("pikeDown")	
		animPlayer.play_backwards("pikeUp")
		await get_tree().create_timer(pikeDownTime).timeout
	
	while (true):
		animPlayer.play("pikeUp")
		await get_tree().create_timer(pikeUpTime).timeout
		
		#animPlayer.play("pikeDown")	
		animPlayer.play_backwards("pikeUp")
		await get_tree().create_timer(pikeDownTime).timeout


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
	
func _physics_process(delta):
	scale.y = lerpf(minScale, maxScale, activationRatio)
