extends Node

var currentRoom:Room
var currentRoomPath:String

var currentCheckpoint:CheckpointSaveData

signal onRoomVisited(Room)
var visitedRooms:Array[String] = []

var isGamePaused:bool = false

var lastCheckpointPath = "user://lastCheckpoint.tscn"

var chrono:float = 0.0
var isChronoRunning:bool = false
var chronoStartRoomPath:String = "res://scenes/WhiteRooms/WhiteVillage.tscn"
var chronoEndRoomPath:String = "res://scenes/AberrationRooms/FinalRoom.tscn"

var bgm:AudioStreamPlayer

@onready var redBossRoomMusic = preload("res://musics/Ossuary 4 - Animate.mp3")
@onready var greenBossRoomMusic = preload("res://musics/Corruption.mp3")
@onready var aberrationBossRoomMusic = preload("res://musics/Killers.mp3")
@onready var whiteMusic = preload("res://musics/Floating Cities.mp3")
@onready var redMusic = preload("res://musics/The Escalation.mp3")
@onready var greenMusic = preload("res://musics/Lord of the Land.mp3")
@onready var lightAberrationMusic = preload("res://musics/Interloper.mp3")
@onready var aberrationMusic = preload("res://musics/The Complex.mp3")

func setDifficulty(difficulty:int):
	currentCheckpoint.difficulty = difficulty
	saveLastCheckpoint()

func _process(delta):
	if (isChronoRunning):
		chrono += delta

func updateIsChronoRunning(roomPath:String):
	if (roomPath == chronoStartRoomPath):
		isChronoRunning = true
	elif (roomPath == chronoEndRoomPath):
		isChronoRunning = false

func openLink(str:String):
	OS.shell_open(str)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	currentCheckpoint = CheckpointSaveData.new()
	currentCheckpoint.room = ProjectSettings.get_setting("game/config/first_room")
	currentCheckpoint.exit = ""
	#currentCheckpoint.hasBeatenGreenBoss = true
	#currentCheckpoint.hasBeatenRedBoss = true
	#
	preloadDialogic()	
	preloadNextRooms()
	ResourceLoader.load_threaded_request("res://Textures/enemySeemlessNoise2D.tres")
	ResourceLoader.load_threaded_request("res://Textures/enemies/T_Slime.tres")	
	
	var packedScene = ResourceLoader.load("res://scenes/preloadShaders.tscn") as PackedScene
	var preloadShaders = packedScene.instantiate()
	
	await get_tree().process_frame
	get_tree().root.add_child(preloadShaders)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	preloadShaders.queue_free()
	#preloadShaders.queue_free()
	
	var packedScene2 = ResourceLoader.load("res://scenes/bgm.tscn") as PackedScene
	bgm = packedScene2.instantiate() as AudioStreamPlayer
	get_tree().root.add_child(bgm)
	
#func tryChangeMusic(path:String):
	#if (path == bgm.stream.resource_path):
		#return
		#
	#bgm.stream = load(path)
	#bgm.play()
	
func tryChangeMusic(stream):
	if (stream == bgm.stream):
		return
		
	bgm.stream = stream
	bgm.play()
	
func updateMusic():
	#currentRoom = room
	#currentRoomPath = newRoomPath
	
	if (bgm == null):
		return
	
	if (currentRoom.name == "RedBossRoom"):
		tryChangeMusic(redBossRoomMusic)
	elif (currentRoom.name == "GreenBossRoom"):
		tryChangeMusic(greenBossRoomMusic)
	#elif (currentRoom.name == "AberrationBossRoom"):
		#tryChangeMusic("res://musics/Burn The World Waltz .mp3")

	elif (currentRoom.name.contains("Red")):
		tryChangeMusic(redMusic)
	elif (currentRoom.name.contains("Green")):
		tryChangeMusic(greenMusic)
	elif (currentRoom.name.contains("LightAberration")):
		tryChangeMusic(lightAberrationMusic)
	elif (currentRoom.name.contains("Aberration")):
		tryChangeMusic(aberrationMusic)
	else: # white
		tryChangeMusic(whiteMusic)
	
func preloadDialogic():
	#ResourceLoader.load_threaded_request(ProjectSettings.get_setting("dialogic/layout/default_style"))
	var defaultStyle:DialogicStyle = ResourceLoader.load(ProjectSettings.get_setting("dialogic/layout/default_style")) as DialogicStyle
	defaultStyle.prepare()
	
	#var styles:Array = ProjectSettings.get_setting("dialogic/layout/style_list")
	#for style in styles:
		#if (style is String):
			#ResourceLoader.load_threaded_request(style)

	ResourceLoader.load_threaded_request("res://addons/dialogic/Modules/DefaultLayoutParts/Layer_VN_Textbox/vn_textbox_layer.tscn")

func preloadNextRooms():
	if (currentRoom == null):
		return
		
	var exits = currentRoom.findAllExits()
	for roomExit in exits:
		if ResourceLoader.exists(roomExit.nextRoom):
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

func changeRoomNextFrame(newRoomPath: String, nextExitName: String):	
	Dialogic.timeline_ended.connect(func():
		changeRoom(newRoomPath, nextExitName)
	)

func visitRoom(room:Room):
	currentRoom = room
	visitedRooms.push_back(currentRoom.name)
	onRoomVisited.emit(room)
	

func changeRoom(newRoomPath: String, nextExitName: String):	
	if (!ResourceLoader.exists(newRoomPath)):
		return
		
	updateIsChronoRunning(newRoomPath)
		
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
		
	if (room.isCheckpoint or currentCheckpoint.difficulty == 0):
		currentCheckpoint.room = newRoomPath
		currentCheckpoint.exit = nextExitName
		saveLastCheckpoint()
	
	root.add_child(room)
	
	for nodeToRemove in nodesToRemove:
		nodeToRemove.queue_free()

	visitRoom(room)
	currentRoom = room
	currentRoomPath = newRoomPath
	preloadNextRooms()
	
	updateMusic()
	
func changeRoom2(newRoomPath: String, nextExitName: String, playerToCollider:Vector2, player:Player):	
	if (!ResourceLoader.exists(newRoomPath)):
		return
		
	updateIsChronoRunning(newRoomPath)

	var room = (ResourceLoader.load(newRoomPath) as PackedScene).instantiate() as Room
	room.player = room.find_child("Player", true, false) as Player
	room.player.velocity = player.velocity
	room.player.grapplingHookVelocity = player.grapplingHookVelocity
	room.player.state = player.state
	for child in room.player.get_children():
		if child is Jump:
			child.durationSinceLastJump = player.jump.durationSinceLastJump

	var root = get_tree().get_root()
	
	var nodesToRemove = []
	for child in root.get_children():
		if child is Node2D:
			nodesToRemove.push_back(child)
			root.remove_child(child) 


	
	var roomExit =  room.findExit(nextExitName)
	
	var shapeOwner = roomExit.getShapeOwner()
	var rectangle = roomExit.getRectangle(shapeOwner)
	
	if (rectangle.size.x > rectangle.size.y):
		playerToCollider.y *= -1
	else:
		playerToCollider.x *= -1
		
	room.player.global_position = shapeOwner.global_position - playerToCollider * rectangle.size
		
	room.player.global_position += roomExit.normal * 400
	if (roomExit.normal.is_zero_approx()):
		push_error("the normal shouldn't be zero")
		
	#if (roomExit != null):
		#room.player.global_position = roomExit.playerEnter.global_position
		
	if (room.isCheckpoint or currentCheckpoint.difficulty == 0):
		currentCheckpoint.room = newRoomPath
		currentCheckpoint.exit = nextExitName
		saveLastCheckpoint()
	
	root.add_child(room)
	
	for nodeToRemove in nodesToRemove:
		nodeToRemove.queue_free()

	visitRoom(room)
	currentRoom = room
	currentRoomPath = newRoomPath
	preloadNextRooms()
	
	updateMusic()
