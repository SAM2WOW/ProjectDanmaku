extends Node


var sounds = {
	"Lazer": "res://sounds/Lazer.wav",
}


func _ready():
	for i in sounds.keys():
		var s = AudioStreamPlayer2D.new()
		s.set_stream(load(sounds[i]))
		s.set_bus("Sound")
		s.name = i
		s.set_script(load("res://scripts/AudioRandomizer.gd"))
		add_child(s)


func play(sound_name):
	get_node(sound_name).play()


func play_positional(sound_name, position):
	get_node(sound_name).set_global_position(position)
	get_node(sound_name).play()
