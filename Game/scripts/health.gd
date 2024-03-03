extends Node
class_name Health

@export var shouldRemoveOnDeath:bool = true
@export var life:float = 10
@export var maxLife:float = 10

signal onDeath(killer:Node)
signal onDamage(attacker:Node)
signal onHeal(healer:Node)

func dealDamages(damages:float, attacker:Node):
	if (attacker == get_parent()):
		return
		
	if ("skillOwner" in attacker):
		if (attacker.skillOwner == get_parent()):
			return
	
	life -= damages
	
	onDamage.emit(attacker)
	
	if (life <= 0):
		life = 0
		onDeath.emit(attacker)
		if (shouldRemoveOnDeath):
			get_parent().queue_free()
	
func heal(amount:float, healer:Node):
	var parent = get_parent()

	life += amount
	
	onHeal.emit(healer)
	
	if (life > maxLife):
		life = maxLife
