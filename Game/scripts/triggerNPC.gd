extends Area2D

@export var isJump:bool = false
@export var isDoubleJump:bool = false
@export var directionIsRight:bool = true

@export var isLongDoubleJump:bool = false

func _on_body_entered(body):
	if (body is NPC):
		if (directionIsRight and body.velocity.x > 0) or (!directionIsRight and body.velocity.x < 0): 
			if (isJump):
				body.pressJumpOnFloor()
			if (isDoubleJump):
				body.pressDoubleJumpOnFloor()
			if (isLongDoubleJump): 
				if (directionIsRight):
					body.pressLongDoubleJumpOnFloor(Vector2.LEFT)
				else:
					body.pressLongDoubleJumpOnFloor(Vector2.RIGHT)	
