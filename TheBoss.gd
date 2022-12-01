extends Node2D

export(PackedScene) var BULLET: PackedScene = null

var target: Node2D = null

var HP = 24

var weakened = false

onready var gunSprite = $Eyeball
onready var rayCast = $RayCast2D
onready var reloadTimer = $RayCast2D/ReloadTimer


func _ready():
	yield(get_tree(), "idle_frame")
	target = find_target()

func _physics_process(delta):
	if target != null:
		var angle_to_target: float = global_position.direction_to(target.global_position).angle()
		rayCast.global_rotation = angle_to_target
		gunSprite.rotation = angle_to_target
		
		if rayCast.is_colliding() and rayCast.get_collider().is_in_group("Player"):
			if reloadTimer.is_stopped():
				shoot()
	
	if HP <= 0:
		SceneChanger.change_scene("res://Scenes/Stats/Ending.tscn")
	
func shoot():
	rayCast.enabled = false
	
	if BULLET:
		var bullet: Node2D = BULLET.instance()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		bullet.global_rotation = rayCast.global_rotation
	reloadTimer.start()

func find_target():
	var new_target: Node2D = null
	
	if get_tree().has_group("Player"):
		new_target = get_tree().get_nodes_in_group("Player")[0]
	
	return new_target

func _on_ReloadTimer_timeout():
	reloadTimer.stop()
	rayCast.enabled = true

func _on_Area2D_area_entered(area):
	$Attacked.play()
	if weakened != true:
		rayCast.enabled = false
		reloadTimer.stop()
		$AnimationPlayer.play("Weakened")
		$AnimationPlayer2.play("attacked")
	
	HP -= 1
	print(HP)

func hurt():
	$AnimationPlayer2.play("attacked")
	HP -= 1
	print(HP)

func _backup():
	weakened == false
	rayCast.enabled = true

func hurted():
	$Attacked.play()
