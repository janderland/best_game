extends Node2D

# Main - Central game controller that manages scenes, levels, and game flow

signal level_complete()

# Scene references
@onready var level_container = $LevelContainer if has_node("LevelContainer") else Node2D.new()
@onready var ui = $UI if has_node("UI") else null
@onready var player = $Player if has_node("Player") else null
@onready var level_generator = $LevelGenerator if has_node("LevelGenerator") else null

# Current level instances
var current_level = null
var current_entities = []

# Initialization flag
var game_started = false

func _ready():
	print("\n" + "=".repeat(60))
	print("ECHOES OF THE FORGOTTEN")
	print("A Psychological Horror-Adventure")
	print("=".repeat(60) + "\n")

	# Set up level container
	if not has_node("LevelContainer"):
		level_container = Node2D.new()
		level_container.name = "LevelContainer"
		add_child(level_container)

	# Set up level generator
	if not level_generator:
		level_generator = preload("res://scripts/LevelGenerator.gd").new()
		level_generator.name = "LevelGenerator"
		add_child(level_generator)

	# Connect signals
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.game_state_changed.connect(_on_game_state_changed)

	if level_generator:
		level_generator.level_generated.connect(_on_level_generated)

	# Start game
	start_game()

func start_game():
	"""Initialize and start the game"""
	print("Initializing game systems...")

	# Generate procedural art on startup as requested
	print("Generating procedural artwork...")
	generate_startup_art()

	print("\nStarting at level 1...")

	# Set initial game state
	GameManager.set_game_state(GameManager.GameState.PLAYING)

	# Generate first level
	generate_current_level()

	game_started = true

	# Show intro narrative
	show_level_intro()

func generate_startup_art():
	"""Generate procedural art assets on game startup"""
	print("  - Generating theme textures...")

	var themes = ["childhood_memory", "lost_love", "regret", "fear", "joy",
				  "betrayal", "loneliness", "rage", "grief", "hope"]

	for theme in themes:
		var _texture = ProceduralArt.generate_texture_for_theme(theme, Vector2(256, 256))
		print("    Created ", theme, " texture")

	print("  - Generating character sprites...")
	var character_types = ["devotee", "hollow_child", "broken_soldier",
						   "weeping_artist", "forgotten_mother", "mirror_twin"]

	for char_type in character_types:
		var _sprite = ProceduralArt.generate_character_sprite(char_type, 64)
		print("    Created ", char_type, " sprite")

	print("  - Generating enemy sprites...")
	var enemy_types = ["shadow_lurker", "memory_wraith", "forgotten_one",
					   "grief_incarnate", "hollow_echo"]

	for enemy_type in enemy_types:
		var _sprite = ProceduralArt.generate_enemy_sprite(enemy_type, 64)
		print("    Created ", enemy_type, " sprite")

	print("Procedural art generation complete!\n")

func generate_current_level():
	"""Generate the current level"""
	var level_num = GameManager.current_level

	print("\n--- Generating Level ", level_num, " ---")

	# Clear previous level
	clear_level()

	# Generate level layout
	if level_generator:
		level_generator.generate_level(level_num)
		print(level_generator.visualize_level_ascii())

	# Create level instance
	spawn_level_contents()

func clear_level():
	"""Clear current level contents"""
	# Remove all entities
	for entity in current_entities:
		if is_instance_valid(entity):
			entity.queue_free()

	current_entities.clear()

	# Clear level container
	for child in level_container.get_children():
		child.queue_free()

func spawn_level_contents():
	"""Spawn all level entities based on generated data"""
	if not level_generator:
		return

	var level_data = level_generator.get_level_data()

	# Spawn player at start position
	if player:
		player.global_position = level_data["spawn_point"]
		print("Player spawned at: ", level_data["spawn_point"])

	# Spawn entities from each room
	for room_data in level_data["rooms"]:
		spawn_room_entities(room_data)

func spawn_room_entities(room_data: Dictionary):
	"""Spawn entities in a room"""
	for entity_data in room_data["entities"]:
		match entity_data["type"]:
			"enemy":
				spawn_enemy(entity_data)
			"character":
				spawn_character(entity_data)
			"memory_fragment":
				spawn_memory_fragment(entity_data)
			"item":
				spawn_item(entity_data)

func spawn_enemy(entity_data: Dictionary):
	"""Spawn an enemy"""
	var enemy = preload("res://scripts/Enemy.gd").new()

	# Set up enemy
	enemy.enemy_type = entity_data.get("enemy_type", "shadow_lurker")
	enemy.position = entity_data["position"] * level_generator.TILE_SIZE

	# Add collision shape
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20
	collision.shape = shape
	enemy.add_child(collision)

	# Add sprite
	var sprite_node = Sprite2D.new()
	sprite_node.name = "Sprite"
	enemy.add_child(sprite_node)

	level_container.add_child(enemy)
	current_entities.append(enemy)

	enemy.enemy_died.connect(_on_enemy_died)

func spawn_character(entity_data: Dictionary):
	"""Spawn a character"""
	var character = preload("res://scripts/Character.gd").new()

	# Set up character
	character.character_type = entity_data.get("character_type", "generic")
	character.position = entity_data["position"] * level_generator.TILE_SIZE

	# Set character name based on type
	match character.character_type:
		"devotee":
			character.character_name = "The Devotee"
		"hollow_child":
			character.character_name = "The Hollow Child"
		"broken_soldier":
			character.character_name = "The Broken Soldier"
		"weeping_artist":
			character.character_name = "The Weeping Artist"
		"forgotten_mother":
			character.character_name = "The Forgotten Mother"
		"mirror_twin":
			character.character_name = "Your Mirror"
		_:
			character.character_name = "Echo"

	# Add collision shape
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 25
	collision.shape = shape
	character.add_child(collision)

	# Add sprite
	var sprite_node = Sprite2D.new()
	sprite_node.name = "Sprite"
	character.add_child(sprite_node)

	# Add label
	var label = Label.new()
	label.name = "Label"
	label.rect_position = Vector2(-50, -60)
	label.rect_size = Vector2(100, 20)
	label.align = Label.ALIGN_CENTER
	character.add_child(label)

	level_container.add_child(character)
	current_entities.append(character)

	character.dialogue_started.connect(_on_dialogue_started)
	character.dialogue_ended.connect(_on_dialogue_ended)

func spawn_memory_fragment(entity_data: Dictionary):
	"""Spawn a collectible memory fragment"""
	var fragment = Area2D.new()
	fragment.name = "MemoryFragment"
	fragment.position = entity_data["position"] * level_generator.TILE_SIZE
	fragment.add_to_group("interactable")

	# Collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 15
	collision.shape = shape
	fragment.add_child(collision)

	# Visual - glowing orb
	var sprite = Sprite2D.new()
	sprite.modulate = Color(0.8, 0.8, 1.0, 0.8)

	# Create simple texture
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for y in range(32):
		for x in range(32):
			var dx = x - 16
			var dy = y - 16
			var dist = sqrt(dx * dx + dy * dy)
			if dist < 12:
				var alpha = 1.0 - (dist / 12.0)
				img.set_pixel(x, y, Color(0.9, 0.9, 1.0, alpha))

	var tex = ImageTexture.new()
	tex.create_from_image(img)
	sprite.texture = tex
	fragment.add_child(sprite)

	# Connect interaction
	fragment.set_script(preload("res://scripts/MemoryFragment.gd"))

	level_container.add_child(fragment)
	current_entities.append(fragment)

func spawn_item(entity_data: Dictionary):
	"""Spawn a collectible item"""
	var item = Area2D.new()
	item.name = "Item_" + entity_data["item_type"]
	item.position = entity_data["position"] * level_generator.TILE_SIZE
	item.add_to_group("interactable")
	item.set_meta("item_type", entity_data["item_type"])

	# Collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 12
	collision.shape = shape
	item.add_child(collision)

	# Visual
	var sprite = Sprite2D.new()
	var color = Color(0.2, 1.0, 0.3) if entity_data["item_type"] == "health" else Color(0.3, 0.6, 1.0)
	sprite.modulate = color

	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	for y in range(24):
		for x in range(24):
			var dx = x - 12
			var dy = y - 12
			var dist = sqrt(dx * dx + dy * dy)
			if dist < 10:
				img.set_pixel(x, y, color)

	var tex = ImageTexture.new()
	tex.create_from_image(img)
	sprite.texture = tex
	item.add_child(sprite)

	# Connect interaction
	item.set_script(preload("res://scripts/Item.gd"))

	level_container.add_child(item)
	current_entities.append(item)

func show_level_intro():
	"""Show narrative introduction for current level"""
	var intro = NarrativeManager.get_level_intro(GameManager.current_level)

	print("\n" + "=".repeat(60))
	print(intro["title"].to_upper())
	print("-".repeat(60))
	print(intro["text"])
	print("=".repeat(60) + "\n")

	# In full game, this would show in UI with fade in/out

func advance_to_next_level():
	"""Progress to the next level"""
	print("\n!!! LEVEL COMPLETE !!!\n")

	emit_signal("level_complete")

	if GameManager.advance_level():
		# Save progress
		GameManager.save_game()

		# Generate next level
		await get_tree().create_timer(2.0).timeout
		generate_current_level()
		show_level_intro()
	else:
		# Game complete!
		show_ending()

func show_ending():
	"""Show game ending"""
	var devotee_stage = GameManager.get_devotee_stage()
	var sanity = GameManager.player_sanity

	var ending_text = NarrativeManager.get_completion_text(devotee_stage, sanity)

	print("\n" + "=".repeat(60))
	print("ENDING")
	print("=".repeat(60))
	print(ending_text)
	print("=".repeat(60))

	print("\n=== GAME STATISTICS ===")
	var stats = GameManager.get_game_statistics()
	for key in stats:
		print(key, ": ", stats[key])

	print("\nThank you for playing ECHOES OF THE FORGOTTEN")

func _on_level_changed(level_num):
	"""Handle level change"""
	print("Level changed to: ", level_num)

func _on_game_state_changed(new_state):
	"""Handle game state change"""
	match new_state:
		GameManager.GameState.GAME_OVER:
			print("\n=== GAME OVER ===")
			print(NarrativeManager.get_death_message())
			print("\nRespawning...")
		GameManager.GameState.VICTORY:
			print("\n=== VICTORY ===")

func _on_level_generated():
	"""Handle level generation complete"""
	print("Level generation complete")

func _on_dialogue_started(_character):
	"""Handle dialogue start"""
	pass

func _on_dialogue_ended(_character):
	"""Handle dialogue end"""
	pass

func _on_enemy_died(enemy_type):
	"""Handle enemy death"""
	print("Enemy defeated: ", enemy_type)

	# Small sanity restoration for overcoming fear
	GameManager.modify_sanity(2.0)

func _process(_delta):
	# Check for level exit trigger
	if player and level_generator:
		var exit_pos = level_generator.get_exit_position()
		if exit_pos != Vector2.ZERO:
			var dist = player.global_position.distance_to(exit_pos)
			if dist < 50:
				# Player reached exit!
				advance_to_next_level()
