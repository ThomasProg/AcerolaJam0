extends CharacterBody2D

class_name AberrationBoss

@export var phases:Array[Node]
@export var target:Player
@export var currentPhaseIndex = 0

@onready var health:Health = $Health
@onready var bossProgressBar:ProgressBar = $CanvasLayer/MarginContainer/VBoxContainer/ProgressBar
@onready var meshInstance:MeshInstance2D = $MeshInstance2D3

func _physics_process(delta):
	move_and_slide()

func runNextPhase():
	phases[currentPhaseIndex].end()
	currentPhaseIndex += 1
	if (currentPhaseIndex < phases.size()):
		phases[currentPhaseIndex].start()

func _ready():
	for phase in phases:
		phase.boss = self
	
	health.onDamage.connect(func(attacker:Node):			
		bossProgressBar.min_value = 0
		bossProgressBar.max_value = health.maxLife
		bossProgressBar.value = health.life
		)
		
	health.onHeal.connect(func(healer:Node):			
		bossProgressBar.min_value = 0
		bossProgressBar.max_value = health.maxLife
		bossProgressBar.value = health.life
		)
		
	await get_tree().process_frame
	
	phases.front().start()
