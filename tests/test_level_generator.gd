extends "res://addons/gdunit4/src/GdUnitTestSuite.gd"

# Test suite for LevelGenerator

var level_generator

func before_test():
	"""Set up before each test"""
	level_generator = preload("res://scripts/LevelGenerator.gd").new()

func after_test():
	"""Clean up after each test"""
	if level_generator:
		level_generator.free()

func test_level_generation():
	"""Test that levels generate without errors"""
	level_generator.generate_level(1)

	assert_int(level_generator.rooms.size()).is_greater(0)
	assert_object(level_generator.spawn_point).is_not_null()
	assert_object(level_generator.exit_point).is_not_null()

func test_room_count():
	"""Test that room count is within expected range"""
	level_generator.generate_level(1)

	var room_count = level_generator.rooms.size()
	assert_int(room_count).is_greater_equal(level_generator.MIN_ROOMS)
	assert_int(room_count).is_less_equal(level_generator.MAX_ROOMS)

func test_no_overlapping_rooms():
	"""Test that rooms don't overlap"""
	level_generator.generate_level(1)

	var rooms = level_generator.rooms

	for i in range(rooms.size()):
		for j in range(i + 1, rooms.size()):
			var overlaps = rooms[i].intersects(rooms[j])
			assert_bool(overlaps).is_false()

func test_spawn_and_exit_exist():
	"""Test that spawn and exit rooms are created"""
	level_generator.generate_level(1)

	var has_spawn = false
	var has_exit = false

	for room in level_generator.rooms:
		if room.room_type == "spawn":
			has_spawn = true
		if room.room_type == "exit":
			has_exit = true

	assert_bool(has_spawn).is_true()
	assert_bool(has_exit).is_true()

func test_deterministic_generation():
	"""Test that same seed produces same level"""
	var seed_value = 12345

	level_generator.generate_level(1, seed_value)
	var rooms1 = level_generator.rooms.size()

	level_generator.clear_level()

	level_generator.generate_level(1, seed_value)
	var rooms2 = level_generator.rooms.size()

	assert_int(rooms1).is_equal(rooms2)

func test_level_data_generation():
	"""Test that level data is properly compiled"""
	level_generator.generate_level(1)

	var data = level_generator.get_level_data()

	assert_dict(data).contains_keys(["level_number", "rooms", "spawn_point", "exit_point"])
	assert_int(data["level_number"]).is_equal(1)
	assert_array(data["rooms"]).is_not_empty()

func test_entity_spawning():
	"""Test that entities are spawned in rooms"""
	level_generator.generate_level(5)  # Higher level for more entities

	var total_entities = 0
	for room in level_generator.rooms:
		total_entities += room.entities.size()

	assert_int(total_entities).is_greater(0)

func test_boss_room_spawns():
	"""Test that boss rooms spawn on appropriate levels"""
	level_generator.generate_level(8)  # Level 8 should have boss

	var has_boss_room = false
	for room in level_generator.rooms:
		if room.room_type == "boss":
			has_boss_room = true
			break

	assert_bool(has_boss_room).is_true()

func test_level_intensity_increases():
	"""Test that higher levels have more entities"""
	level_generator.generate_level(1)
	var entities_level_1 = 0
	for room in level_generator.rooms:
		entities_level_1 += room.entities.size()

	level_generator.clear_level()

	level_generator.generate_level(50)
	var entities_level_50 = 0
	for room in level_generator.rooms:
		entities_level_50 += room.entities.size()

	# Higher levels should generally have more entities
	# Using greater_equal in case of random variation
	assert_int(entities_level_50).is_greater_equal(entities_level_1)
