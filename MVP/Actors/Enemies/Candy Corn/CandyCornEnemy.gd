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
class_name CandyCorn
extends KinematicBody2D

const SPEED = 80
const KNOCKBACK = 100
const ATTACK_DAMAGE = 10
const BODY_DAMAGE = 5

var health := 10.0
var target : Player
var facing_right := false
var motion := Vector2.ZERO

onready var animation_player := $AnimationPlayer
onready var sprite := $Sprite
onready var state_machine := $StateMachine
onready var interest_timer := $InterestTimer

# Sound effects
onready var audio_stream_player := $AudioStreamPlayer
const HIT = preload("res://Actors/Enemies/Enemy Hit.wav")
const DEATH = preload("res://Actors/Enemies/Enemy Death.wav")
const WALK = preload("res://Actors/Enemies/Candy Corn/Candy Corn Walk.wav")
const ATTACK = preload("res://Actors/Enemies/Candy Corn/Candy Corn Attack.wav")

func take_damage(damage:float, knockback:Vector2):
	health -= damage
	motion += knockback
	if state_machine.state.name == "Idle":
		$StateMachine/Idle.on_something_detected(get_tree().current_scene.player)
	if health <= 0:
		state_machine.transition_to("Death")
		GlobalVars.play_sound(DEATH)
	else:
		$Sprite.get_material().set("shader_param/flashState", 1.0)
		yield(get_tree().create_timer(0.1), "timeout")
		$Sprite.get_material().set("shader_param/flashState", 0.0)
		$AudioStreamPlayer2D.play()

func on_hit_something(something):
	if something is Player:
		something.take_damage(5, Vector2.ZERO)
	else:
		$Sprite.get_material().set("shader_param/flashState", 1.0)
		yield(get_tree().create_timer(0.1), "timeout")
		$Sprite.get_material().set("shader_param/flashState", 0.0)
