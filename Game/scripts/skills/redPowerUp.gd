extends Node
class_name RedPowerUp

@export var color: Color = Color.DARK_RED
@export var skillOwner: Player = null
@export var dmgMultiplicator = 2

func setSkillOwner(newOwner: Player):
	skillOwner = newOwner
	skillOwner.sprite.modulate = color
	skillOwner.dmgMultiplicator *= dmgMultiplicator

func onRemoved():
	skillOwner.dmgMultiplicator /= dmgMultiplicator

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
