# Sweet Dream, a sweet metroidvannia
#    Copyright (C) 2022 Kamran Charles Nayebi and William Duplain
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
extends Node

const DEFAULT_SAVE_PATH = "user://SaveData.json"

var save_path := DEFAULT_SAVE_PATH

func save():
	var file = File.new()
	var save_data = {}
	if file.file_exists(save_path):
		file.open(save_path, File.READ)
		var json = file.get_as_text()
		save_data = parse_json(json)
		file.close()
	for node in get_tree().get_nodes_in_group("save"):
		node.save(save_data)
	var error = file.open(save_path, File.WRITE)
	if error != OK:
		printerr("Could not create save file")
		return
	var json_string := JSON.print(save_data)
	file.store_string(json_string)
	file.close()

func load():
	var file = File.new()
	var error = file.open(save_path, File.READ)
	if error != OK:
		printerr("Could not load save")
		return
	var json_string = file.get_as_text()
	file.close()
	if json_string == "":
		return
	var save_data : Dictionary = JSON.parse(json_string).result
	for node in get_tree().get_nodes_in_group("save"):
		node.load(save_data)

func partial_load(node:Node):
	var file = File.new()
	var error = file.open(node.save_path, File.READ)
	if error != OK:
		printerr("Could not load save")
		return
	var json_string = file.get_as_text()
	file.close()
	if json_string == "":
		return
	var save_data : Dictionary = JSON.parse(json_string).result
	node.load(save_data)
	
func partial_save(node:Node):
	var file = File.new()
	var save_data = {}
	if file.file_exists(node.save_path):
		file.open(node.save_path, File.READ)
		var json = file.get_as_text()
		save_data = parse_json(json)
		file.close()
	node.save(save_data)
	var error = file.open(node.save_path, File.WRITE)
	if error != OK:
		printerr("Could not create save file")
		return
	var json_string := JSON.print(save_data)
	file.store_string(json_string)
	file.close()
