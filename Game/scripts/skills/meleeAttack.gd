extends Area2D
class_name MeleeAttack

@export var growDuration:float = 0.1
@export var totalDuration:float = 0.2
@export var isReversed:bool = false
@export var attackRange:float = 1
@export var isRight:bool = true

@export var attackTime = 0
@export var damages = 5

@export var skillOwner:Node

func easeOutCubic(x: float):
	return 1 - pow(1 - x, 3);

# Called when the node enters the scene tree for the first time.
func _ready():
	scale.x = 0

func setSkillOwner(newOwner: Player):
	skillOwner = newOwner

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	attackTime += delta

	# @TODO	
	#if (isRight):
		#offset.x = 100
	#else:
		#offset.x = -100
	
	if (isReversed):
		rotation_degrees = lerpf(-90, 90, attackTime / totalDuration)
	else:
		rotation_degrees = lerpf(90, -90, attackTime / totalDuration)
	
	if (attackTime < growDuration):
		scale.x = attackRange * easeOutCubic(attackTime / growDuration)
	
	if (attackTime > totalDuration-growDuration):
		scale.x = attackRange * easeOutCubic((totalDuration - attackTime) / growDuration)
	
	if (attackTime > totalDuration):
		queue_free()
	
func onObjectEntered(object: Node):
	#print("MeleeAttack: Trying to attack ", object.name)
	for child in object.get_children():
		if (child is Health):
			child.dealDamages(damages, self)
	
func _on_area_entered(area):
	onObjectEntered(area)


func _on_body_entered(body):
	onObjectEntered(body)
