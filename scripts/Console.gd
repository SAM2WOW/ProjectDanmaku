extends Node


var boss_health = 5000
var portal

func _ready():
	Global.console = self
	
	$"../CanvasLayer/Control/HealthBar".set_max(boss_health)
	$"../CanvasLayer/Control/HealthBar".set_value(boss_health)
	
	play_shockwave($"../Node2D")


func damage_boss(amount):
	boss_health -= amount
	
	$"../CanvasLayer/Control/HealthBar".set_value(boss_health)
	
	if boss_health <= 0:
		print("You Win")
		
		get_tree().reload_current_scene()


func play_shockwave(actor):
	#var h = actor.get_global_transform_with_canvas().origin.x / $CanvasLayer.get_viewport_rect().size.x
	#var v = actor.get_global_transform_with_canvas().origin.y / $CanvasLayer.get_viewport_rect().size.y
	#$Shockwave.get_material().set_shader_param("")
	
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($"../CanvasLayer/Control/Shockwave".get_material(), "shader_param/Radius", 1, 5)
