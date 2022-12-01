extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerStats.HP = PlayerStats.MaxHP
	PlayerStats.has_bow = true
	var dialog = Dialogic.start("END")
	dialog.pause_mode = PAUSE_MODE_PROCESS
	dialog.connect("dialogic_signal", self, "dialog_listener")
	add_child(dialog)

func dialog_listener(string):
	match string:
		"Pause":
			PlayerStats.pause = true
			$Player/UI.visible = false
			get_tree().paused = true
	match string:
		"Unpause":
			PlayerStats.pause = false
			$Player/UI.visible = true
			get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
