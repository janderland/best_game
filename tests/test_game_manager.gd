extends "res://addons/gdunit4/src/GdUnitTestSuite.gd"

# Test suite for GameManager

func test_game_manager_initialization():
	"""Test that GameManager initializes correctly"""
	assert_object(GameManager).is_not_null()
	assert_int(GameManager.current_level).is_equal(1)
	assert_float(GameManager.player_health).is_equal(100.0)
	assert_float(GameManager.player_sanity).is_equal(100.0)

func test_advance_level():
	"""Test level advancement"""
	GameManager.reset_game()
	var initial_level = GameManager.current_level

	var result = GameManager.advance_level()

	assert_bool(result).is_true()
	assert_int(GameManager.current_level).is_equal(initial_level + 1)
	assert_array(GameManager.levels_completed).contains([initial_level])

func test_max_level_completion():
	"""Test that game completes at max level"""
	GameManager.reset_game()
	GameManager.current_level = GameManager.max_level

	var result = GameManager.advance_level()

	assert_bool(result).is_false()
	assert_int(GameManager.current_state).is_equal(GameManager.GameState.VICTORY)

func test_player_damage():
	"""Test player damage system"""
	GameManager.reset_game()
	var initial_health = GameManager.player_health

	var died = GameManager.damage_player(30.0)

	assert_bool(died).is_false()
	assert_float(GameManager.player_health).is_equal(initial_health - 30.0)

func test_player_death():
	"""Test player death"""
	GameManager.reset_game()

	var died = GameManager.damage_player(200.0)

	assert_bool(died).is_true()
	assert_float(GameManager.player_health).is_equal(0.0)
	assert_int(GameManager.deaths).is_equal(1)

func test_sanity_modification():
	"""Test sanity system"""
	GameManager.reset_game()
	var initial_sanity = GameManager.player_sanity

	GameManager.modify_sanity(-20.0)

	assert_float(GameManager.player_sanity).is_equal(initial_sanity - 20.0)

func test_sanity_clamping():
	"""Test sanity stays within bounds"""
	GameManager.reset_game()

	GameManager.modify_sanity(200.0)
	assert_float(GameManager.player_sanity).is_equal(GameManager.player_max_sanity)

	GameManager.modify_sanity(-300.0)
	assert_float(GameManager.player_sanity).is_equal(0.0)

func test_devotee_interaction():
	"""Test Devotee relationship tracking"""
	GameManager.reset_game()

	GameManager.interact_with_devotee("kind")

	assert_int(GameManager.devotee_encounters).is_equal(1)
	assert_int(GameManager.devotee_affection).is_greater(0)

func test_devotee_stages():
	"""Test Devotee relationship stages"""
	GameManager.reset_game()

	var stage = GameManager.get_devotee_stage()
	assert_str(stage).is_equal("stranger")

	GameManager.devotee_affection = 150
	GameManager.devotee_obsession = 50
	stage = GameManager.get_devotee_stage()
	assert_str(stage).is_equal("devoted")

func test_memory_collection():
	"""Test memory fragment collection"""
	GameManager.reset_game()
	var initial_count = GameManager.memory_fragments_collected

	GameManager.collect_memory_fragment()

	assert_int(GameManager.memory_fragments_collected).is_equal(initial_count + 1)

func test_character_tracking():
	"""Test character meeting tracking"""
	GameManager.reset_game()

	GameManager.meet_character("devotee")

	assert_bool(GameManager.characters_met.has("devotee")).is_true()
	assert_int(GameManager.characters_met["devotee"]["encounters"]).is_equal(1)

func test_level_theme():
	"""Test level theme generation"""
	GameManager.reset_game()

	var theme = GameManager.get_level_theme()

	assert_str(theme).is_not_empty()

func test_level_intensity():
	"""Test level intensity calculation"""
	GameManager.reset_game()
	GameManager.current_level = 1

	var intensity1 = GameManager.get_level_intensity()

	GameManager.current_level = GameManager.max_level

	var intensity_max = GameManager.get_level_intensity()

	assert_float(intensity1).is_less(intensity_max)
	assert_float(intensity_max).is_equal(1.0)
