extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func dialog_listener(string):
	match string:
		"Pause":
			PlayerStats.pause = true
			get_tree().paused = true
	match string:
		"Tutorial2End":
			PlayerStats.pause = false
			get_tree().paused = false
			self.queue_free()


func _on_Dialog3_area_entered(area):
	var dialog = Dialogic.start("Tutorial2")
	dialog.pause_mode = PAUSE_MODE_PROCESS
	dialog.connect("dialogic_signal", self, "dialog_listener")
	add_child(dialog)
