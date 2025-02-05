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
extends PlayerState

onready var footstep_player = $Footstep1
onready var secondary_footstep_player = $Footstep2

func enter(_msg := {}) -> void:
	player.animation_tree.set('parameters/Run/blend_position', 1 if player.facing_right else -1)
	player.animation_mode.travel("Run")

func physics_update(delta: float) -> void:
	# Notice how we have some code duplication between states. That's inherent to the pattern,
	# although in production, your states will tend to be more complex and duplicate code
	# much more rare.
	if not player.is_on_floor():
		check_floor()
		
	# We move the run-specific input code to the state.
	# A good alternative would be to define a `get_input_direction()` function on the `Player.gd`
	# script to avoid duplicating these lines in every script.
	var input_direction_x: float = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)
	
	# Check to see if we need to transition state
	
	if Input.is_action_pressed("crouch"):
		state_machine.transition_to("Crouched")
		return
	
	if Input.is_action_just_pressed("move_up"):
		state_machine.transition_to("Air", {do_jump = true})
	elif -0.5 < player.velocity.x and player.velocity.x < 0.5 && is_equal_approx(input_direction_x, 0.0):
		player.velocity = Vector2.ZERO
		state_machine.transition_to("Idle")
	elif Input.is_action_pressed("dash"):
		state_machine.transition_to("Dashing")
		return
	
	# Check to see if the player needs to turn around
	if player.facing_right != (input_direction_x > 0) && input_direction_x != 0:
		player.facing_right = input_direction_x > 0
		player.sprite.flip_h = !player.facing_right
		player.animation_tree.set('parameters/Run/blend_position', 1 if player.facing_right else -1)
		player.animation_tree.set('parameters/Idle/blend_position', 1 if player.facing_right else -1)
		player.camera_arm.position.x = 127 if player.facing_right else -127
	
	# Move
	if is_equal_approx(input_direction_x, 0.0):
		player.velocity.x = lerp(player.velocity.x, 0, player.DECELERATION)
	else:
		player.velocity.x += player.ACCELERATION * input_direction_x
	player.velocity.x = clamp(player.velocity.x, -player.SPEED, player.SPEED)
	player.velocity = player.move_and_slide_with_snap(player.velocity, Vector2.DOWN * 16, Vector2.UP, false, 4, PI/4, false)
	
	if Input.is_action_pressed("shoot") && player.can_shoot:
		if GlobalVars.ammo_equipped_array.size() != 0 && GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index] != null && GlobalVars.sugar >= GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index].sugar:
			state_machine.transition_to("Aim")

func check_floor():
	yield(get_tree().create_timer(0.1), "timeout")
	if is_instance_valid(player) and not player.is_on_floor():
		state_machine.transition_to("Air", {coyote_time = true})

func play_footstep():
	if footstep_player.playing:
		secondary_footstep_player.stream = ResourceLoader.load("res://Actors/Player/Running/Sound/footstep%s.mp3"%((randi()%7)+1))
		secondary_footstep_player.play()
	else:
		footstep_player.stream = ResourceLoader.load("res://Actors/Player/Running/Sound/footstep%s.mp3"%((randi()%7)+1))
		footstep_player.play()
