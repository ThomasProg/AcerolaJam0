extends Node

@export var item:CanvasItem
@export var glowDuration:float = 0.5

var ratio = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if (item == null):
		item = get_parent().get_parent()
	
	var health = get_parent() as Health
	health.onDamage.connect(func(attacker:Node):
		ratio = 0.0
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ratio += delta / glowDuration
	ratio = clampf(ratio, 0.0, 1.0)
	item.modulate = lerp(Color.RED, Color.WHITE, ratio)
