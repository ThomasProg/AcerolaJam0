extends Node

var currentRoom:Room
var currentRoomPath:String

var currentCheckpoint:CheckpointSaveData

var lastCheckpointPath = "user://lastCheckpoint.tscn"

func _ready():
	currentCheckpoint = CheckpointSaveData.new()
	currentCheckpoint.room = ProjectSettings.get_setting("game/config/first_room")
	currentCheckpoint.exit = ""
	
	preloadDialogic()	
	preloadNextRooms()
	ResourceLoader.load_threaded_request("res://Textures/enemySeemlessNoise2D.tres")
	ResourceLoader.load_threaded_request("res://Textures/enemies/T_Slime.tres")	
	
	var packedScene = ResourceLoader.load("res://scenes/preloadShaders.tscn") as PackedScene
	var preloadShaders = packedScene.instantiate()
	
	await get_tree().process_frame
	get_tree().root.add_child(preloadShaders)
	#await get_tree().process_frame
	#await get_tree().process_frame
	#await get_tree().process_frame
	#preloadShaders.queue_free()
	
	
func preloadDialogic():
	#ResourceLoader.load_threaded_request(ProjectSettings.get_setting("dialogic/layout/default_style"))
	var defaultStyle:DialogicStyle = ResourceLoader.load(ProjectSettings.get_setting("dialogic/layout/default_style")) as DialogicStyle
	defaultStyle.prepare()
	
	var styles:Array = ProjectSettings.get_setting("dialogic/layout/style_list")
	for style in styles:
		if (style is String):
			ResourceLoader.load_threaded_request(style)

func preloadNextRooms():
	if (currentRoom == null):
		return
		
	var exits = currentRoom.findAllExits()
	for roomExit in exits:
		ResourceLoader.load_threaded_request(roomExit.nextRoom)
		
		#Dialogic.preload_timeline()

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
	preloadNextRooms()
	
