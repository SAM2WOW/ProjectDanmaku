extends Node2D


var style = 0

func _ready():
	Global.background = self
	_on_Verse_Jump(Global.initial_style);

func _on_Verse_Jump(verse):
	style = verse
	Global.current_style = verse
	get_node("Style%d" % style).show()
	if is_instance_valid(Global.boss):
		Global.boss.break_state = false
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()
			print("Style%d" % style)
