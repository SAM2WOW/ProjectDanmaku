extends Node


var console
var player

var initial_style = 0
var total_style = 3
var prev_style = initial_style;
var current_style = initial_style

var window_width = ProjectSettings.get_setting("display/window/size/width");
var window_height = ProjectSettings.get_setting("display/window/size/height");

var player_bullet_properties = {
	0: {"damage":5, "fire rate":0.2, "speed":900},
	1: {"damage":20, "fire rate":0.5, "speed":700},
	2: {"damage":10, "fire rate":0.4, "speed":900}
}
