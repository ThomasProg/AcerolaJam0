extends Node2D
class_name AberrationArea

@export var dps:float = 1.0
@onready var area = $Area2D

func _process(delta):
	for body in area.get_overlapping_bodies():
		for child in body.get_children():
			if (child is Health):
				child.dealDamages(dps * delta, self)
