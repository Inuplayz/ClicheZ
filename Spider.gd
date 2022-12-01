extends KinematicBody2D

export (float) var HP = 1

enum {
	IDLE,
	WINDUP,
	ATTACK,
	FALL
}

var state = IDLE

var dir = -1
var motion = Vector2()
var speed = 30

var Gravity = 2500
var Jump = 150
var MaxJump = -225

var Wind = true
var can_turn = true

onready var RaycastPlayerL = $RayCast2DL
onready var RaycastPlayerR = $RayCast2DR
onready var player = get_tree().get_nodes_in_group("Player")

func _ready():
	pass

func _process(delta):
	
	match (state):
		IDLE: 
			$AnimationPlayer.play("Walk")
			motion = move_and_slide(motion, Vector2.UP)
	
			motion.x = speed * dir
	
			if not is_on_floor():
				motion.y = 100
			else:
				motion.y = 0
			
			if $RayCast2DL.is_colliding():
				dir *= -1
				$RayCast2DR.enabled = true
				$RayCast2DPlayerR.enabled = true
				$RayCast2DL.enabled = false
				$RayCast2DPlayerL.enabled = false
		
			if $RayCast2DR.is_colliding():
				dir *= -1
				$RayCast2DL.enabled = true
				$RayCast2DPlayerL.enabled = true
				$RayCast2DR.enabled = false
				$RayCast2DPlayerR.enabled = false
			
			if dir == 1:
				$Sprite.flip_h = true
			else:
				$Sprite.flip_h = false
			
			if $RayCast2DPlayerL.is_colliding() or $RayCast2DPlayerR.is_colliding():
				$RayCast2DL.enabled = false
				$RayCast2DPlayerL.enabled = false
				$RayCast2DR.enabled = false
				$RayCast2DPlayerR.enabled = false
				$Timer.start()
				state = WINDUP
				continue
	
		WINDUP:
			RaycastPlayerL.enabled = false
			RaycastPlayerR.enabled = false
			$AnimationPlayer.play("Idle")
			motion = move_and_slide(motion, Vector2.UP)
			motion.x = 0
			motion.y = 0
			dir = sign(self.position.x - player[0].position.x)
			if dir == -1:
				$Sprite.flip_h = true
			else:
				$Sprite.flip_h = false

		ATTACK:
			$Timer.stop()
			$AnimationPlayer.play("Jump")
			motion = move_and_slide(motion, Vector2.UP)
			if is_on_wall():
				dir *= -1
			motion.x += (speed * 2) * -(dir) 
			motion.y -= Jump 
			
			if motion.y <= MaxJump:
				state = FALL
				continue
		FALL:
			motion = move_and_slide(motion, Vector2.UP)
			motion.y += Gravity * delta
			if is_on_floor():
				$Timer.start()
				state = WINDUP
				continue
	
#	$Label.text = "Move x:" + str(motion.x) + " y: " + str(motion.y) + "\n" + "DIR: " \
#	+ str(dir) + str($Sprite.flip_h) + " " + str(state) + " " + str(self.position.x) + " " \
#	+ str (player[0].position.x)
	

func _on_Timer_timeout():
	state = ATTACK


func _on_Hitbox_area_entered(area):
	pass

func hurt():
	self.queue_free()
