extends Control

onready var sprite := $TextureRect/ColorRect/Sprite
onready var texture_rect := $TextureRect
onready var color_rect := $TextureRect/ColorRect

var maps : Array = [Map.new("res://Levels/SecondLevelPartA.tscn", Vector2(17,31), Vector2(1272,742), Vector2(0,88))]
var current_map_index := 0 

#func _ready():
#	color_rect.hide()

func _process(delta):
	if Input.is_action_just_pressed("show_map") && !GlobalVars.map_lock:
		show_map()
	if Input.is_action_just_released("show_map"):
		hide()

func set_level(path:String):
	for i in maps.size():
		if maps[i].path == path:
			current_map_index = i
	color_rect.position = maps[current_map_index].color_rect_position
	color_rect.rect_size = maps[current_map_index].color_rect_size
	sprite.position = maps[current_map_index].origin

func show_map():
	var real_level = get_tree().current_scene.current_level
	var real_level_origin = Vector2(real_level.level_range_x.x, real_level.level_range_y.x)
	
	var real_level_size = Vector2(real_level.level_range_x.y - real_level_origin.x, real_level.level_range_y.y - real_level_origin.y)
	var scale:Vector2 = Vector2(color_rect.rect_size.x/real_level_size.x, color_rect.rect_size.y/real_level_size.y) 
	
	sprite.position = maps[current_map_index].origin + Vector2(get_tree().current_scene.player.global_position.x * scale.x, get_tree().current_scene.player.global_position.y * scale.y)
	show()

class Map:
	var path:String
	var color_rect_position:Vector2
	var color_rect_size:Vector2
	var origin:Vector2
	func _init(init_path, init_color_rect_position, init_color_rect_size, init_origin):
		color_rect_position = init_color_rect_position
		color_rect_size = init_color_rect_size
		origin = init_origin
		path = init_path
