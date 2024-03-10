extends Node
class_name Health

@export var shouldRemoveOnDeath:bool = true
@export var life:float = 10
@export var maxLife:float = 10

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
		onDeath.emit(attacker)
		if (shouldRemoveOnDeath):
			get_parent().queue_free()
	
func heal(amount:float, healer:Node):
	life += amount
	
	onHeal.emit(healer)
	
	if (life > maxLife):
		life = maxLife
