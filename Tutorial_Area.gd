extends Node2D

func _ready():
	PlayerStats.pause = true



func _on_EnterTemple_area_entered(area):
	SceneChanger.change_scene("res://Scenes/Levels/BossLevel.tscn")
