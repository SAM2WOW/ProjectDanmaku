extends Node2D


var style = 0


func _on_Verse_Jump(verse):
	style = verse
	
	get_node("Style%d" % style).show()
	
	for i in range(3):
		if i != style:
			get_node("Style%d" % i).hide()
			print("Style%d" % style)
