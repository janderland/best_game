extends Node2D

# Procedural Level Generator - Creates unique layouts for each level

signal level_generated()

const TILE_SIZE = 64
const MIN_ROOMS = 5
const MAX_ROOMS = 15
const ROOM_MIN_SIZE = 4
const ROOM_MAX_SIZE = 12
const CORRIDOR_WIDTH = 2

var rng = RandomNumberGenerator.new()
var current_level = 1
var level_data = {}
var rooms = []
var corridors = []
var spawn_point = Vector2.ZERO
var exit_point = Vector2.ZERO

# Tilemap reference (would be assigned from scene)
var tilemap: TileMap = null

class Room:
	var position: Vector2
	var size: Vector2
	var center: Vector2
	var connections = []
	var room_type: String = "normal"
	var entities = []
	var theme: String = ""

	func _init(pos: Vector2, sz: Vector2):
		position = pos
		size = sz
		center = pos + sz / 2.0

	func intersects(other: Room) -> bool:
		return not (position.x + size.x < other.position.x or
					position.x > other.position.x + other.size.x or
					position.y + size.y < other.position.y or
					position.y > other.position.y + other.size.y)

	func get_random_floor_position(rng: RandomNumberGenerator) -> Vector2:
		return Vector2(
			position.x + rng.randi_range(1, int(size.x) - 2),
			position.y + rng.randi_range(1, int(size.y) - 2)
		)

func _ready():
	rng.randomize()

func generate_level(level_number: int, seed_value: int = -1):
	"""Generate a complete level"""
	current_level = level_number

	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.seed = GameManager.game_seed + level_number

	print("Generating level ", level_number, " with seed ", rng.seed)

	clear_level()
	generate_rooms()
	connect_rooms()
	place_corridors()
	place_entities()
	place_special_rooms()
	generate_level_data()

	emit_signal("level_generated")
	print("Level ", level_number, " generated: ", rooms.size(), " rooms")

func clear_level():
	"""Clear existing level data"""
	rooms.clear()
	corridors.clear()
	level_data.clear()
	spawn_point = Vector2.ZERO
	exit_point = Vector2.ZERO

	if tilemap:
		tilemap.clear()

func generate_rooms():
	"""Generate random non-overlapping rooms"""
	var num_rooms = MIN_ROOMS + int((MAX_ROOMS - MIN_ROOMS) * GameManager.get_level_intensity())
	num_rooms = rng.randi_range(MIN_ROOMS, MAX_ROOMS)

	var max_attempts = 500
	var attempts = 0

	while rooms.size() < num_rooms and attempts < max_attempts:
		attempts += 1

		var room_w = rng.randi_range(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
		var room_h = rng.randi_range(ROOM_MIN_SIZE, ROOM_MAX_SIZE)

		var room_x = rng.randi_range(-20, 20)
		var room_y = rng.randi_range(-20, 20)

		var new_room = Room.new(
			Vector2(room_x, room_y),
			Vector2(room_w, room_h)
		)

		# Check for overlaps
		var overlaps = false
		for existing_room in rooms:
			if new_room.intersects(existing_room):
				overlaps = true
				break

		if not overlaps:
			rooms.append(new_room)

	# Set room themes based on level theme
	var level_theme = GameManager.get_level_theme()
	for room in rooms:
		room.theme = level_theme

func connect_rooms():
	"""Create connections between rooms"""
	if rooms.size() < 2:
		return

	# Connect each room to its nearest unconnected neighbor
	for i in range(rooms.size()):
		if i == 0:
			continue

		var room = rooms[i]
		var prev_room = rooms[i - 1]

		room.connections.append(prev_room)
		prev_room.connections.append(room)

		# Store corridor data
		corridors.append({
			"from": prev_room.center,
			"to": room.center
		})

	# Add some extra connections for complexity
	var extra_connections = rng.randi_range(1, max(1, rooms.size() / 3))
	for _i in range(extra_connections):
		var room1 = rooms[rng.randi_range(0, rooms.size() - 1)]
		var room2 = rooms[rng.randi_range(0, rooms.size() - 1)]

		if room1 != room2 and not room2 in room1.connections:
			room1.connections.append(room2)
			room2.connections.append(room1)

			corridors.append({
				"from": room1.center,
				"to": room2.center
			})

func place_corridors():
	"""Create corridor tiles between rooms"""
	# This would actually place tiles if we had a tilemap
	# For now, just stored as data
	pass

func place_entities():
	"""Place enemies, items, and characters in rooms"""
	var intensity = GameManager.get_level_intensity()

	for room in rooms:
		# Chance to spawn enemy
		var enemy_chance = 0.3 + (intensity * 0.5)
		if rng.randf() < enemy_chance:
			var num_enemies = rng.randi_range(1, max(1, int(3 * intensity)))
			for _i in range(num_enemies):
				room.entities.append({
					"type": "enemy",
					"position": room.get_random_floor_position(rng),
					"enemy_type": get_random_enemy_type()
				})

		# Chance to spawn character
		var char_chance = 0.15 + (intensity * 0.2)
		if rng.randf() < char_chance:
			room.entities.append({
				"type": "character",
				"position": room.get_random_floor_position(rng),
				"character_type": get_random_character_type()
			})

		# Chance to spawn memory fragment
		var memory_chance = 0.4
		if rng.randf() < memory_chance:
			room.entities.append({
				"type": "memory_fragment",
				"position": room.get_random_floor_position(rng)
			})

		# Chance to spawn health/sanity restore
		var item_chance = 0.25
		if rng.randf() < item_chance:
			var item_type = "health" if rng.randf() < 0.5 else "sanity"
			room.entities.append({
				"type": "item",
				"item_type": item_type,
				"position": room.get_random_floor_position(rng)
			})

func place_special_rooms():
	"""Designate special room types"""
	if rooms.size() == 0:
		return

	# First room is spawn
	rooms[0].room_type = "spawn"
	spawn_point = rooms[0].center * TILE_SIZE

	# Last room is exit
	rooms[rooms.size() - 1].room_type = "exit"
	exit_point = rooms[rooms.size() - 1].center * TILE_SIZE

	# Devotee always appears at a specific point in level
	var devotee_chance = get_devotee_spawn_chance()
	if rng.randf() < devotee_chance and rooms.size() > 2:
		var devotee_room_idx = rng.randi_range(1, rooms.size() - 2)
		rooms[devotee_room_idx].entities.append({
			"type": "character",
			"position": rooms[devotee_room_idx].center,
			"character_type": "devotee"
		})

	# Safe room (sanity restoration)
	if rooms.size() > 3 and rng.randf() < 0.4:
		var safe_room_idx = rng.randi_range(1, rooms.size() - 2)
		if rooms[safe_room_idx].room_type == "normal":
			rooms[safe_room_idx].room_type = "safe"

	# Boss room (intense encounter)
	if current_level % 8 == 0 and rooms.size() > 2:  # Boss every 8 levels
		var boss_room_idx = rooms.size() - 2
		rooms[boss_room_idx].room_type = "boss"
		rooms[boss_room_idx].entities.clear()
		rooms[boss_room_idx].entities.append({
			"type": "boss",
			"position": rooms[boss_room_idx].center,
			"boss_type": get_boss_type()
		})

func get_devotee_spawn_chance() -> float:
	"""Calculate chance of Devotee appearing based on progression"""
	var base_chance = 0.3
	var stage = GameManager.get_devotee_stage()

	match stage:
		"stranger":
			return base_chance * 0.5
		"curious":
			return base_chance
		"infatuated":
			return base_chance * 1.5
		"devoted":
			return base_chance * 2.0
		"obsessed":
			return base_chance * 3.0
		"consumed":
			return 1.0  # Always appears

	return base_chance

func get_random_enemy_type() -> String:
	"""Get random enemy type based on level"""
	var types = [
		"shadow_lurker",
		"memory_wraith",
		"forgotten_one",
		"grief_incarnate",
		"hollow_echo"
	]

	return types[rng.randi_range(0, types.size() - 1)]

func get_random_character_type() -> String:
	"""Get random character type"""
	var types = [
		"hollow_child",
		"broken_soldier",
		"weeping_artist",
		"forgotten_mother",
		"mirror_twin"
	]

	return types[rng.randi_range(0, types.size() - 1)]

func get_boss_type() -> String:
	"""Get boss type based on level"""
	var bosses = [
		"manifestation_of_regret",
		"embodiment_of_loss",
		"avatar_of_obsession",
		"personification_of_madness"
	]

	var idx = (current_level / 8 - 1) % bosses.size()
	return bosses[idx]

func generate_level_data():
	"""Compile all level data into a dictionary"""
	level_data = {
		"level_number": current_level,
		"seed": rng.seed,
		"theme": GameManager.get_level_theme(),
		"rooms": [],
		"corridors": corridors,
		"spawn_point": spawn_point,
		"exit_point": exit_point
	}

	for room in rooms:
		level_data["rooms"].append({
			"position": room.position,
			"size": room.size,
			"center": room.center,
			"type": room.room_type,
			"theme": room.theme,
			"entities": room.entities
		})

func get_level_data() -> Dictionary:
	"""Get generated level data"""
	return level_data

func get_room_at_position(world_pos: Vector2) -> Dictionary:
	"""Get room data at world position"""
	var tile_pos = world_pos / TILE_SIZE

	for room in rooms:
		if (tile_pos.x >= room.position.x and tile_pos.x < room.position.x + room.size.x and
			tile_pos.y >= room.position.y and tile_pos.y < room.position.y + room.size.y):

			return {
				"position": room.position,
				"size": room.size,
				"center": room.center,
				"type": room.room_type,
				"theme": room.theme
			}

	return {}

func is_position_walkable(world_pos: Vector2) -> bool:
	"""Check if a world position is walkable"""
	var tile_pos = world_pos / TILE_SIZE

	# Check if in any room
	for room in rooms:
		if (tile_pos.x >= room.position.x and tile_pos.x < room.position.x + room.size.x and
			tile_pos.y >= room.position.y and tile_pos.y < room.position.y + room.size.y):
			return true

	# Check if in any corridor (simplified - just check if near corridor path)
	for corridor in corridors:
		var dist_to_corridor = point_distance_to_line_segment(tile_pos, corridor["from"], corridor["to"])
		if dist_to_corridor < CORRIDOR_WIDTH:
			return true

	return false

func point_distance_to_line_segment(point: Vector2, line_start: Vector2, line_end: Vector2) -> float:
	"""Calculate distance from point to line segment"""
	var line_vec = line_end - line_start
	var point_vec = point - line_start
	var line_len = line_vec.length()

	if line_len == 0:
		return point_vec.length()

	var t = max(0, min(1, point_vec.dot(line_vec) / (line_len * line_len)))
	var projection = line_start + t * line_vec
	return point.distance_to(projection)

func get_spawn_position() -> Vector2:
	"""Get spawn position in world coordinates"""
	return spawn_point

func get_exit_position() -> Vector2:
	"""Get exit position in world coordinates"""
	return exit_point

func get_rooms() -> Array:
	"""Get array of all rooms"""
	return rooms

func visualize_level_ascii() -> String:
	"""Generate ASCII representation of level for debugging"""
	if rooms.size() == 0:
		return "No rooms generated"

	# Find bounds
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF

	for room in rooms:
		min_x = min(min_x, room.position.x)
		min_y = min(min_y, room.position.y)
		max_x = max(max_x, room.position.x + room.size.x)
		max_y = max(max_y, room.position.y + room.size.y)

	var width = int(max_x - min_x) + 1
	var height = int(max_y - min_y) + 1

	# Create grid
	var grid = []
	for _y in range(height):
		var row = []
		for _x in range(width):
			row.append(" ")
		grid.append(row)

	# Fill rooms
	for i in range(rooms.size()):
		var room = rooms[i]
		for y in range(int(room.size.y)):
			for x in range(int(room.size.x)):
				var gx = int(room.position.x - min_x + x)
				var gy = int(room.position.y - min_y + y)
				if gx >= 0 and gx < width and gy >= 0 and gy < height:
					if room.room_type == "spawn":
						grid[gy][gx] = "S"
					elif room.room_type == "exit":
						grid[gy][gx] = "E"
					elif room.room_type == "boss":
						grid[gy][gx] = "B"
					else:
						grid[gy][gx] = "."

	# Build string
	var result = "\n=== LEVEL " + str(current_level) + " LAYOUT ===\n"
	for row in grid:
		result += "".join(row) + "\n"
	result += "S=Spawn, E=Exit, B=Boss, .=Room\n"

	return result
