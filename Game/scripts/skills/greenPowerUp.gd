extends Node
class_name GreenPowerUp

@export var color: Color = Color.DARK_GREEN
@export var skillOwner: Player = null
@export var healPerSecond = 1

func setSkillOwner(newOwner: Player):
	skillOwner = newOwner
	skillOwner.sprite.modulate = color
	skillOwner.regenerationPerSecond += healPerSecond

func onRemoved():
	skillOwner.regenerationPerSecond -= healPerSecond

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
