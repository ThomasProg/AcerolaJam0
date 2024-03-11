extends Node
class_name Health

@export var shouldRemoveOnDeath:bool = true
@export var life:float = 10
@export var maxLife:float = 10
@onready var deathParticlesPrefab:PackedScene = load("res://prefabs/particles/deathParticles.tscn")

signal onDeath(killer:Node)
signal onDamage(attacker:Node)
signal onHeal(healer:Node)

func isDead():
	return life <= 0 or is_zero_approx(life)

func dealDamages(damages:float, attacker:Node):
	if (attacker == get_parent()):
		return
		
	if (attacker != null and "skillOwner" in attacker):
		if (attacker.skillOwner == get_parent()):
			return
	
	var wasDead:bool = isDead()
	
	life -= damages
	
	onDamage.emit(attacker)
	
	if (!wasDead and isDead()):
		life = 0
		
		var particles = deathParticlesPrefab.instantiate() as GPUParticles2D
		particles.finished.connect(func(): particles.queue_free())
		particles.global_position = (get_parent() as Node2D).global_position
		particles.emitting = true
		get_parent().get_parent().add_child(particles)
		
		onDeath.emit(attacker)
		if (shouldRemoveOnDeath):
			get_parent().queue_free()
	
func heal(amount:float, healer:Node):
	life += amount
	
	onHeal.emit(healer)
	
	if (life > maxLife):
		life = maxLife
