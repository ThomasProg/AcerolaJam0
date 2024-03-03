extends Node

@export var animPlayer: AnimationPlayer
@export var eventName: String

# Called when the node enters the scene tree for the first time.
func _ready():
	animPlayer.play(eventName)

