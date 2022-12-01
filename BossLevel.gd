extends Node2D

func _ready():
	var dialog = Dialogic.start("Bosslvl")
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
