extends Area2D

@export var player : Player

func _process(delta):
	var bodies = get_overlapping_bodies()
	var ground = bodies.any(func(obj): return obj != player)
	if ground:
		player.jump.durationSinceLastFloorTime = 0.0
