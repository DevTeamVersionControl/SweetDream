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
extends JawbreakerBossState

func enter(_msg := {}) -> void:
	jawbreaker_boss.get_node("CollisionShape2D").set_deferred("disabled", true)
	jawbreaker_boss.animation_player.play("Death")
	yield(jawbreaker_boss.animation_player, "animation_finished")
	jawbreaker_boss.emit_signal("died")
	jawbreaker_boss.queue_free()

func shake():
	get_tree().current_scene.shaker.start(1, 15, 20)
