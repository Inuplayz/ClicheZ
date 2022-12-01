extends KinematicBody2D

enum{
	IDLE,
	CHASE,
	ATTACK
}

export (float) var HP = 1.0
export (float) var MaxHP = 1.0
var state = IDLE
var dir = 1
var motion = Vector2()
var stats = PlayerStats
var SPEED = 65

onready var state_machine = $AnimationTree.get("parameters/playback")
onready var player = get_tree().get_nodes_in_group("Player")

func _ready():
	$TextureProgress.max_value = MaxHP
	$TextureProgress.value = HP

func _process(delta):
	
	match (state):
		IDLE:
			
			if $Detect.is_colliding():
				$Timer.start()
				state = CHASE
				continue
		CHASE:
			motion = move_and_slide(motion, Vector2.UP)
			
			if not $Halt.is_colliding():
				motion.x = SPEED * -(dir)
			else:
				motion.x = 0
			
			if stats.crouch:
				state_machine.travel("IdleLow")
				$Shield/CollisionShape2D.position.y = 6
				
			else:
				state_machine.travel("IdleHigh")
				$Shield/CollisionShape2D.position.y = -5
			
		ATTACK:
			$Timer.stop()
			if stats.crouch:
				state_machine.travel("AttackLow")
			else:
				state_machine.travel("AttackHigh")
	
	if $Attack.is_colliding():
		var target = $Attack.get_collider()
		if target.name.find("Shield") < 0:
			print(target)
			$HurtP.play()
			stats.HP -= 0.50
			$Attack.enabled = false
			print(target)
		else:
			$Attack.enabled = false
			print(target)
	
	dir = sign(self.position.x - player[0].position.x)
	$Sprite.flip_h = !bool((sign(dir) + 1) / 2)
	
	if dir != -1:
		$Halt.cast_to.x = -9
		$Halt.position.x = -9
		$Detect.cast_to.x = -50
		$Detect.position.x = -9
		$Attack.cast_to.x = -11
		$Attack.position.x = -10
		$Shield/CollisionShape2D.position.x = -8
	else:
		$Halt.cast_to.x = 9
		$Halt.position.x = 9
		$Detect.cast_to.x = 50
		$Detect.position.x = 9
		$Attack.cast_to.x = 11
		$Attack.position.x = 10
		$Shield/CollisionShape2D.position.x = 8
	
	
	if HP < 0:
		queue_free()
	
	$Label.text = str(state) + " " + str(dir) 
	
func hurt():
	$Hurtself.play()
	HP -= PlayerStats.DamageP
	$TextureProgress.value = HP
	print(str(HP) + "/" + str(MaxHP))
	if HP <= 0:
		PlayerStats.knights += 1
		queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Timer_timeout():
	if stats.crouch:
		$Attack.position.y = 4
		
	else:
		$Attack.position.y = -5
	state = ATTACK

func _to_chase():
	state = CHASE
	$Timer.start()
