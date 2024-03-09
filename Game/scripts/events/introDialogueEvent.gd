extends Node

@export var animPlayer:AnimationPlayer

@export var player:Player
@export var npc:NPC

@export var destinations:Array[Node2D]
@export var dialogues:Array[DialogicTimeline]

@export var currentDestIndex = -1
@export var currentDialogueIndex = -1

@export var currentAnimIndex:int = 0

@export var nextAnimTriggers:Array[Area2D]

@export var npcPlayDialogueTriggers:Array[Area2D]

func moveToNextDest():
	
	if (npc.target != null and !npc.navAgent.is_target_reached()):
		await npc.navAgent.target_reached
	
	currentDestIndex += 1
	if ("target" in npc):
		if (currentDestIndex < destinations.size()):
			npc.target = destinations[currentDestIndex]
		
func destroyNPC():
	npc.queue_free()


var lastPause:float = 0
func pausePlayer():
	if (lastPause < animPlayer.current_animation_position):
		lastPause = animPlayer.current_animation_position
		animPlayer.pause()

func playNextAnim():	
	currentAnimIndex += 1
	moveToNextDest()
	#var animName = String.num_int64(currentAnimIndex)
	#if (animPlayer.has_animation(animName)):
		#animPlayer.play(animName)

func playDialogue(dialogue: DialogicTimeline):
	if Dialogic.current_timeline != null:
		return

	Dialogic.start(dialogue)
	get_viewport().set_input_as_handled()
	
	await Dialogic.timeline_ended


func playNextDialogue():
	while(!player.is_on_floor()):
		await get_tree().process_frame
	
	currentDialogueIndex += 1
	if (currentDialogueIndex == currentAnimIndex):
		playDialogue(dialogues[currentDialogueIndex])
	
# Called when the node enters the scene tree for the first time.
func _ready():
	#animPlayer.play("0")
	moveToNextDest()

	for trigger in nextAnimTriggers:
		trigger.body_entered.connect(func(body):
			playNextAnim(), CONNECT_ONE_SHOT)

	for trigger in npcPlayDialogueTriggers:
		trigger.body_entered.connect(func(body):
			playNextDialogue(), CONNECT_ONE_SHOT)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
