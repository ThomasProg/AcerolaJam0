extends Node
class_name BluePowerUp

@export var color: Color = Color.DARK_CYAN
@export var skillOwner: Player = null
@export var speedMultiplicator = 1.5

func setSkillOwner(newOwner: Player):
	skillOwner = newOwner
	skillOwner.sprite.modulate = color
	skillOwner.speed *= speedMultiplicator
	
func onRemoved():
	skillOwner.speed /= speedMultiplicator

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
