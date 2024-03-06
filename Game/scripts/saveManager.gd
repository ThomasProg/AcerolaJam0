extends Node

var currentRoom:Room
var currentRoomPath:String

var currentCheckpoint:CheckpointSaveData

var lastCheckpointPath = "user://lastCheckpoint.tscn"

func _ready():
	currentCheckpoint = CheckpointSaveData.new()
	currentCheckpoint.room = ProjectSettings.get_setting("game/config/first_room")
	currentCheckpoint.exit = ""

func saveCheckpoint(checkpointName:String):
	ResourceSaver.save(currentCheckpoint, checkpointName)

func loadCheckpoint(checkpointName:String):
	if ResourceLoader.exists(checkpointName):
		var newCheckpoint = ResourceLoader.load(checkpointName) as CheckpointSaveData
		currentCheckpoint = newCheckpoint
	changeRoom(currentCheckpoint.room, currentCheckpoint.exit)

func saveLastCheckpoint():
	saveCheckpoint(lastCheckpointPath)

func loadLastCheckpoint():
	loadCheckpoint(lastCheckpointPath)

func changeRoom(newRoomPath: String, nextExitName: String):	
	if (!ResourceLoader.exists(newRoomPath)):
		return
		
	var root = get_tree().get_root()
	
	var nodesToRemove = []
	for child in root.get_children():
		if child is Node2D:
			nodesToRemove.push_back(child)
			root.remove_child(child) 

	var room = (ResourceLoader.load(newRoomPath) as PackedScene).instantiate() as Room
	room.player = room.find_child("Player", true, false)
	
	var roomExit =  room.findExit(nextExitName)
	if (roomExit != null):
		room.player.global_position = roomExit.playerEnter.global_position
		
	if (room.isCheckpoint):
		currentCheckpoint.room = newRoomPath
		currentCheckpoint.exit = nextExitName
		saveLastCheckpoint()
	
	root.add_child(room)
	
	for nodeToRemove in nodesToRemove:
		nodeToRemove.queue_free()

	currentRoom = room
	currentRoomPath = newRoomPath
