extends Area2D

func _ready():
	pass # Replace with function body.

func dialog_listener(string):
	match string:
		"Pause":
			PlayerStats.pause = true
			get_tree().paused = true
	match string:
		"Tutorial5End":
			PlayerStats.pause = false
			get_tree().paused = false
			self.queue_free()
func _on_Dialog6_area_entered(area):
	var dialog = Dialogic.start("Tutorial5")
	dialog.pause_mode = PAUSE_MODE_PROCESS
	dialog.connect("dialogic_signal", self, "dialog_listener")
	add_child(dialog)
