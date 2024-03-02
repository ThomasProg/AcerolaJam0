extends Area2D
class_name FallingEnemy

@export var skillOwner:Node
@export var useGravity:bool = false
@export var velocity: Vector2 = Vector2.ZERO
@export var dmg:float = 1
@export var maxSpeed:float = 3000

func _physics_process(delta):
	if (useGravity):
		if (velocity.length_squared() < maxSpeed*maxSpeed):
			velocity.y += gravity * delta
			
			
	global_position += velocity * delta
	
		
func onEntered(object:Node):
	for child in object.get_children():
		if (child is Health):
			child.dealDamages(dmg, self)
			
	queue_free()

func _on_area_entered(area):
	onEntered(area)

func _on_body_entered(body):
	onEntered(body)
