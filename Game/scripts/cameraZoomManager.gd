extends Node
class_name CameraZoomManager

@export var camera:Camera2D
@export var defaultZoom:Vector2 = Vector2.ONE
@export var preTransitionZoom:Vector2 = Vector2.ONE
@export var targetZoom = Vector2.ONE
@export var transitionDuration:float = 1.0

var time = 0.0

func startTransition(newZoom:Vector2, duration:float):
	time = 0.0
	preTransitionZoom = camera.zoom
	targetZoom = newZoom
	transitionDuration = duration

# Called when the node enters the scene tree for the first time.
func _ready():
	defaultZoom = camera.zoom
	preTransitionZoom = camera.zoom
	targetZoom = camera.zoom

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	camera.zoom = lerp(preTransitionZoom, targetZoom, clamp(time/transitionDuration,0,1))


