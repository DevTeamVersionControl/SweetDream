extends KinematicBody2D

signal changed_ammo(ammo_index)
signal update(vari)

export var MAX_BOUNCE = 60
export var MAX_FALL_SPEED = 120.5
export var MAX_SPEED = 7
export var JUMP_FORCE = 34
export var ACCEL = 2
export var JUMP_ACCEL = 1.8
export var hp := 10
export var gravity := 9.8
var knockback_strength = 20

const PIXELS_PER_METER = 16
const MAX_BULLET_STRENGTH = 1
const UP = Vector2.UP

var facing = Vector2(1,0)
var bullet_direction = Vector2()
var bullet_strength := 0.0
var bullet_cooldown := 0.0

var jumping := false
var can_shoot := true
var invulnerable := false
var crush_detection := true
var screen_size
var bullet

var motion = Vector2()

func _ready():
	screen_size = get_viewport_rect().size
	if GlobalVars.hp == 0:
		GlobalVars.hp = hp
	#$Camera2D.set_limit(MARGIN_BOTTOM, screen_size.y)
	#$Camera2D.set_limit(MARGIN_TOP, 0)
	#$Camera2D.set_limit(MARGIN_LEFT, 0)
	#$Camera2D.set_limit(MARGIN_RIGHT, screen_size.x)

func update():
	emit_signal("changed_ammo", GlobalVars.equiped_ammo)

func _physics_process(delta):
	
	if $AmmoTimer.time_left > 0 && !can_shoot:
		$CooldownBar.scale.x = $AmmoTimer.time_left / (bullet_cooldown * 20)
	
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("ammo_next"): #&& can_shoot
		if bullet != null && is_a_parent_of(bullet):
			bullet.queue_free()
		bullet = null
		GlobalVars.equiped_ammo = GlobalVars.ammo_instance_array.find(GlobalVars.ammo_equipped_array[(GlobalVars.ammo_equipped_array.find(GlobalVars.ammo_instance_array[GlobalVars.equiped_ammo], 0) + 1) % GlobalVars.ammo_equipped_array.size()], 0)
		emit_signal("changed_ammo", GlobalVars.equiped_ammo)
	
	if(Input.is_action_just_pressed("shoot")):
		if (GlobalVars.equiped_ammo == GlobalVars.ammo_type.jawbreaker || GlobalVars.equiped_ammo == GlobalVars.ammo_type.jello) && can_shoot:
			$ShootBar.visible = true
			bullet_strength = 0.2
		elif (GlobalVars.equiped_ammo == GlobalVars.ammo_type.icing_gun || GlobalVars.equiped_ammo == GlobalVars.ammo_type.popping_candy) && can_shoot:
			if bullet == null:
				shoot(GlobalVars.ammo_instance_array[GlobalVars.equiped_ammo], bullet_strength)
			else:
				if bullet.rotation_degrees == -90 && facing.x != 1:
					bullet.queue_free()
					shoot(GlobalVars.ammo_instance_array[GlobalVars.equiped_ammo], bullet_strength)
				elif bullet.rotation_degrees == 90 && facing.x != -1:
					bullet.queue_free()
					shoot(GlobalVars.ammo_instance_array[GlobalVars.equiped_ammo], bullet_strength)
		elif can_shoot:
			shoot(GlobalVars.ammo_instance_array[GlobalVars.equiped_ammo], bullet_strength)
	
	if(Input.is_action_pressed("shoot")):
		if $ShootBar.visible:
			if bullet_strength <= MAX_BULLET_STRENGTH:
				bullet_strength += delta/2
				$ShootBar.scale.x = bullet_strength/20
	
	if(Input.is_action_just_released("shoot")):
		if bullet_strength != 0 && $ShootBar.visible:
			shoot(GlobalVars.ammo_instance_array[GlobalVars.equiped_ammo], bullet_strength)
			bullet_strength = 0
			$ShootBar.visible = false
			$ShootBar.scale.x = 0
	
	motion.y += gravity/2 * pow(delta * 45,2)
	
	if motion.y > MAX_FALL_SPEED:
		motion.y = MAX_FALL_SPEED
	
	if (Input.is_action_pressed("up")):
		bullet_direction.y = -1
	elif (Input.is_action_pressed("down")):
		bullet_direction.y = 1
	else:
		bullet_direction.y = 0
	
	if (Input.is_action_pressed("right")):
		bullet_direction.x = 1
		motion.x += ACCEL
		facing.x = 1
	elif (Input.is_action_pressed("left")):
		bullet_direction.x = -1
		motion.x -= ACCEL
		facing.x = -1
	else:
		motion.x = lerp(motion.x, 0, 0.2)
		bullet_direction.x = 0
		if bullet_direction.y == 0 && bullet_direction.x == 0:
			bullet_direction = facing
	
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	
	if 	is_on_floor():
		if (Input.is_action_just_pressed("jump")):
			motion.y = -JUMP_FORCE
			jumping = true
		elif (jumping):
			jumping = false
	if (Input.is_action_pressed("jump")) && jumping && motion.y < 0:
		motion.y -= JUMP_ACCEL
	var snap = Vector2.ZERO if jumping else Vector2.DOWN * 16
	motion = move_and_slide_with_snap(motion * PIXELS_PER_METER, snap, UP, false,  4, PI/4, false)
	motion /= PIXELS_PER_METER
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("movable") && collision.normal.y > -0.2:
			collision.collider.set_linear_velocity(Vector2(lerp(collision.collider.linear_velocity.x, MAX_SPEED * PIXELS_PER_METER * collision.normal.x, ACCEL), collision.collider.linear_velocity.y))
			collision.collider.set_linear_velocity(Vector2(clamp(collision.collider.linear_velocity.x, MAX_SPEED * 16, -MAX_SPEED * 16),collision.collider.linear_velocity.y))
			motion.x = collision.collider.linear_velocity.x / PIXELS_PER_METER
	
	if global_position.y > screen_size.y:
		get_tree().reload_current_scene()

func shoot(ammo, strength):
	if invulnerable:
		return
	bullet = ammo.instance()
	add_child(bullet)
	bullet_direction = bullet_direction.normalized()
	bullet.global_position = global_position + Vector2.UP * 20
	bullet.launch(bullet_direction, bullet_strength)
	can_shoot = false
	bullet_cooldown = bullet.COOLDOWN
	$AmmoTimer.start(bullet_cooldown)
	$CooldownBar.visible = true

func take_damage(damage, direction):
	if invulnerable:
		return
	GlobalVars.hp -= damage
	motion.x += direction.x * 4
	if GlobalVars.hp <= 0:
		get_tree().reload_current_scene()
	invulnerable = true
	$AnimatedSprite.playing = true
	yield($AnimatedSprite, "animation_finished")
	$AnimatedSprite.playing = false
	$AnimatedSprite.frame = 0
	invulnerable = false
	emit_signal("update", "HP:" + String(GlobalVars.hp))

func _on_AmmoTimer_timeout():
	can_shoot = true
	$CooldownBar.visible = false

func _on_Area2D_body_entered(body):
	if body.is_in_group("destructable"):
		body.can_reappear = false
	if body.is_in_group("enemy"):
		take_damage(2, body.motion.normalized() * knockback_strength)

func _on_Area2D_body_exited(body):
	if body.is_in_group("destructable"):
		body.can_reappear = true
		if body.should_reappear:
			body.reappear()

func _on_InvulnerabilityTimer_timeout():
	invulnerable = false

func _on_BounceBox_area_entered(area):
	if motion.y > 0 && !invulnerable:
		if motion.length() < MAX_BOUNCE:
			motion.y *= -1.4
			motion.x *= 2
		if area.get_parent().is_in_group("enemy"):
			invulnerable = true
			$InvulnerabilityTimer.start(0.5)
		area.get_parent().bounce()

func _on_CrushBox_body_entered(body):
	if body.is_in_group("floor") && crush_detection:
		get_tree().reload_current_scene()

func _on_CrushTimer_timeout():
	crush_detection = true
