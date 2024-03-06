extends Area2D
class_name RoomExit

#@export var nextRoom:PackedScene
@export_file("*.tscn") var nextRoom: String
@export var nextExitName:String="RoomExit_right"
@export var playerEnter:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if (body is Player):
		await get_tree().physics_frame

		if (SaveManager.currentRoom != null and SaveManager.currentRoom.isCheckpoint):
			SaveManager.currentCheckpoint.room = SaveManager.currentRoomPath
			SaveManager.currentCheckpoint.exit = name
			SaveManager.saveLastCheckpoint()

		SaveManager.changeRoom(nextRoom, nextExitName)
