extends Area2D
class_name RoomExit

#@export var nextRoom:PackedScene
@export_file("*.tscn") var nextRoom: String
@export var nextExitName:String="RoomExit_right"
@export var playerEnter:Node2D
@export var useRelativePosition:bool = false
@export var normal:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getShapeOwner() -> CollisionShape2D:
	var shapeOwners = get_shape_owners()
	if (shapeOwners.size() != 1):
		push_error("There should only be 1 shape owner for exits!")
		return null

	var shapeOwner = shape_owner_get_owner(shapeOwners[0])
	if (shapeOwner is CollisionShape2D):
		return shapeOwner
	else:
		push_error("shapeOwner is not a CollisionShape2D!")
		return null
		
func getRectangle(shapeOwner:CollisionShape2D) -> RectangleShape2D:	
	if (shapeOwner.shape as RectangleShape2D):
		return shapeOwner.shape
		
	else:
		push_error("exit shape is not a RectangleShape2D!")
		return null

func _on_body_entered(body):
	if (body is Player):
		await get_tree().physics_frame

		if (SaveManager.currentRoom != null and SaveManager.currentRoom.isCheckpoint):
			SaveManager.currentCheckpoint.room = SaveManager.currentRoomPath
			SaveManager.currentCheckpoint.exit = name
			SaveManager.saveLastCheckpoint()

		if (useRelativePosition):
			var shapeOwner = getShapeOwner()
			var rectangle = getRectangle(shapeOwner)

			var playerToCollider = (shapeOwner.global_position - body.global_position)
			playerToCollider /= rectangle.size
			SaveManager.changeRoom2(nextRoom, nextExitName, playerToCollider, body)


			#get_collider_shape().
			#print(body.global_position)
			#SaveManager.changeRoom(nextRoom, nextExitName)
		else:
			SaveManager.changeRoom(nextRoom, nextExitName)
