extends Area2D

func _ready():
	pass # Replace with function body.

func dialog_listener(string):
	match string:
		"Pause":
			PlayerStats.pause = true
			get_tree().paused = true
	match string:
		"Bosslvl1End":
			PlayerStats.pause = false
			get_tree().paused = false
			self.queue_free()
func _on_Dialog7_area_entered(area):
	var dialog = Dialogic.start("Bosslvl1")
	dialog.pause_mode = PAUSE_MODE_PROCESS
	dialog.connect("dialogic_signal", self, "dialog_listener")
	add_child(dialog)
