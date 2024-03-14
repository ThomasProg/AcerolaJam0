extends CanvasLayer

@export var minimap: Minimap
@export var resumeButton: Button
@export var player: Player
@export var difficultyButtons:Array[Button]
@export var creditPrefab:PackedScene

@onready var instaDeathButton: Button = $Panel/MarginContainer/VBoxContainer/ButtonDeath
@onready var creditButton: Button = $Panel/MarginContainer/VBoxContainer/ButtonCredit

var credits:Credits = null

# Called when the node enters the scene tree for the first time.
func _ready():
	resumeButton.pressed.connect(resume)
	instaDeathButton.pressed.connect(func():
		resume()
		player.health.dealDamages(999999, null, true)
		)
		
	creditButton.pressed.connect(func():
		credits = creditPrefab.instantiate() as Credits
		
		credits.onResume.connect(func():
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			)
		
		add_child(credits)
		)

func resume():
	visible = false
	minimap.updateCameraFromPlayerPos = true
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (credits != null):
		return
	
	if (Input.is_action_just_pressed("openInGameMenu")):
		if (visible):
			resume()
		else:
			visible = true
			minimap.updateCameraFromPlayerPos = true
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	for i in range(difficultyButtons.size()):
		if (i == SaveManager.currentCheckpoint.difficulty):
			difficultyButtons[i].modulate = Color.DARK_RED
		else:
			difficultyButtons[i].modulate = Color.WHITE
