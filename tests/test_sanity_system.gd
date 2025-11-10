extends "res://addons/gdunit4/src/GdUnitTestSuite.gd"

# Test suite for SanitySystem

func test_sanity_initialization():
	"""Test SanitySystem initializes correctly"""
	assert_object(SanitySystem).is_not_null()
	assert_float(SanitySystem.current_sanity).is_equal(1.0)

func test_sanity_modification():
	"""Test sanity modification"""
	SanitySystem.set_sanity(1.0)
	var initial = SanitySystem.current_sanity

	SanitySystem.set_sanity(0.5)

	assert_float(SanitySystem.current_sanity).is_equal(0.5)

func test_sanity_clamping():
	"""Test sanity stays within 0-1 range"""
	SanitySystem.set_sanity(2.0)
	assert_float(SanitySystem.current_sanity).is_equal(1.0)

	SanitySystem.set_sanity(-0.5)
	assert_float(SanitySystem.current_sanity).is_equal(0.0)

func test_sanity_thresholds():
	"""Test sanity threshold detection"""
	SanitySystem.set_sanity(1.0)
	var threshold = SanitySystem.get_current_threshold()
	assert_str(threshold).is_equal("stable")

	SanitySystem.set_sanity(0.5)
	threshold = SanitySystem.get_current_threshold()
	assert_str(threshold).is_equal("disturbed")

	SanitySystem.set_sanity(0.1)
	threshold = SanitySystem.get_current_threshold()
	assert_str(threshold).is_equal("breaking")

func test_visual_effects_scale():
	"""Test visual effects scale with sanity"""
	SanitySystem.set_sanity(1.0)
	SanitySystem.update_visual_effects()
	var aberration_high = SanitySystem.chromatic_aberration_strength

	SanitySystem.set_sanity(0.2)
	SanitySystem.update_visual_effects()
	var aberration_low = SanitySystem.chromatic_aberration_strength

	assert_float(aberration_low).is_greater(aberration_high)

func test_hallucination_chance():
	"""Test hallucination chance increases with low sanity"""
	SanitySystem.set_sanity(1.0)
	SanitySystem.update_gameplay_effects()
	var chance_high = SanitySystem.hallucination_chance

	SanitySystem.set_sanity(0.2)
	SanitySystem.update_gameplay_effects()
	var chance_low = SanitySystem.hallucination_chance

	assert_float(chance_low).is_greater(chance_high)

func test_movement_stability():
	"""Test movement stability decreases at low sanity"""
	SanitySystem.set_sanity(1.0)
	var stability_high = SanitySystem.get_movement_stability()

	SanitySystem.set_sanity(0.1)
	var stability_low = SanitySystem.get_movement_stability()

	assert_float(stability_high).is_equal(1.0)
	assert_float(stability_low).is_less(1.0)

func test_sanity_damage():
	"""Test sanity damage application"""
	SanitySystem.set_sanity(1.0)

	SanitySystem.apply_sanity_damage(0.3, "test")

	assert_float(SanitySystem.current_sanity).is_equal(0.7)

func test_enemy_perception():
	"""Test enemy perception modifier"""
	SanitySystem.set_sanity(1.0)
	var perception_high = SanitySystem.get_enemy_perception()

	SanitySystem.set_sanity(0.2)
	var perception_low = SanitySystem.get_enemy_perception()

	assert_float(perception_high).is_greater(perception_low)
	assert_float(perception_low).is_greater_equal(0.3)  # Never drops below minimum
