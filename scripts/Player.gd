extends KinematicBody2D

# Player Controller - Handles player movement, interactions, and state

signal player_died()
signal health_changed(current, maximum)
signal sanity_changed(current, maximum)
signal interaction_available(target)

const SPEED = 200.0
const ACCELERATION = 1000.0
const FRICTION = 800.0

var velocity = Vector2.ZERO
var can_move = true
var is_in_dialogue = false

# References
var current_interaction_target = null
var nearby_interactables = []

# Visual components
onready var sprite = $Sprite if has_node("Sprite") else null
onready var animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null
onready var interaction_area = $InteractionArea if has_node("InteractionArea") else null

func _ready():
	print("Player initialized")

	# Connect to game manager signals
	GameManager.connect("game_state_changed", self, "_on_game_state_changed")

	# Set up interaction area
	if interaction_area:
		interaction_area.connect("area_entered", self, "_on_interaction_area_entered")
		interaction_area.connect("area_exited", self, "_on_interaction_area_exited")

	update_health_display()
	update_sanity_display()

func _process(_delta):
	# Check for interaction input
	if Input.is_action_just_pressed("interact") and current_interaction_target:
		interact_with_target()

	# Check for pause
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func _physics_process(delta):
	if not can_move or is_in_dialogue:
		apply_friction(delta)
		velocity = move_and_slide(velocity)
		return

	# Get input direction
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()

	# Apply sanity-based movement instability
	var stability = SanitySystem.get_movement_stability()
	if stability < 1.0:
		var noise_x = (randf() - 0.5) * (1.0 - stability) * 2.0
		var noise_y = (randf() - 0.5) * (1.0 - stability) * 2.0
		input_vector += Vector2(noise_x, noise_y)
		input_vector = input_vector.normalized()

	# Movement
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)

		# Update sprite direction
		if sprite and input_vector.x != 0:
			sprite.flip_h = input_vector.x < 0

		# Track distance traveled
		GameManager.total_distance_traveled += velocity.length() * delta
	else:
		apply_friction(delta)

	velocity = move_and_slide(velocity)

	# Update animation based on movement
	update_animation()

func apply_friction(delta):
	"""Apply friction to gradually stop movement"""
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

func update_animation():
	"""Update animation based on current state"""
	if not animation_player:
		return

	if velocity.length() > 10:
		if not animation_player.is_playing() or animation_player.current_animation != "walk":
			animation_player.play("walk")
	else:
		if not animation_player.is_playing() or animation_player.current_animation != "idle":
			animation_player.play("idle")

func take_damage(amount: float, source: String = ""):
	"""Take damage from a source"""
	print("Player took ", amount, " damage from ", source)

	if GameManager.damage_player(amount):
		emit_signal("player_died")

	update_health_display()

	# Visual feedback
	flash_hurt()

func take_sanity_damage(amount: float, source: String = ""):
	"""Take sanity damage"""
	print("Player lost ", amount, " sanity from ", source)
	GameManager.modify_sanity(-amount)
	SanitySystem.apply_sanity_damage(amount / 100.0, source)

	update_sanity_display()

func heal(amount: float):
	"""Heal player"""
	GameManager.heal_player(amount)
	update_health_display()

func restore_sanity(amount: float):
	"""Restore sanity"""
	GameManager.modify_sanity(amount)
	update_sanity_display()

func update_health_display():
	"""Update health UI"""
	emit_signal("health_changed", GameManager.player_health, GameManager.player_max_health)

func update_sanity_display():
	"""Update sanity UI"""
	emit_signal("sanity_changed", GameManager.player_sanity, GameManager.player_max_sanity)

func flash_hurt():
	"""Visual feedback for taking damage"""
	if sprite:
		sprite.modulate = Color(1, 0.3, 0.3, 1)
		yield(get_tree().create_timer(0.1), "timeout")
		if sprite:
			sprite.modulate = Color(1, 1, 1, 1)

func _on_interaction_area_entered(area):
	"""Handle entering interaction range"""
	if area.is_in_group("interactable"):
		nearby_interactables.append(area)
		update_closest_interactable()

func _on_interaction_area_exited(area):
	"""Handle leaving interaction range"""
	if area in nearby_interactables:
		nearby_interactables.erase(area)
		update_closest_interactable()

func update_closest_interactable():
	"""Find closest interactable object"""
	if nearby_interactables.empty():
		current_interaction_target = null
		emit_signal("interaction_available", null)
		return

	# Find closest
	var closest = null
	var closest_dist = INF

	for interactable in nearby_interactables:
		var dist = global_position.distance_to(interactable.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = interactable

	current_interaction_target = closest
	emit_signal("interaction_available", closest)

func interact_with_target():
	"""Interact with current target"""
	if not current_interaction_target:
		return

	print("Interacting with: ", current_interaction_target.name)

	# Check sanity-based interaction reliability
	var reliability = SanitySystem.get_interaction_reliability()
	if randf() > reliability:
		print("Interaction failed due to low sanity")
		return

	# Call interact method on target
	if current_interaction_target.has_method("interact"):
		current_interaction_target.interact(self)

func start_dialogue():
	"""Enter dialogue mode"""
	is_in_dialogue = true
	can_move = false
	GameManager.set_game_state(GameManager.GameState.DIALOGUE)

func end_dialogue():
	"""Exit dialogue mode"""
	is_in_dialogue = false
	can_move = true
	GameManager.set_game_state(GameManager.GameState.PLAYING)

func toggle_pause():
	"""Toggle pause state"""
	if GameManager.current_state == GameManager.GameState.PAUSED:
		GameManager.set_game_state(GameManager.GameState.PLAYING)
	else:
		GameManager.set_game_state(GameManager.GameState.PAUSED)

func _on_game_state_changed(new_state):
	"""Handle game state changes"""
	match new_state:
		GameManager.GameState.PLAYING:
			can_move = true
			is_in_dialogue = false
		GameManager.GameState.DIALOGUE:
			can_move = false
			is_in_dialogue = true
		GameManager.GameState.PAUSED:
			can_move = false
		GameManager.GameState.GAME_OVER:
			can_move = false
		GameManager.GameState.VICTORY:
			can_move = false

func get_position() -> Vector2:
	"""Get player world position"""
	return global_position

func set_position(pos: Vector2):
	"""Set player world position"""
	global_position = pos

func reset_player():
	"""Reset player to default state"""
	velocity = Vector2.ZERO
	can_move = true
	is_in_dialogue = false
	update_health_display()
	update_sanity_display()
