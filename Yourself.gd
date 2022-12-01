extends Node2D

var moment = false
var num = 0

func _process(delta):
	if PlayerStats.HP <= 0.25 and num == 0:
		num += 1
		$EVIL/CollisionShape2D.disabled = false
		
