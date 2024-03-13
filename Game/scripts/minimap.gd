extends Control

@export var viewport: SubViewport

#@export var playerCoords:Vector2i = Vector2i(0,0) 
#
#var cellSize:float = 20
#
#var nbCellsDisplayed:Vector2i = Vector2i(20, 10)
#var center:Vector2 = Vector2(nbCellsDisplayed.x, nbCellsDisplayed.y) / 2.0
#
## Called when the node enters the scene tree for the first time.
#func _ready():
	#size = Vector2(cellSize * nbCellsDisplayed.x, cellSize * nbCellsDisplayed.y)
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#queue_redraw()
	#
	#if Input.is_action_just_pressed("jump"):
		#playerCoords.x += 1
#
#func drawCell(coords:Vector2i, color:Color):
	#var relativeCoords = coords - playerCoords
	#var pos = relativeCoords * cellSize + center
	#var size = Vector2(cellSize, cellSize)
	#draw_rect(Rect2(pos, size), color, true)
#
#func drawCells(from:Vector2i, to:Vector2i, color:Color):
	#for i in range(from.x, to.x):
		#for j in range(from.y, to.y):
			#drawCell(Vector2i(i, j), color)
			#
#func drawRoom(from:Vector2i, size:Vector2i, color:Color):
	#drawCells(from, from + size, color)	
#
#class MapRoom:
	#func _init(coords2, size2):
		#coords = coords2
		#size = size2
	#var coords
	#var size

func _process(delta):
	var room:Node2D = viewport.find_child(SaveManager.currentRoom.name)
	if (room == null):
		push_error("Wrong room name in minimap; ", SaveManager.currentRoom.name, " doesn't exist")
	viewport.get_camera_2d().global_position = room.global_position

#func _draw() -> void:
	#drawCell(Vector2i(0,0), Color.RED)
	#drawCell(Vector2i(1,0), Color.BLUE)
	
	#var rooms = {}
	
	#rooms["White1"] = MapRoom.new(Vector2i(0,0), Vector2i(4,2))
	
	#drawRoom(Vector2i(0,0), Vector2i(4,2), Color.WHITE)
#
	#drawRoom(Vector2i(6,0), Vector2i(4,2), Color.WHITE)	
	#
	#drawRoom(Vector2i(12,0), Vector2i(4,2), Color.WHITE)	
	#


	#for room in rooms:
		#drawRoom(room.coords, room.size, Color.WHITE)
