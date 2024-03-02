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
		
		var root = get_tree().get_root()
		var NodeToRemove = root.get_child(0) 
		
		
		root.remove_child(NodeToRemove) 
		
		var newPackedScene = load(nextRoom) as PackedScene 
		var room = newPackedScene.instantiate() as Room
		room.player = room.find_child("Player", true, false)
		room.player.global_position = room.findExit(nextExitName).playerEnter.global_position
		
		root.add_child(room)
		#get_tree().change_scene_to_packed(nextRoom)
		
		NodeToRemove.queue_free()
