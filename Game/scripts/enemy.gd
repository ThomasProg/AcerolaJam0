extends Node

#@export var dps:float = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if (get_parent() is Area2D):
		#for body in get_parent().get_overlapping_bodies():
			#for child in body.get_children():
				#if (child is Health):
					#child.dealDamages(dps * delta, self)
				#
