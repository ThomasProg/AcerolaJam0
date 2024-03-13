extends Area2D

@export var dmg:float = 1.0

func onEntered(object:Node):
	pass
	#for child in object.get_children():
		#if (child is Health):
			#child.dealDamages(dmg, get_parent())

func _on_area_entered(area):
	onEntered(area)

func _on_body_entered(body):
	onEntered(body)

func _process(delta):
	for body in get_overlapping_bodies():
		for child in body.get_children():
			if (child is Health):
				child.dealDamages(dmg, self)
