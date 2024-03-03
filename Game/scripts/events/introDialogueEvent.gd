extends Node

@export var animPlayer:AnimationPlayer

@export var npc:NPC

@export var destinations:Array[Node2D]
@export var dialogues:Array[DialogicTimeline]

@export var currentDestIndex = -1
@export var currentDialogueIndex = -1

@export var currentAnimIndex:int = 0

func moveToNextDest():
	
	if (npc.target != null and !npc.navAgent.is_target_reached()):
		await npc.navAgent.target_reached
	
	currentDestIndex += 1
	if ("target" in npc):
		npc.target = destinations[currentDestIndex]
		
func destroyNPC():
	npc.queue_free()


var lastPause:float = 0
func pausePlayer():
	if (lastPause < animPlayer.current_animation_position):
		lastPause = animPlayer.current_animation_position
		animPlayer.pause()

func playDialogue(dialogue: DialogicTimeline):
	if Dialogic.current_timeline != null:
		return

	Dialogic.start(dialogue)
	get_viewport().set_input_as_handled()
	
	await Dialogic.timeline_ended
	currentAnimIndex += 1
	var animName = String.num_int64(currentAnimIndex)
	if (animPlayer.has_animation(animName)):
		animPlayer.play(animName)

func playNextDialogue():
	currentDialogueIndex += 1
	playDialogue(dialogues[currentDialogueIndex])
	
# Called when the node enters the scene tree for the first time.
func _ready():
	animPlayer.play("0")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(animPlayer.current_animation_position)
	pass
