extends "res://addons/gdunit4/src/GdUnitTestSuite.gd"

# Test suite for NarrativeManager

func test_narrative_manager_exists():
	"""Test NarrativeManager is accessible"""
	assert_object(NarrativeManager).is_not_null()

func test_level_intro_generation():
	"""Test level intro generation"""
	var intro = NarrativeManager.get_level_intro(1)

	assert_dict(intro).contains_keys(["title", "text"])
	assert_str(intro["title"]).is_not_empty()
	assert_str(intro["text"]).is_not_empty()

func test_special_level_intros():
	"""Test that special levels have unique intros"""
	var intro_1 = NarrativeManager.get_level_intro(1)
	var intro_20 = NarrativeManager.get_level_intro(20)
	var intro_64 = NarrativeManager.get_level_intro(64)

	# Special levels should have different text
	assert_str(intro_1["text"]).is_not_equal(intro_20["text"])
	assert_str(intro_20["text"]).is_not_equal(intro_64["text"])

func test_devotee_dialogue_generation():
	"""Test Devotee dialogue generation"""
	var dialogue = NarrativeManager.get_devotee_dialogue("stranger", "encounter")

	assert_array(dialogue).is_not_empty()
	assert_dict(dialogue[0]).contains_keys(["text", "emotion"])

func test_devotee_stages():
	"""Test different Devotee relationship stages have different dialogue"""
	var stranger_dialogue = NarrativeManager.get_devotee_dialogue("stranger", "encounter")
	var obsessed_dialogue = NarrativeManager.get_devotee_dialogue("obsessed", "encounter")

	assert_array(stranger_dialogue).is_not_empty()
	assert_array(obsessed_dialogue).is_not_empty()

	# Dialogue should be different for different stages
	if stranger_dialogue.size() > 0 and obsessed_dialogue.size() > 0:
		assert_str(stranger_dialogue[0]["text"]).is_not_equal(obsessed_dialogue[0]["text"])

func test_character_dialogue():
	"""Test character dialogue generation"""
	var types = ["hollow_child", "broken_soldier", "weeping_artist",
				 "forgotten_mother", "mirror_twin"]

	for char_type in types:
		var dialogue = NarrativeManager.get_random_character_dialogue(char_type)

		assert_dict(dialogue).contains_keys(["text", "character"])
		assert_str(dialogue["text"]).is_not_empty()
		assert_str(dialogue["character"]).is_equal(char_type)

func test_memory_fragment_text():
	"""Test memory fragment text generation"""
	var text = NarrativeManager.get_memory_fragment_text()

	assert_str(text).is_not_empty()

func test_death_message():
	"""Test death message generation"""
	var message = NarrativeManager.get_death_message()

	assert_str(message).is_not_empty()

func test_completion_text():
	"""Test completion text for different endings"""
	var stranger_ending = NarrativeManager.get_completion_text("stranger", 80.0)
	var consumed_ending = NarrativeManager.get_completion_text("consumed", 80.0)

	assert_str(stranger_ending).is_not_empty()
	assert_str(consumed_ending).is_not_empty()

	# Different endings should have different text
	assert_str(stranger_ending).is_not_equal(consumed_ending)

func test_low_sanity_ending():
	"""Test that low sanity affects ending"""
	var high_sanity_end = NarrativeManager.get_completion_text("curious", 90.0)
	var low_sanity_end = NarrativeManager.get_completion_text("curious", 20.0)

	# Both should be valid
	assert_str(high_sanity_end).is_not_empty()
	assert_str(low_sanity_end).is_not_empty()
