@tool
extends Node2D

@export var startOffset:float = 0.0
@export var radius:float = 1000.0
@export var speed:float = 1.5
@export var maxAngleDegrees = 270

@onready var body:AnimatableBody2D = $AnimatableBody2D

@onready var rotationRoot:Node2D = $rotationRoot
@onready var rotated:Node2D = $rotationRoot/rotated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	rotated.position.y = radius
	var angle = (float(Time.get_ticks_msec()) / 1000.0 + startOffset) * speed
	rotationRoot.rotation = maxAngleDegrees * sin(angle) * PI / 360
	body.global_position = rotated.global_position
	#print(rotated.position)
