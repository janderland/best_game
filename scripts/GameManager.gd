extends Node

# Game Manager - Singleton that manages game state, progression, and save data

signal level_changed(level_number)
signal game_state_changed(new_state)

enum GameState {
	MENU,
	PLAYING,
	DIALOGUE,
	PAUSED,
	GAME_OVER,
	VICTORY
}

var current_state = GameState.MENU setget set_game_state
var current_level := 1
var max_level := 64
var player_name := "Wanderer"
var game_seed := 0

# Player stats
var player_health := 100.0
var player_max_health := 100.0
var player_sanity := 100.0
var player_max_sanity := 100.0

# Progression tracking
var levels_completed := []
var characters_met := {}
var memory_fragments_collected := 0
var total_memory_fragments := 0

# Relationship tracking
var devotee_affection := 0
var devotee_obsession := 0
var devotee_encounters := 0

# Gameplay stats
var deaths := 0
var play_time := 0.0
var total_distance_traveled := 0.0

func _ready():
	randomize()
	game_seed = randi()
	print("=== ECHOES OF THE FORGOTTEN ===")
	print("Game Seed: ", game_seed)
	print("Initializing game systems...")
	reset_game()

func _process(delta):
	if current_state == GameState.PLAYING:
		play_time += delta

func reset_game():
	"""Reset game to initial state for new playthrough"""
	current_level = 1
	player_health = player_max_health
	player_sanity = player_max_sanity
	levels_completed.clear()
	characters_met.clear()
	memory_fragments_collected = 0
	devotee_affection = 0
	devotee_obsession = 0
	devotee_encounters = 0
	deaths = 0
	play_time = 0.0
	total_distance_traveled = 0.0

	# Generate new seed for this run
	game_seed = randi()
	seed(game_seed)

	print("Game reset. New seed: ", game_seed)

func set_game_state(new_state):
	if current_state != new_state:
		var old_state = current_state
		current_state = new_state
		emit_signal("game_state_changed", new_state)
		print("Game state changed: ", GameState.keys()[old_state], " -> ", GameState.keys()[new_state])

func advance_level():
	"""Progress to next level"""
	if current_level < max_level:
		levels_completed.append(current_level)
		current_level += 1
		emit_signal("level_changed", current_level)
		print("Advanced to level ", current_level, "/", max_level)
		return true
	else:
		# Game completed!
		set_game_state(GameState.VICTORY)
		print("All levels completed! Victory!")
		return false

func damage_player(amount: float) -> bool:
	"""Deal damage to player. Returns true if player died."""
	player_health = max(0, player_health - amount)

	if player_health <= 0:
		player_death()
		return true

	return false

func heal_player(amount: float):
	"""Heal player"""
	player_health = min(player_max_health, player_health + amount)

func modify_sanity(amount: float):
	"""Change player sanity. Negative values decrease sanity."""
	player_sanity = clamp(player_sanity + amount, 0, player_max_sanity)

	# Update sanity system
	if SanitySystem:
		SanitySystem.set_sanity(player_sanity / player_max_sanity)

	# Check for sanity death
	if player_sanity <= 0:
		player_death()

func player_death():
	"""Handle player death"""
	deaths += 1
	print("Player died. Deaths: ", deaths)
	set_game_state(GameState.GAME_OVER)

	# Respawn at current level after a delay
	yield(get_tree().create_timer(2.0), "timeout")
	respawn_player()

func respawn_player():
	"""Respawn player at current level"""
	player_health = player_max_health
	player_sanity = player_max_sanity * 0.5  # Respawn with reduced sanity
	set_game_state(GameState.PLAYING)
	print("Player respawned")

func collect_memory_fragment():
	"""Collect a memory fragment"""
	memory_fragments_collected += 1
	total_memory_fragments += 1
	print("Memory fragment collected: ", memory_fragments_collected)

	# Restore some sanity
	modify_sanity(5.0)

func meet_character(character_id: String):
	"""Record meeting a character"""
	if not characters_met.has(character_id):
		characters_met[character_id] = {
			"first_met_level": current_level,
			"encounters": 0,
			"affection": 0
		}

	characters_met[character_id]["encounters"] += 1

func modify_character_affection(character_id: String, amount: float):
	"""Modify relationship with a character"""
	if characters_met.has(character_id):
		characters_met[character_id]["affection"] += amount

func interact_with_devotee(interaction_type: String):
	"""Special handling for The Devotee interactions"""
	devotee_encounters += 1

	match interaction_type:
		"kind":
			devotee_affection += 10
			devotee_obsession += 5
		"neutral":
			devotee_affection += 3
			devotee_obsession += 2
		"cruel":
			devotee_affection -= 5
			devotee_obsession += 15  # Cruelty increases obsession!
		"romantic":
			devotee_affection += 20
			devotee_obsession += 20

	print("Devotee relationship - Affection: ", devotee_affection, " Obsession: ", devotee_obsession)

func get_devotee_stage() -> String:
	"""Get current stage of Devotee relationship"""
	var total = devotee_affection + devotee_obsession

	if total < 20:
		return "stranger"
	elif total < 50:
		return "curious"
	elif total < 100:
		return "infatuated"
	elif total < 200:
		return "devoted"
	elif total < 400:
		return "obsessed"
	else:
		return "consumed"

func get_level_theme() -> String:
	"""Get theme for current level"""
	var themes = [
		"childhood_memory",
		"lost_love",
		"regret",
		"fear",
		"joy",
		"betrayal",
		"loneliness",
		"rage",
		"grief",
		"hope"
	]

	# Cycle through themes with some randomness
	var index = (current_level + int(game_seed)) % themes.size()
	return themes[index]

func get_level_intensity() -> float:
	"""Get intensity factor based on level (0.0 to 1.0)"""
	return float(current_level) / float(max_level)

func save_game():
	"""Save game state to file"""
	var save_data = {
		"current_level": current_level,
		"player_health": player_health,
		"player_sanity": player_sanity,
		"levels_completed": levels_completed,
		"characters_met": characters_met,
		"memory_fragments": memory_fragments_collected,
		"devotee_affection": devotee_affection,
		"devotee_obsession": devotee_obsession,
		"devotee_encounters": devotee_encounters,
		"deaths": deaths,
		"play_time": play_time,
		"game_seed": game_seed
	}

	var save_file = File.new()
	save_file.open("user://echoes_save.dat", File.WRITE)
	save_file.store_var(save_data)
	save_file.close()
	print("Game saved")

func load_game() -> bool:
	"""Load game state from file"""
	var save_file = File.new()
	if not save_file.file_exists("user://echoes_save.dat"):
		print("No save file found")
		return false

	save_file.open("user://echoes_save.dat", File.READ)
	var save_data = save_file.get_var()
	save_file.close()

	current_level = save_data.get("current_level", 1)
	player_health = save_data.get("player_health", 100.0)
	player_sanity = save_data.get("player_sanity", 100.0)
	levels_completed = save_data.get("levels_completed", [])
	characters_met = save_data.get("characters_met", {})
	memory_fragments_collected = save_data.get("memory_fragments", 0)
	devotee_affection = save_data.get("devotee_affection", 0)
	devotee_obsession = save_data.get("devotee_obsession", 0)
	devotee_encounters = save_data.get("devotee_encounters", 0)
	deaths = save_data.get("deaths", 0)
	play_time = save_data.get("play_time", 0.0)
	game_seed = save_data.get("game_seed", 0)

	print("Game loaded - Level ", current_level)
	return true

func get_game_statistics() -> Dictionary:
	"""Get current game statistics"""
	return {
		"level": current_level,
		"max_level": max_level,
		"health": player_health,
		"max_health": player_max_health,
		"sanity": player_sanity,
		"max_sanity": player_max_sanity,
		"memories": memory_fragments_collected,
		"devotee_stage": get_devotee_stage(),
		"deaths": deaths,
		"play_time": play_time,
		"characters_met": characters_met.size()
	}
