extends Area2D

@export var dmg:float = 1.0

func onEntered(object:Node):
	for child in object.get_children():
		if (child is Health):
			child.dealDamages(dmg, self)

func _on_area_entered(area):
	onEntered(area)

func _on_body_entered(body):
	onEntered(body)
