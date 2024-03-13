extends Node2D
class_name Room

var player: Player
@export var roomLimits:MeshInstance2D
@export var isCheckpoint:bool = false

func findExit(exitName:String) -> RoomExit:
	for child in get_children():
		if (child as RoomExit and child.name == exitName):
			return child
	return null
	
func findAllExits() -> Array[RoomExit]:
	var exits:Array[RoomExit] = []
	for child in get_children():
		if (child as RoomExit):
			exits.push_back(child)
	return exits

# Called when the node enters the scene tree for the first time.
func _ready():
	player = find_child("Player", true, false)
	
	player.camera.limit_left = roomLimits.position.x - roomLimits.scale.x / 2.0
	player.camera.limit_right = roomLimits.position.x + roomLimits.scale.x / 2.0
	
	player.camera.limit_top = roomLimits.position.y - roomLimits.scale.y / 2.0
	player.camera.limit_bottom = roomLimits.position.y + roomLimits.scale.y / 2.0

	if (SaveManager.currentRoom == null):
		SaveManager.visitRoom(self)
		SaveManager.currentRoom = self
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
