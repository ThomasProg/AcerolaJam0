extends Node
class_name GrowSpikes

@export var skillOwner:Node2D
@export var phase:Phase = Phase.PRE_ATTACK

@export var spikePrefab:PackedScene
@export var particlesPrefab:PackedScene

@export var p1:Vector2
@export var p2:Vector2
@export var nbEnemies:int = 20
@export var removeRandomSpike:bool = true
@export var forceSpikesAround:Array[Vector2] = []
@export var forceSpikesDistance:float = 1500

@export var preAttackWaitTime:float = 1.0 
@export var postAttackWaitTime:float = 1.0 
@export var spikesLifetime:float = 4.0 
@export var hintDuration:float = 2.0 

var spikes:Array[Node2D] = []

enum Phase { PRE_ATTACK, HINT, GROWING_PIKES, FINISHED }

signal onHint()
signal onSpikesGrow()
signal onEnd()
signal onSpikesDestroyed()

func _ready():
	set_physics_process(false)

func Start():
	phase = Phase.PRE_ATTACK
	await get_tree().create_timer(preAttackWaitTime).timeout
	phase = Phase.HINT
	onHint.emit()
	
	var spikesParticles:Array[Node2D] = []
	
	var spawnPositions:Array[Vector2] = [] 
	var spawnPositionIndicesOutsideOfTheBoss:Array[int] = [] 
	for i in range(nbEnemies):
		var position:Vector2 = lerp(p1, p2, i / float(nbEnemies - 1)) as Vector2
		spawnPositions.push_back(position)
		if (forceSpikesAround.all(func(a): return position.distance_squared_to(a) > forceSpikesDistance * forceSpikesDistance)):
			spawnPositionIndicesOutsideOfTheBoss.push_back(i) 
			
	var randomSpikeIndexToRemove = spawnPositionIndicesOutsideOfTheBoss.pick_random()
	
	for i in range(spawnPositions.size()):
		if (i == randomSpikeIndexToRemove and removeRandomSpike):
			continue
			
		var spikeParticle = particlesPrefab.instantiate() as Node2D
		spikeParticle.global_position = spawnPositions[i]
		skillOwner.get_parent().add_child(spikeParticle)
		spikesParticles.push_back(spikeParticle)
	
	await get_tree().create_timer(hintDuration).timeout
	phase = Phase.GROWING_PIKES
	onSpikesGrow.emit()
	
	for spikeParticle in spikesParticles:
		spikeParticle.queue_free()
	
	for i in range(spawnPositions.size()):
		if (i == randomSpikeIndexToRemove and removeRandomSpike):
			continue
		var spike = spikePrefab.instantiate() as Node2D
		spike.global_position = spawnPositions[i]
		skillOwner.get_parent().add_child(spike)
		spikes.push_back(spike)
	
	await get_tree().create_timer(postAttackWaitTime).timeout
	onEnd.emit()

	await get_tree().create_timer(spikesLifetime - postAttackWaitTime).timeout
	
	for spike in spikes:
		if (spike != null):
			spike.queue_free()
			#for child in spike.get_children():
				#if (child is Health):
					#child.dealDamages(child.life, self)
	spikes.clear()
					
	onSpikesDestroyed.emit()
				
