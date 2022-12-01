extends KinematicBody2D


enum{
	GROUND, 
	ATTACK,
	CROUCH, 
	CROUCH_ATTACK, 
	JUMPING, 
	AIR,
	AIR_ATTACK,
}

var state = GROUND

var GRAVITY = 1400
var MAX_SPEED = 55
var ACCELERATION = 300
var JUMP_MAX = -152
var JUMP = 910

var motion = Vector2.ZERO

var jump
var move_dir = 1
var labelMove
var labelMotion

var stats = PlayerStats

onready var collider = $RayCast2D
onready var state_machine = $AnimationTree.get("parameters/playback")
onready var target = collider.get_collider()

export var arrow : PackedScene = load("res://Scenes/Player/Arrow.tscn")

func _ready():
	pass

func Move_R_L(delta, Allow_M, Allow_F):
	var move = (int(Input.is_action_pressed("ui_right")) \
	-int(Input.is_action_pressed("ui_left")))
	
	move_and_slide_with_snap(motion,Vector2.DOWN * 8,Vector2.UP)
	
	if move != 0 and Allow_M:
		state_machine.travel("walk")
		if abs(motion.x) <= MAX_SPEED:
			motion.x += (move*ACCELERATION*delta)
	elif Allow_F:
		motion.x -= min(abs(motion.x), ACCELERATION * delta) * sign(motion.x)
	
	if move != 0:
		move_dir = move
		stats.DIR = move_dir
		$Sprite.flip_h = !bool((sign(move_dir) + 1) / 2)
	
	if move_dir == -1:
		$RayCast2D.cast_to.x = -15
		$RayCast2D.position.x = -8
		$Shield/CollisionShape2D.position.x = -7
	else:
		$RayCast2D.cast_to.x = 15
		$RayCast2D.position.x = 8
		$Shield/CollisionShape2D.position.x = 7
	labelMove = move
	labelMotion = motion.x

func _change_to_ground():
	state_machine.travel("Idle")
	if not is_on_floor():
		state = AIR
	else:
		state = GROUND
func _change_to_crouch():
	state_machine.travel("Crouch")
	state = CROUCH
func _attack():
	$RayCast2D.enabled = true
	$Attack.play()
func hurt():
	stats.HP -= 0.25
	$Hurt.play()
	print("Player got hit")
	self.modulate = Color(1,0,0)

func _process(delta):
	
	self.modulate = Color(1,1,1)
	
	match(state):
		GROUND:
			stats.crouch = false
			state_machine.travel("Idle")
			motion.y = 0
			Move_R_L(delta, true, true)
			move_and_slide_with_snap(motion,Vector2.DOWN * 8,Vector2.UP)
			
			$RayCast2D.position.y = -4
			$Shield/CollisionShape2D.position.y = -5
			
			if Input.is_action_just_pressed("ui_accept"):
				motion.y -= 100
				jump = true
				state = JUMPING
				continue
			if not is_on_floor():
				state = AIR
				continue
			if Input.is_action_pressed("ui_down"):
				state = CROUCH
				continue
			if Input.is_action_just_pressed("ui_attack"):
				state = ATTACK
				continue
				
		ATTACK:
			if collider.is_colliding():
				target = collider.get_collider()
				if target.name.find("Shield") < 0:
					target.hurt()
					$RayCast2D.enabled = false
				else:
					$RayCast2D.enabled = false
			Move_R_L(delta, false, false)
			motion.x = 0
			state_machine.travel("Attack")
			
		CROUCH:
			Move_R_L(delta, false, true)
			
			if not is_on_floor():
				motion.y += delta * GRAVITY
			
			state_machine.travel("Crouch")
			$RayCast2D.position.y = 6
			$Shield/CollisionShape2D.position.y = 7
			
			stats.crouch = true
			
			if not Input.is_action_pressed("ui_down"):
				state = GROUND
				continue
			if Input.is_action_just_pressed("ui_accept"):
				state = JUMPING
				continue
			if Input.is_action_just_pressed("ui_attack"):
				state = CROUCH_ATTACK
				continue
			
		CROUCH_ATTACK:
			Move_R_L(delta, false, false)
			target = collider.get_collider()
			if collider.is_colliding():
				if target.name.find("Shield") < 0:
					target.hurt()
					$RayCast2D.enabled = false
				else:
					$RayCast2D.enabled = false
			motion.x = 0
			state_machine.travel("CrouchAttack")

		JUMPING:
			Move_R_L(delta, false, false)
			move_and_slide(motion,Vector2.UP)
			motion.y -= delta * JUMP
			
			if Input.is_action_just_pressed("ui_attack"):
				state = AIR_ATTACK
				continue
			
			if Input.is_action_just_released("ui_accept") or motion.y <= JUMP_MAX:
				state = AIR
				continue
		
		AIR:
			Move_R_L(delta, false, false)
			move_and_slide(motion,Vector2.UP)
			motion.y += delta * GRAVITY
			
			if Input.is_action_just_pressed("ui_attack"):
				state = AIR_ATTACK
				continue
			
			if is_on_floor():
				state = GROUND
				continue
		
		AIR_ATTACK:
			target = collider.get_collider()
			if collider.is_colliding():
				if target.name.find("Shield") < 0:
					target.hurt()
					$RayCast2D.enabled = false
				else:
					$RayCast2D.enabled = false
			Move_R_L(delta, false, false)
			move_and_slide(motion,Vector2.UP)
			motion.y += delta * GRAVITY
			
			state_machine.travel("Attack")
			
			if is_on_floor():
				state = AIR
				continue
	
	if Input.is_action_just_pressed("ui_item"):
		if stats.can_shoot == true:
			var new_arrow = arrow.instance()
			new_arrow.position = self.position
			if $Sprite.flip_h == true:
				new_arrow.dir = -1
			else:
				new_arrow.dir = 1
			owner.add_child(new_arrow)
	
	$Label.text = "motion: " + str(move_dir) + " " + "x.move: " \
	+ str(stepify(motion.x, 0.11)) + "\n" + "y.move: " \
	+ str(stepify(motion.y, 0.11)) + "\n" + "State: " + str(state)\
	 + " " + str($Sprite.flip_h)
	


func _on_Hurtbox_area_entered(area):
	hurt()
	self.modulate = Color(1,0,0)
