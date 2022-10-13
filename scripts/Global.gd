extends Node


var console
var player
var boss
var camera
var background
var portal

var initial_style = 0
var total_style = 4
var current_style = initial_style

var window_width = ProjectSettings.get_setting("display/window/size/width");
var window_height = ProjectSettings.get_setting("display/window/size/height");

var player_bullet_properties = {
	0: {"damage":10, "fire rate":0.3, "speed":900},
	1: {"damage":50, "fire rate":0.75, "speed":1500},
	2: {"damage":100, "fire rate":0.6, "speed":900},
	3: {"damage":10, "fire rate":0.4, "speed":1000}
}

var boss_bullet_properties = {
	0: {"damage": 30, "speed": 300},
	1: {"damage": 40, "speed": 1000},
	2: {"damage": 40},
	3: {"damage": 20, "speed": 300}
}
