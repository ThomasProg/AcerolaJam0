extends Area2D
class_name DashAttack

@export var totalDuration:float = 0.2
@export var damages:float = 2
@export var direction:Vector2 = Vector2(1,0)
@export var maxDist:float = 600
@export var impulseSpeed:float = 2000

@onready var explosionCollider:Node2D = $ExplosionCollider
@onready var laserCollider:Node2D = $LaserCollider
@onready var laserParticles:GPUParticles2D = $Laser
@onready var explosionParticules:GPUParticles2D = $Explosion
#@export var attackRange:float = 1

#@export var attackTime = 0

@export var skillOwner:Node

@onready var animPlayer:AnimationPlayer = $AnimationPlayer

var touchedEnemies = []

func setSkillOwner(newOwner: Player):
	skillOwner = newOwner
	
	look_at(to_global(direction))
	
	skillOwner.impulseVelocity = - direction * impulseSpeed
	
	
	var space_state = get_world_2d().direct_space_state
	var endPosition = global_position + direction * maxDist
	var query = PhysicsRayQueryParameters2D.create(global_position, endPosition)
	var result = space_state.intersect_ray(query)
	
	if (result):
		explosionCollider.global_position = result.position
		explosionParticules.global_position = result.position
		print("attacked: ", result.collider.name)
	else:
		explosionCollider.global_position = endPosition
		explosionParticules.global_position = endPosition
		print("nothing attacked")
		

	

# Called when the node enters the scene tree for the first time.
func _ready():
	#queue_free()
	
	animPlayer.speed_scale = 3.0
	animPlayer.play("attack")

	await get_tree().create_timer(totalDuration).timeout
	
	for collider in get_children():
		if collider is CollisionShape2D:
			collider.queue_free()
	
	# animDuration*speedScale + maxParticleSystemLifetime - totalDuration
	await get_tree().create_timer(animPlayer.current_animation_length*animPlayer.speed_scale + 1.0 - totalDuration).timeout	
	
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	laserParticles.global_position = (explosionParticules.global_position + global_position) / 2.0
	var p = laserParticles.process_material as ParticleProcessMaterial
	p.emission_box_extents.x = laserParticles.position.x
	
	if (laserCollider != null):
		laserCollider.global_position = laserParticles.global_position
		(laserCollider.shape as RectangleShape2D).size.x = laserParticles.position.x

func onObjectEntered(object: Node):
	print("MeleeAttack: Trying to attack ", object.name)
	for child in object.get_children():
		if (child is Health):
			if (!touchedEnemies.has(object)):
				child.dealDamages(damages, self)
				touchedEnemies.push_back(object)

func _on_body_entered(body):
	onObjectEntered(body)


func _on_area_entered(area):
	onObjectEntered(area)
