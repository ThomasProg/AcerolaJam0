extends Node2D

@export var target:Node2D
@export var rotationDegrees:float = 0 
@export var wallSize:float = 2000.0
@export var wallDistance:float = 1000.0
@export var moveOffset:float = 0.0
@export var activateMinDistance:float = 100.0

@export var doesDeactivateRemoveLine:bool = true
@export var cancelBumpWhenDeactivated = false

@onready var sub1:LinkEnemySub = $LinkEnemySub1
@onready var sub2:LinkEnemySub = $LinkEnemySub2
@onready var sepLine:CharacterBody2D = $SeparationLine
@onready var collider:CollisionShape2D = $SeparationLine/CollisionShape2D

@onready var sub1Health:Health = $LinkEnemySub1/Health
@onready var sub2Health:Health = $LinkEnemySub2/Health
@onready var health:Health = $SeparationLine/Health

@onready var target1:Node2D = $Target1
@onready var target2:Node2D = $Target2

@onready var a:Node2D = $OnTarget/A
@onready var b:Node2D = $OnTarget/B

@onready var onTarget:Node2D = $OnTarget

var isActivated:bool = false

var line:Line2D = Line2D.new()
var shape:SegmentShape2D

func setTarget(newTarget):
	target = newTarget
	
	if (onTarget.get_parent() != null):
		onTarget.get_parent().remove_child(onTarget)
	
	target.add_child(onTarget)

func activate(doesDeactivateRemoveLine:bool):
	if (isActivated):
		return
	
	isActivated = true
	if (doesDeactivateRemoveLine):
		add_child(line)
		sepLine.add_child(collider)
	
	sub1.stop()
	sub2.stop()

	shape.a = collider.to_local(sub1.global_position) 
	shape.b = collider.to_local(sub2.global_position)
	
func deactivate(doesDeactivateRemoveLine:bool):
	if (!isActivated):
		return
	
	isActivated = false
	if (doesDeactivateRemoveLine):
		remove_child(line)
		sepLine.remove_child(collider)
	
	sub1.resume()
	sub2.resume()

func onDamage(attacker:Node2D):
	#var d1 = a.global_position.distance_to(sub1.global_position)
	#var d2 = b.global_position.distance_to(sub2.global_position)
	#var dist = Vector2(wallDistance, wallSize / 2.0).length() + moveOffset
	#if (d1 > dist or d2 > dist and isActivated):
	if (cancelBumpWhenDeactivated and !isActivated):
		return
	
	if (attacker is DashAttack):
		var dir:Vector2 = (shape.a - shape.b).normalized()
		
		if (sub1 != null):
			var bumpedEffect = BumpedEffect.new()
			bumpedEffect.skillOwner = sub1
			bumpedEffect.speed = 800
			bumpedEffect.damping = 800.0
			bumpedEffect.direction = attacker.direction
			sub1.add_child(bumpedEffect)
			
		if (sub2 != null):
			var bumpedEffect2 = BumpedEffect.new()
			bumpedEffect2.skillOwner = sub2
			bumpedEffect2.speed = 800
			bumpedEffect2.damping = 800.0
			bumpedEffect2.direction = attacker.direction
			sub2.add_child(bumpedEffect2)

# Called when the node enters the scene tree for the first time.
func _ready():
	shape = SegmentShape2D.new()
	collider.shape = shape

	health.onDamage.connect(onDamage)
	sepLine.remove_child(collider)
	remove_child(onTarget)
	
	setTarget(target)
	
	activate(true)
	
	sub1Health.onDeath.connect(func(killer):
		deactivate(true)
		)
		
	sub2Health.onDeath.connect(func(killer):
		deactivate(true)
		)
		
	#sepLine.
	
	
func _process(delta):
	line.clear_points()
	line.default_color = Color.REBECCA_PURPLE
	
	if (sub1 != null and sub2 != null):
		line.add_point(sub1.position)
		line.add_point(sub2.position)

func _physics_process(delta):
	if (sub1 == null or sub2 == null):
		if (sub1 != null):
			sub1.stop()
		if (sub2 != null):
			sub2.stop()
		return
	
	onTarget.rotation_degrees = rotationDegrees
	a.position = Vector2(-wallDistance, -wallSize / 2.0) 
	b.position = Vector2(-wallDistance, wallSize / 2.0)
	
	if (!isActivated):
		var vel = shape.a - collider.to_local(sub1.global_position)
		var collision:KinematicCollision2D = sepLine.move_and_collide(vel, true)
		if collision:
			var ortho = (shape.a.direction_to(shape.b)).orthogonal()
			var aToPlayer = collider.to_global(shape.a).direction_to(collision.get_collider().global_position)
			
			#print(collision.get_collider().name)
			var bumpedEffect = BumpedEffect.new()
			bumpedEffect.skillOwner = collision.get_collider()
			bumpedEffect.speed = 400
			bumpedEffect.damping = 400.0
			print("vel:", vel)
			print("obj:", collision.get_collider().name)
			if (ortho.dot(aToPlayer) > 0):
				bumpedEffect.direction = ortho #-collision.get_normal()
			else:
				bumpedEffect.direction = -ortho
			collision.get_collider().velocity = Vector2.ZERO
			collision.get_collider().add_child(bumpedEffect)
		else:
			sepLine.move_and_collide(vel)

			shape.a = collider.to_local(sub1.global_position)
			shape.b = collider.to_local(sub2.global_position)
			
	else:
		shape.a = collider.to_local(sub1.global_position)
		shape.b = collider.to_local(sub2.global_position)

	var p1 = a.global_position# target.global_position + Vector2(-500, -1000)
	var p2 = b.global_position# target.global_position + Vector2(-500, 1000)

	if (!isActivated):
		target1.global_position = p1
		target2.global_position = p2
	else:
		target1.global_position = sub1.global_position
		target2.global_position = sub2.global_position

	var d1 = p1.distance_to(sub1.global_position)
	var d2 = p2.distance_to(sub2.global_position)
	
	var dist = Vector2(wallDistance, wallSize / 2.0).length() + moveOffset
	if (d1 > dist and d2 > dist and isActivated):
		deactivate(doesDeactivateRemoveLine)

	if (d1 < activateMinDistance and d2 < activateMinDistance and !isActivated):
		activate(doesDeactivateRemoveLine)
