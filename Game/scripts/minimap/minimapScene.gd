extends Node2D

@export var roomsRoot:Node2D = null
@export var connectionsRoot:Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	SaveManager.onRoomVisited.connect(func(room):
		UpdateRoomsVisibility(roomsRoot)
		UpdateConnectionsVisibility(connectionsRoot)
		)
		
	UpdateRoomsVisibility(roomsRoot)
	UpdateConnectionsVisibility(connectionsRoot)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func UpdateRoomVisibility(room:Node2D):
	if (SaveManager.visitedRooms.find(room.name) == -1):
		room.visible = false
	else:
		room.visible = true

func UpdateRoomsVisibility(roomsRoot:Node2D):
	for category in roomsRoot.get_children():
		for room in category.get_children():
			UpdateRoomVisibility(room)

func UpdateConnectionVisibility(connection:RoomConnection):
	if (connection.room1.visible or connection.room2.visible):
		connection.visible = true
	else:
		connection.visible = false

func UpdateConnectionsVisibility(connectionsRoot:Node2D):
	for connection in connectionsRoot.get_children():
		UpdateConnectionVisibility(connection)
