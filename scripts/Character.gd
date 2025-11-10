extends Area2D

# Character - Represents NPCs that the player can interact with

signal dialogue_started(character)
signal dialogue_ended(character)

export var character_type = "generic"
export var character_name = "Echo"

var is_interactable = true
var dialogue_active = false
var current_dialogue_index = 0
var current_dialogue_options = []

# Visual
onready var sprite = $Sprite if has_node("Sprite") else null
onready var label = $Label if has_node("Label") else null

func _ready():
	add_to_group("interactable")

	# Generate character appearance
	generate_appearance()

	# Set up label
	if label:
		label.text = character_name
		label.visible = false

func _process(_delta):
	# Show name when player is nearby
	if label and has_node("../Player"):
		var player = get_node("../Player")
		var dist = global_position.distance_to(player.global_position)
		label.visible = dist < 150

func generate_appearance():
	"""Generate visual appearance based on character type"""
	if sprite:
		var tex = ImageTexture.new()
		var img = ProceduralArt.generate_character_sprite(character_type, 64)
		tex.create_from_image(img)
		sprite.texture = tex

func interact(player):
	"""Handle interaction with player"""
	if not is_interactable or dialogue_active:
		return

	print("Character interaction: ", character_name)

	# Record meeting
	GameManager.meet_character(character_type)

	# Start dialogue
	start_dialogue(player)

func start_dialogue(player):
	"""Begin dialogue with player"""
	dialogue_active = true
	player.start_dialogue()

	emit_signal("dialogue_started", self)

	# Get dialogue based on character type
	if character_type == "devotee":
		show_devotee_dialogue()
	else:
		show_character_dialogue()

func show_devotee_dialogue():
	"""Show dialogue for The Devotee"""
	var stage = GameManager.get_devotee_stage()
	var context = get_devotee_context()

	var dialogues = NarrativeManager.get_devotee_dialogue(stage, context)

	if dialogues.empty():
		end_dialogue()
		return

	current_dialogue_options = dialogues
	current_dialogue_index = 0

	show_dialogue_text(dialogues[0])

func show_character_dialogue():
	"""Show dialogue for other characters"""
	var dialogue = NarrativeManager.get_random_character_dialogue(character_type)

	show_dialogue_text(dialogue)

	# Auto-advance after delay
	yield(get_tree().create_timer(3.0), "timeout")
	end_dialogue()

func show_dialogue_text(dialogue: Dictionary):
	"""Display dialogue text"""
	var text = dialogue.get("text", "...")
	var emotion = dialogue.get("emotion", "")

	print("\n=== ", character_name, " ===")
	print(text)
	if emotion:
		print("[", emotion, "]")
	print("===\n")

	# In full implementation, this would show in UI
	# For now, we show in console

	# Handle The Devotee's special dialogue options
	if character_type == "devotee":
		yield(get_tree().create_timer(2.0), "timeout")
		show_devotee_response_options()

func show_devotee_response_options():
	"""Show response options for Devotee dialogue"""
	print("Response options:")
	print("1. [Kind] Respond with kindness")
	print("2. [Neutral] Respond neutrally")
	print("3. [Romantic] Respond romantically")
	print("4. [Cruel] Respond with cruelty")
	print("5. [Leave] Walk away")

	# For automation, randomly choose response
	yield(get_tree().create_timer(1.0), "timeout")
	var choice = randi() % 5

	match choice:
		0:
			handle_devotee_response("kind")
		1:
			handle_devotee_response("neutral")
		2:
			handle_devotee_response("romantic")
		3:
			handle_devotee_response("cruel")
		4:
			end_dialogue()

func handle_devotee_response(response_type: String):
	"""Handle player's response to Devotee"""
	print("You respond: ", response_type)

	GameManager.interact_with_devotee(response_type)

	match response_type:
		"kind":
			print("The Devotee's eyes light up with hope...")
			GameManager.modify_sanity(5)  # Kindness restores sanity
		"romantic":
			print("The Devotee trembles, overwhelmed with emotion...")
			GameManager.modify_sanity(-5)  # Deep emotional connection strains sanity
		"cruel":
			print("The Devotee recoils, hurt but somehow more fixated...")
			GameManager.modify_sanity(-10)  # Cruelty damages your own sanity
		"neutral":
			print("The Devotee accepts your measured response...")

	yield(get_tree().create_timer(2.0), "timeout")
	end_dialogue()

func get_devotee_context() -> String:
	"""Determine dialogue context for Devotee"""
	var encounters = GameManager.devotee_encounters

	if encounters == 0:
		return "encounter"
	elif encounters < 3:
		return "help"
	elif encounters < 6:
		return "gift"
	elif encounters < 10:
		return "touch"
	elif GameManager.devotee_affection > GameManager.devotee_obsession:
		return "reciprocate"
	elif GameManager.devotee_obsession > 100:
		return "escape_attempt"
	else:
		return "encounter"

func end_dialogue():
	"""End dialogue"""
	dialogue_active = false
	current_dialogue_index = 0
	current_dialogue_options.clear()

	emit_signal("dialogue_ended", self)

	# Tell player dialogue ended
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		player[0].end_dialogue()

func special_event():
	"""Trigger special character event"""
	match character_type:
		"devotee":
			devotee_special_event()
		"hollow_child":
			hollow_child_event()
		"broken_soldier":
			broken_soldier_event()
		"weeping_artist":
			weeping_artist_event()
		"forgotten_mother":
			forgotten_mother_event()
		"mirror_twin":
			mirror_twin_event()

func devotee_special_event():
	"""Special event for The Devotee"""
	var stage = GameManager.get_devotee_stage()

	match stage:
		"obsessed":
			print("\n!!! SPECIAL EVENT !!!")
			print("The Devotee appears from nowhere, blocking your path.")
			print("'We need to talk,' they say, voice cracking with emotion.")
		"consumed":
			print("\n!!! SPECIAL EVENT !!!")
			print("The mansion itself seems to pulse with The Devotee's presence.")
			print("They are everywhere. In every shadow. Every reflection.")
			print("'Why do you keep running from what we both want?'")

func hollow_child_event():
	"""Hollow Child wants to play a deadly game"""
	print("\n!!! SPECIAL EVENT !!!")
	print("The Hollow Child giggles. 'Let's play hide and seek!'")
	print("Shadows begin moving on their own...")

	# Spawn shadow entities
	SanitySystem.apply_sanity_damage(0.1, "hollow_child_game")

func broken_soldier_event():
	"""Broken Soldier has an episode"""
	print("\n!!! SPECIAL EVENT !!!")
	print("The Soldier screams: 'INCOMING! TAKE COVER!'")
	print("He attacks, not seeing you, only the enemy...")

	# Trigger combat

func weeping_artist_event():
	"""Weeping Artist creates disturbing art"""
	print("\n!!! SPECIAL EVENT !!!")
	print("The Artist unveils their latest work. It depicts YOUR death.")
	print("Every detail is perfect. Too perfect.")

	SanitySystem.apply_sanity_damage(0.15, "disturbing_art")

func forgotten_mother_event():
	"""Forgotten Mother mistakes you for her child"""
	print("\n!!! SPECIAL EVENT !!!")
	print("The Mother embraces you. 'My child! I finally found you!'")
	print("Her grip is uncomfortably tight...")

	# Choice: comfort her or escape

func mirror_twin_event():
	"""Mirror Twin claims your identity"""
	print("\n!!! SPECIAL EVENT !!!")
	print("Your twin speaks: 'I've been practicing. I can be you perfectly now.'")
	print("They mimic your movements exactly. Unsettlingly so.")

	SanitySystem.apply_sanity_damage(0.1, "identity_crisis")

func wander():
	"""Simple wandering behavior"""
	# Could implement random movement
	pass

func flee(from_position: Vector2):
	"""Flee from a position"""
	var direction = (global_position - from_position).normalized()
	global_position += direction * 50

func approach(target_position: Vector2):
	"""Move toward a position"""
	var direction = (target_position - global_position).normalized()
	global_position += direction * 30
