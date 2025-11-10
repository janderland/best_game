extends KinematicBody2D

# Enemy - Base class for hostile entities

signal enemy_died(enemy_type)

export var enemy_type = "shadow_lurker"
export var health = 50.0
export var max_health = 50.0
export var damage = 10.0
export var speed = 100.0
export var detection_range = 300.0
export var attack_range = 50.0

var velocity = Vector2.ZERO
var player_detected = false
var player_ref = null
var attack_cooldown = 0.0
var is_attacking = false
var is_dead = false

# Behavior parameters
var wander_timer = 0.0
var wander_direction = Vector2.ZERO
var aggro_level = 0.0

# Visual
onready var sprite = $Sprite if has_node("Sprite") else null
onready var collision_shape = $CollisionShape2D if has_node("CollisionShape2D") else null

func _ready():
	add_to_group("enemies")

	# Generate appearance
	generate_appearance()

	# Find player
	call_deferred("find_player")

func _process(delta):
	if is_dead:
		return

	# Update timers
	if attack_cooldown > 0:
		attack_cooldown -= delta

	wander_timer -= delta

	# Check for player detection
	check_player_detection()

	# Behavior based on awareness
	if player_detected and player_ref:
		pursue_player(delta)
	else:
		wander(delta)

func _physics_process(delta):
	if is_dead:
		return

	# Move
	velocity = move_and_slide(velocity)

	# Face movement direction
	if sprite and velocity.length() > 10:
		sprite.flip_h = velocity.x < 0

func find_player():
	"""Find player reference"""
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]

func generate_appearance():
	"""Generate enemy visual appearance"""
	if sprite:
		var tex = ImageTexture.new()
		var img = ProceduralArt.generate_enemy_sprite(enemy_type, 64)
		tex.create_from_image(img)
		sprite.texture = tex

		# Add subtle animation/bobbing
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(sprite, "position:y", 0, -5, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.interpolate_property(sprite, "position:y", -5, 0, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.0)
		tween.repeat = true
		tween.start()

func check_player_detection():
	"""Check if player is in detection range"""
	if not player_ref or is_dead:
		player_detected = false
		return

	var distance_to_player = global_position.distance_to(player_ref.global_position)

	# Detection modified by player's sanity
	var perception = SanitySystem.get_enemy_perception()
	var effective_detection_range = detection_range * perception

	if distance_to_player < effective_detection_range:
		player_detected = true
		aggro_level = min(1.0, aggro_level + 0.01)
	else:
		# Lose aggro gradually
		aggro_level = max(0.0, aggro_level - 0.005)
		if aggro_level <= 0:
			player_detected = false

	# Sanity drain when near player
	if distance_to_player < 150:
		var drain_amount = (150 - distance_to_player) / 150.0 * 0.1
		SanitySystem.drain_sanity(get_process_delta_time(), drain_amount)

func pursue_player(delta):
	"""Chase and attack player"""
	if not player_ref:
		return

	var direction_to_player = (player_ref.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player_ref.global_position)

	# Different behavior based on enemy type
	match enemy_type:
		"shadow_lurker":
			shadow_lurker_behavior(direction_to_player, distance_to_player, delta)
		"memory_wraith":
			memory_wraith_behavior(direction_to_player, distance_to_player, delta)
		"forgotten_one":
			forgotten_one_behavior(direction_to_player, distance_to_player, delta)
		"grief_incarnate":
			grief_incarnate_behavior(direction_to_player, distance_to_player, delta)
		"hollow_echo":
			hollow_echo_behavior(direction_to_player, distance_to_player, delta)
		_:
			default_behavior(direction_to_player, distance_to_player, delta)

	# Check for attack
	if distance_to_player < attack_range and attack_cooldown <= 0:
		attack_player()

func shadow_lurker_behavior(direction: Vector2, distance: float, _delta):
	"""Stalks from shadows, fast attacks"""
	if distance > attack_range * 1.5:
		# Teleport closer occasionally
		if randf() < 0.02:
			global_position = lerp(global_position, player_ref.global_position, 0.5)
			print("Shadow Lurker teleports!")
	else:
		velocity = direction * speed * 1.5  # Fast approach

func memory_wraith_behavior(direction: Vector2, distance: float, _delta):
	"""Floats, phases through obstacles, drains sanity"""
	velocity = direction * speed * 0.8  # Slow floating
	# Extra sanity drain
	SanitySystem.drain_sanity(get_process_delta_time(), 0.5)

	# Randomly phase/become transparent
	if sprite and randf() < 0.05:
		sprite.modulate.a = 0.3 if sprite.modulate.a > 0.5 else 1.0

func forgotten_one_behavior(direction: Vector2, distance: float, _delta):
	"""Erratic movement, sometimes freezes"""
	if randf() < 0.05:
		# Freeze in place
		velocity = Vector2.ZERO
		yield(get_tree().create_timer(1.0), "timeout")
	else:
		# Erratic movement
		var erratic = Vector2(randf() - 0.5, randf() - 0.5).normalized()
		velocity = (direction * 0.7 + erratic * 0.3).normalized() * speed

func grief_incarnate_behavior(direction: Vector2, distance: float, _delta):
	"""Slow, inexorable, heavy sanity damage"""
	velocity = direction * speed * 0.5  # Very slow
	# Heavy sanity drain
	SanitySystem.drain_sanity(get_process_delta_time(), 1.0)

	# Visual weight effect
	if sprite:
		sprite.modulate = Color(0.3, 0.3, 0.4, 1.0)

func hollow_echo_behavior(direction: Vector2, distance: float, _delta):
	"""Mimics player movement with delay"""
	# Store player positions and follow with delay
	if distance > attack_range:
		velocity = direction * speed * 1.2
	else:
		# Circle around player
		var perpendicular = Vector2(-direction.y, direction.x)
		velocity = perpendicular * speed

func default_behavior(direction: Vector2, _distance: float, _delta):
	"""Default chase behavior"""
	velocity = direction * speed

func wander(delta):
	"""Random wandering when player not detected"""
	if wander_timer <= 0:
		wander_direction = Vector2(randf() - 0.5, randf() - 0.5).normalized()
		wander_timer = randf() * 2.0 + 1.0

	velocity = wander_direction * speed * 0.3

func attack_player():
	"""Attack the player"""
	if not player_ref or is_dead:
		return

	is_attacking = true
	attack_cooldown = 2.0

	print(enemy_type, " attacks!")

	# Deal damage
	if player_ref.has_method("take_damage"):
		player_ref.take_damage(damage, enemy_type)

	# Deal sanity damage based on type
	var sanity_damage = get_sanity_damage()
	if player_ref.has_method("take_sanity_damage"):
		player_ref.take_sanity_damage(sanity_damage, enemy_type)

	# Visual feedback
	if sprite:
		sprite.modulate = Color(1.5, 0.5, 0.5, 1.0)
		yield(get_tree().create_timer(0.2), "timeout")
		if sprite:
			sprite.modulate = Color(1, 1, 1, 1)

	is_attacking = false

func get_sanity_damage() -> float:
	"""Get sanity damage based on enemy type"""
	match enemy_type:
		"shadow_lurker":
			return 5.0
		"memory_wraith":
			return 15.0
		"forgotten_one":
			return 8.0
		"grief_incarnate":
			return 20.0
		"hollow_echo":
			return 10.0
		_:
			return 5.0

func take_damage(amount: float):
	"""Take damage"""
	if is_dead:
		return

	health -= amount
	print(enemy_type, " took ", amount, " damage. Health: ", health)

	# Visual feedback
	if sprite:
		sprite.modulate = Color(1.5, 1.5, 1.5, 1.0)
		yield(get_tree().create_timer(0.1), "timeout")
		if sprite:
			sprite.modulate = Color(1, 1, 1, 1)

	if health <= 0:
		die()

func die():
	"""Enemy death"""
	if is_dead:
		return

	is_dead = true
	print(enemy_type, " defeated!")

	emit_signal("enemy_died", enemy_type)

	# Visual death effect
	if sprite:
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(sprite, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(sprite, "scale", sprite.scale, Vector2.ZERO, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_all_completed")

	# Remove from scene
	queue_free()

func stun(duration: float):
	"""Stun enemy temporarily"""
	velocity = Vector2.ZERO
	player_detected = false

	yield(get_tree().create_timer(duration), "timeout")

func knockback(direction: Vector2, force: float):
	"""Apply knockback"""
	velocity = direction.normalized() * force
