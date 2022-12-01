extends Area2D

func _ready():
	pass # Replace with function body.

func dialog_listener(string):
	match string:
		"Pause":
			PlayerStats.pause = true
			get_tree().paused = true
	match string:
		"Yrsf1End":
			PlayerStats.has_bow = true
			SceneChanger.change_scene("res://Scenes/Levels/OneEyeBoss.tscn")
func _on_EVIL_area_entered(area):
	var dialog = Dialogic.start("Yrsf1")
	dialog.pause_mode = PAUSE_MODE_PROCESS
	dialog.connect("dialogic_signal", self, "dialog_listener")
	add_child(dialog)
