extends Node2D

@export var amount:int = 10
@export var speedAtGathering:float = 500
@export var gatheringAcceleration:float = 500
@export var dampeningAccelerationAtGathering:float = 4000
@export var maxSpeedAtSpreading:float = 4000
@export var maxSpreadRange:float = 300
@export var accelerationAtSpreading:float = 4000
@export var gathering:bool = true

@export var player:Player

var fireflies:Array[Node2D] = []
var firefliesVelocities:Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if (child is Firefly):
			fireflies.push_back(child)
			
	firefliesVelocities.resize(fireflies.size())

static func rand_point_in_circle(p_radius = 1.0): # Unit length by default.
	var r = sqrt(randf_range(0.0, 1.0)) * p_radius
	var t = randf_range(0.0, 1.0) * TAU
	return Vector2(r * cos(t), r * sin(t))

func _physics_process(delta):
	if (player.velocity.is_zero_approx()):
		gathering = true
	else:
		gathering = false
	
	for i in range(fireflies.size()):
		var firefly = fireflies[i]
		var fireflyToGatherer:Vector2 = firefly.global_position.direction_to(global_position)
		if (gathering):
			#firefliesVelocities[i] = speedAtGathering * fireflyToGatherer

			firefliesVelocities[i] -= dampeningAccelerationAtGathering * firefliesVelocities[i].normalized() * delta
			firefliesVelocities[i] += fireflyToGatherer * lerpf(0, 1000, firefly.global_position.distance_to(global_position) / maxSpreadRange)
			
			if (firefly.position.length_squared() > maxSpreadRange * maxSpreadRange):
				firefliesVelocities[i] = firefliesVelocities[i].length() * fireflyToGatherer.rotated(randf_range(-PI/5.0, PI/5.0))

			#firefliesVelocities[i] += (accelerationAtSpreading * fireflyToGatherer) * delta
			
			if (firefliesVelocities[i].length_squared() > maxSpeedAtSpreading * maxSpeedAtSpreading):
				firefliesVelocities[i] = firefliesVelocities[i].normalized() * maxSpeedAtSpreading



			#firefly.global_position += (speedAtGathering * fireflyToGatherer) * delta
			
			
			#if (firefly.position.length_squared() < 10 * 10):
				#firefliesVelocities[i] = Vector2.ZERO
			
		else: # spreading
			if (fireflyToGatherer.is_zero_approx()):
				fireflyToGatherer = rand_point_in_circle()
			
			firefliesVelocities[i] += (accelerationAtSpreading * (-fireflyToGatherer)) * delta
			if (firefly.position.length_squared() > maxSpreadRange * maxSpreadRange):
				firefliesVelocities[i] = 1.5 * firefliesVelocities[i].length() * fireflyToGatherer.rotated(randf_range(-PI/5.0, PI/5.0))

			if (firefliesVelocities[i].length_squared() > maxSpeedAtSpreading * maxSpeedAtSpreading):
				firefliesVelocities[i] = firefliesVelocities[i].normalized() * maxSpeedAtSpreading

		firefly.global_position += firefliesVelocities[i] * delta
