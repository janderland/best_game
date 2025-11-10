extends Node

# Sanity System - Manages visual and gameplay effects based on player's mental state

signal sanity_changed(sanity_percent)
signal sanity_threshold_crossed(threshold_name)

var current_sanity := 1.0 setget set_sanity  # 0.0 to 1.0
var sanity_drain_rate := 0.5  # Per second in dangerous areas
var sanity_effects_active := false

# Visual effect parameters
var chromatic_aberration_strength := 0.0
var vignette_intensity := 0.0
var distortion_amount := 0.0
var shadow_spawn_chance := 0.0
var audio_distortion := 0.0

# Gameplay effects
var hallucination_chance := 0.0
var false_door_chance := 0.0
var time_distortion := 1.0

# Thresholds for different effects
const THRESHOLD_ANXIOUS = 0.8
const THRESHOLD_DISTURBED = 0.6
const THRESHOLD_UNSTABLE = 0.4
const THRESHOLD_BREAKING = 0.2
const THRESHOLD_SHATTERED = 0.1

var last_threshold := ""

func _ready():
	set_sanity(1.0)
	print("Sanity System initialized")

func _process(delta):
	if sanity_effects_active:
		update_visual_effects()
		update_gameplay_effects()

func set_sanity(value: float):
	var old_sanity = current_sanity
	current_sanity = clamp(value, 0.0, 1.0)

	emit_signal("sanity_changed", current_sanity)

	# Check threshold changes
	check_thresholds()

	update_visual_effects()
	update_gameplay_effects()

func check_thresholds():
	"""Check if player has crossed sanity thresholds"""
	var new_threshold = get_current_threshold()

	if new_threshold != last_threshold:
		last_threshold = new_threshold
		emit_signal("sanity_threshold_crossed", new_threshold)
		print("Sanity threshold: ", new_threshold)

		# Display message to player
		show_threshold_message(new_threshold)

func get_current_threshold() -> String:
	"""Get current sanity threshold name"""
	if current_sanity >= THRESHOLD_ANXIOUS:
		return "stable"
	elif current_sanity >= THRESHOLD_DISTURBED:
		return "anxious"
	elif current_sanity >= THRESHOLD_UNSTABLE:
		return "disturbed"
	elif current_sanity >= THRESHOLD_BREAKING:
		return "unstable"
	elif current_sanity >= THRESHOLD_SHATTERED:
		return "breaking"
	else:
		return "shattered"

func show_threshold_message(threshold: String):
	"""Show message when crossing sanity threshold"""
	var messages = {
		"anxious": "Your hands tremble slightly. The shadows seem darker.",
		"disturbed": "You hear whispers at the edge of perception. Are they real?",
		"unstable": "The walls breathe. Time feels wrong. You can't trust your senses.",
		"breaking": "Reality fractures. You see things that aren't there. Or are they?",
		"shattered": "You are coming apart. The boundaries between you and the mansion blur."
	}

	if messages.has(threshold):
		print("SANITY: ", messages[threshold])

func update_visual_effects():
	"""Update visual distortion based on sanity"""
	var insanity = 1.0 - current_sanity

	# Chromatic aberration (RGB split)
	chromatic_aberration_strength = insanity * 0.05

	# Vignette (darkness at edges)
	vignette_intensity = 0.3 + (insanity * 0.5)

	# Screen distortion
	distortion_amount = insanity * 0.3

	# Shadow entity spawn rate
	shadow_spawn_chance = insanity * 0.05

	# Audio distortion
	audio_distortion = insanity * 0.7

func update_gameplay_effects():
	"""Update gameplay modifications based on sanity"""
	var insanity = 1.0 - current_sanity

	# Hallucination chance
	hallucination_chance = insanity * 0.3

	# False/disappearing doors
	false_door_chance = insanity * 0.2

	# Time flows differently at low sanity
	if current_sanity < THRESHOLD_UNSTABLE:
		time_distortion = 0.7 + randf() * 0.6  # 0.7 to 1.3
	else:
		time_distortion = 1.0

func drain_sanity(delta: float, multiplier: float = 1.0):
	"""Gradually drain sanity (in scary/stressful areas)"""
	var drain = sanity_drain_rate * delta * multiplier
	set_sanity(current_sanity - drain / 100.0)

func restore_sanity(amount: float):
	"""Restore sanity (from items, safe areas, etc)"""
	set_sanity(current_sanity + amount)

func get_visual_effect_params() -> Dictionary:
	"""Get current visual effect parameters for shaders"""
	return {
		"chromatic_aberration": chromatic_aberration_strength,
		"vignette": vignette_intensity,
		"distortion": distortion_amount,
		"time": OS.get_ticks_msec() / 1000.0,
		"sanity": current_sanity
	}

func should_spawn_hallucination() -> bool:
	"""Check if a hallucination should spawn"""
	return randf() < hallucination_chance * 0.01

func should_spawn_shadow_entity() -> bool:
	"""Check if a shadow entity should appear"""
	return randf() < shadow_spawn_chance

func is_door_real() -> bool:
	"""Check if a door is real or a hallucination"""
	return randf() > false_door_chance

func get_distorted_text(text: String) -> String:
	"""Distort text based on sanity"""
	if current_sanity > THRESHOLD_UNSTABLE:
		return text

	var distorted = text
	var chars = "!@#$%^&*~`"

	# Replace random characters
	for i in range(text.length()):
		if randf() < (1.0 - current_sanity) * 0.3:
			var rand_char = chars[randi() % chars.length()]
			distorted[i] = rand_char

	return distorted

func get_hallucination_type() -> String:
	"""Get type of hallucination to show"""
	var types = [
		"shadow_figure",
		"whispering_voice",
		"false_door",
		"phantom_devotee",
		"crawling_walls",
		"inverted_gravity",
		"time_loop",
		"mirror_self"
	]

	return types[randi() % types.size()]

func apply_sanity_damage(damage: float, source: String = ""):
	"""Apply damage to sanity from specific source"""
	print("Sanity damage: ", damage, " from ", source)
	set_sanity(current_sanity - damage)

	# Specific effects based on source
	match source:
		"enemy_attack":
			# Brief visual distortion
			pass
		"devotee_rejection":
			# Heartbeat sound, screen shake
			pass
		"disturbing_memory":
			# Flash of imagery
			pass
		"monster_sight":
			# Crawling vignette effect
			pass

func get_enemy_perception() -> float:
	"""Get how well player can perceive enemies (lower sanity = harder to see real threats)"""
	return 0.3 + (current_sanity * 0.7)

func get_movement_stability() -> float:
	"""Get movement stability (lower sanity = more erratic movement)"""
	if current_sanity < THRESHOLD_BREAKING:
		return 0.7 + randf() * 0.4  # Unstable movement
	return 1.0

func get_interaction_reliability() -> float:
	"""Get reliability of interactions (lower sanity = more failures)"""
	return current_sanity

func create_sanity_event():
	"""Trigger a random sanity event"""
	var event_type = get_hallucination_type()

	match event_type:
		"shadow_figure":
			print("A figure darts at the edge of your vision...")
		"whispering_voice":
			print("You hear your name whispered from nowhere...")
		"false_door":
			print("A door appears where there wasn't one before...")
		"phantom_devotee":
			print("The Devotee appears, reaches for you, then vanishes...")
		"crawling_walls":
			print("The walls pulse and writhe like living flesh...")
		"inverted_gravity":
			print("For a moment, you're not sure which way is up...")
		"time_loop":
			print("Haven't you been here before? Just now?")
		"mirror_self":
			print("You see yourself watching yourself...")

func get_sanity_recovery_rate() -> float:
	"""Get rate of sanity recovery in safe areas"""
	return 0.1  # 10% per second in safe zones

func start_effects():
	"""Enable sanity effects"""
	sanity_effects_active = true

func stop_effects():
	"""Disable sanity effects"""
	sanity_effects_active = false
