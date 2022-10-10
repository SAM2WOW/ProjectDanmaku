extends Node


var boss_health = 1000


func _ready():
	Global.console = self
	
	$"../CanvasLayer/Control/HealthBar".set_max(boss_health)
	$"../CanvasLayer/Control/HealthBar".set_value(boss_health)


func damage_boss(amount):
	boss_health -= amount
	
	$"../CanvasLayer/Control/HealthBar".set_value(boss_health)
