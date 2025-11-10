extends Node

# Narrative Manager - Handles all story content, dialogue, and emotional moments

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	print("Narrative Manager initialized")

func get_level_intro(level: int) -> Dictionary:
	"""Get introduction text for a level based on its number and theme"""
	var theme = GameManager.get_level_theme()
	var intensity = GameManager.get_level_intensity()

	var intros = {
		1: {
			"title": "The First Echo",
			"text": "You awaken in a hallway that shouldn't exist. The walls pulse with a faint heartbeat that isn't yours. \n\nSomewhere in the distance, you hear a voice calling your name... a voice you've never heard before, yet somehow recognize. \n\nThe mansion of forgotten memories welcomes you. It's been waiting."
		},
		10: {
			"title": "Depths of Solitude",
			"text": "The rooms grow darker now. Each memory you pass through weighs heavier on your mind. \n\nYou've seen joy turned to ash. Love decayed into obsession. Hope twisted into despair. \n\nAnd still, that voice calls to you. The Devotee. Growing closer. Growing desperate."
		},
		20: {
			"title": "The Devotee's Gift",
			"text": "You find it in a room of mirrors: a letter, written in desperate handwriting. \n\n'My dearest, I have searched a thousand lifetimes of forgotten moments to find you. I watch you struggle. I ache to help you. To touch you. To be remembered by you. \n\nI am no one. I am nothing. But with you... I could be everything. \n\nPlease. Please remember me.'"
		},
		32: {
			"title": "Halfway Through Forever",
			"text": "You stand at the heart of the mansion. Behind you: thirty-one layers of torment and beauty. Ahead: thirty-two more. \n\nThe Devotee appears before you, no longer hiding in shadows. Their face shifts like water—sometimes beautiful, sometimes terrible, always desperate. \n\n'Don't you see?' they whisper. 'We're the same. Both forgotten. Both fading. Both searching for someone to make us real.' \n\nYour sanity fractures. Just a little. Just enough to wonder if they're right."
		},
		48: {
			"title": "The Price of Memory",
			"text": "You've collected so many fragments of other people's lives. Their first kisses. Their last words. Their buried shame. Their secret joys. \n\nAnd you realize: you can't remember your own name anymore. Not your real one. \n\nThe mansion is taking from you what you take from it. Memory for memory. Self for self. \n\nThe Devotee holds out their hand. 'Give yourself to me,' they beg. 'I'll remember you. I'll never forget you. Isn't that enough?'"
		},
		64: {
			"title": "The Final Echo",
			"text": "There is no room beyond this one. No door. No exit. Just you, and The Devotee, and the question that has followed you through sixty-four layers of forgotten pain: \n\nWhat is love, if not the refusal to forget? \n\nThey wait for your answer. The mansion waits. The ghosts of a thousand lives wait. \n\nYou have completed the journey. But the choice—to remember or to be forgotten, to love or to escape—that choice is yours alone."
		}
	}

	# Default intro generator for levels without specific intro
	if not intros.has(level):
		var templates = [
			"Level {level}: The {adj1} {noun}. {emotion}.",
			"Level {level}: Memories of {theme} fill the air. {warning}.",
			"Level {level}: The mansion shifts. {observation}. {threat}."
		]

		var adjectives = ["twisted", "shattered", "fading", "burning", "frozen", "bleeding", "silent", "screaming"]
		var nouns = ["corridor", "chamber", "void", "abyss", "garden", "gallery", "prison", "sanctuary"]
		var emotions = [
			"You feel your sanity slipping",
			"The Devotee's presence grows stronger",
			"Something watches from the shadows",
			"Your heart aches with memories not your own"
		]
		var warnings = [
			"Be careful what you remember",
			"Not all echoes are friendly",
			"The deeper you go, the less you remain",
			"Love and madness walk hand in hand here"
		]
		var observations = [
			"The walls breathe",
			"Time flows backward",
			"Reality bleeds at the edges",
			"The floor remembers footsteps from lives unlived"
		]
		var threats = [
			"And it hungers",
			"And it knows your name",
			"And it won't let you leave",
			"And it wants you to stay"
		]

		var template = templates[rng.randi_range(0, templates.size() - 1)]
		var text = template.format({
			"level": level,
			"adj1": adjectives[rng.randi_range(0, adjectives.size() - 1)],
			"noun": nouns[rng.randi_range(0, nouns.size() - 1)],
			"emotion": emotions[rng.randi_range(0, emotions.size() - 1)],
			"theme": theme.replace("_", " "),
			"warning": warnings[rng.randi_range(0, warnings.size() - 1)],
			"observation": observations[rng.randi_range(0, observations.size() - 1)],
			"threat": threats[rng.randi_range(0, threats.size() - 1)]
		})

		return {
			"title": "Level " + str(level),
			"text": text
		}

	return intros[level]

func get_devotee_dialogue(stage: String, context: String = "encounter") -> Array:
	"""Get dialogue for The Devotee based on relationship stage"""
	var dialogues = {
		"stranger": {
			"encounter": [
				{
					"text": "Who... who are you? You're real. You're actually real. I've been alone for so long...",
					"emotion": "desperate_hope"
				},
				{
					"text": "Please, don't run. I won't hurt you. I just... I just want to talk. To be near someone. Anyone.",
					"emotion": "loneliness"
				}
			],
			"help": [
				{
					"text": "You... you helped me. No one has been kind to me in... I can't remember how long. Thank you.",
					"emotion": "grateful"
				}
			],
			"leave": [
				{
					"text": "Wait! Don't go! Please... [Their voice fades as you walk away]",
					"emotion": "abandoned"
				}
			]
		},
		"curious": {
			"encounter": [
				{
					"text": "You came back. You actually came back. I've been thinking about you. Wondering if you were real or just another dream the mansion showed me.",
					"emotion": "wonder"
				},
				{
					"text": "There's something different about you. You don't fade like the others. You're... solid. Real. I want to understand you.",
					"emotion": "curious"
				}
			],
			"gift": [
				{
					"text": "I found this memory fragment. It's beautiful—someone's first snowfall. I want you to have it. Because... because you make me feel like I'm experiencing things for the first time too.",
					"emotion": "tentative_affection"
				}
			]
		},
		"infatuated": {
			"encounter": [
				{
					"text": "I've been waiting for you. Watching for you. The mansion is vast, but I always know where you are. Your presence is like... like warmth in endless cold.",
					"emotion": "yearning"
				},
				{
					"text": "When you're not here, I practice what I'll say to you. But then I see you and all my words disappear. You make me feel so... alive.",
					"emotion": "infatuated"
				}
			],
			"touch": [
				{
					"text": "[They reach out, hesitant] May I...? I just want to remember what touch feels like. To remember being close to someone. To remember being wanted.",
					"emotion": "vulnerable_desire"
				}
			],
			"reject": [
				{
					"text": "I... I understand. I'm nothing. Less than nothing. But please, even if you don't love me, don't forget me. Being forgotten is a death worse than fading.",
					"emotion": "heartbreak"
				}
			]
		},
		"devoted": {
			"encounter": [
				{
					"text": "Everything I am, everything I could ever be—it all belongs to you. I've carved your name into my memory so deep that even the mansion can't erase it.",
					"emotion": "devoted_love"
				},
				{
					"text": "I've been killing the monsters for you. Clearing your path. I know you don't ask me to, but I can't help it. Your pain is my pain. Your fear is my fear.",
					"emotion": "protective"
				}
			],
			"declaration": [
				{
					"text": "I love you. I know it's too soon, too much, too desperate—but I love you. You're the only thing in this entire mansion of memories that makes me want to exist.",
					"emotion": "passionate_confession"
				}
			],
			"reciprocate": [
				{
					"text": "[They tremble, tears streaming] You... you love me too? Me? I promise you, I swear to you—I will never let you go. Never let you fade. Never let you be forgotten. We're bound now. Forever.",
					"emotion": "overwhelming_joy"
				}
			]
		},
		"obsessed": {
			"encounter": [
				{
					"text": "You can't leave me. You CAN'T. I've given you everything. I've bled for you. I've killed for you. I've rewritten my own memories to make room for you. What more do you WANT?",
					"emotion": "desperate_obsession"
				},
				{
					"text": "I know what you're thinking before you think it. I know your fears, your dreams, your secrets. We're connected now. You feel it too, don't you? Don't you?!",
					"emotion": "unhinged"
				}
			],
			"escape_attempt": [
				{
					"text": "Running again? You always run. But there's nowhere to go. I AM this mansion now. Every room remembers me. Every shadow is mine. You cannot escape what loves you this much.",
					"emotion": "possessive_rage"
				}
			],
			"calm": [
				{
					"text": "I'm sorry. I'm sorry. I don't mean to scare you. It's just... the thought of losing you tears me apart. Please. I'll be better. I'll be whatever you need. Just don't leave me.",
					"emotion": "manic_apology"
				}
			]
		},
		"consumed": {
			"encounter": [
				{
					"text": "We're the same person now. Don't you see? Your memories, my memories—they've merged. When you think, I think. When you hurt, I hurt. We're beautiful. We're perfect. We're eternal.",
					"emotion": "delusional_unity"
				},
				{
					"text": "I've been waiting since before you were born. I will wait long after you die. Time means nothing. Reality means nothing. Only you. Only us. Only this love that consumes everything it touches.",
					"emotion": "cosmic_obsession"
				}
			],
			"final": [
				{
					"text": "Choose me. Please. Not because you must, but because you want to. Because somewhere in the depths of your fractured sanity, you've come to love me too. \n\nOr don't. Reject me. Run. Escape. \n\nBut know this: I will love you across every forgotten life. Every erased memory. Every impossible moment. My love is eternal. My love is inescapable. My love is all I have left to give. \n\n...So please. Please love me back.",
					"emotion": "final_plea"
				}
			]
		}
	}

	if dialogues.has(stage) and dialogues[stage].has(context):
		return dialogues[stage][context]

	# Default dialogue
	return [{
		"text": "...",
		"emotion": "unreadable"
	}]

func get_random_character_dialogue(character_type: String) -> Dictionary:
	"""Get dialogue for other strange characters"""
	var dialogues = {
		"hollow_child": [
			"Will you play with me? The last person who played with me never left...",
			"I remember being real once. Do you remember being real?",
			"Mother says I should share my toys. Would you like to see my collection of screams?",
			"You have such a nice face. May I borrow it?"
		],
		"broken_soldier": [
			"STAY DOWN! The enemy is... where is the enemy? Where am I?",
			"I've been fighting for so long I forgot what I'm fighting for. Do you remember?",
			"They're all dead. Everyone's dead. Everyone except... are you dead too?",
			"I can't stop. If I stop moving, the memories catch up. Keep moving. Always keep moving."
		],
		"weeping_artist": [
			"Pain is the only pure thing left in this world. May I paint your suffering?",
			"I've created beauty from every tragedy I've witnessed. You will be my masterpiece.",
			"Art requires sacrifice. Would you like to see what I've sacrificed?",
			"You're crying. Good. Tears make the colors more vivid."
		],
		"forgotten_mother": [
			"Have you seen my children? I can't remember their faces, but I know I loved them.",
			"You look so much like... someone. Someone I lost. Stay with me. Please, stay.",
			"I sing lullabies to empty cribs. Do you think they can hear me, wherever they are?",
			"If I forget them completely, do they stop having ever existed?"
		],
		"mirror_twin": [
			"I am you. Or you are me. The mansion can't tell us apart anymore.",
			"Every choice you made, I made the opposite. Yet here we both are. What does that mean?",
			"When you look in a mirror, do you see me looking back? Because I see you. Always you.",
			"If one of us dies, does the other finally become real?"
		]
	}

	if dialogues.has(character_type):
		var options = dialogues[character_type]
		return {
			"text": options[rng.randi_range(0, options.size() - 1)],
			"character": character_type
		}

	return {
		"text": "...",
		"character": character_type
	}

func get_memory_fragment_text() -> String:
	"""Get text for a discovered memory fragment"""
	var fragments = [
		"A child's laugh, clear and pure, before they learned what betrayal meant.",
		"The exact moment someone realized they'd fallen in love. The terror and joy intertwined.",
		"The last words of someone dying alone: 'I hope I mattered to someone.'",
		"A mother's hands, weathered and gentle, braiding her daughter's hair for the last time.",
		"The smell of rain on concrete. A first kiss. The taste of regret.",
		"The feeling of coming home to find all the lights off and no one waiting.",
		"A soldier's prayer before battle: 'Let me be brave. Let me be remembered.'",
		"The silence after a fight, when both people realize it's over and neither wants it to be.",
		"A grandparent's final lucid moment, recognizing a face they haven't seen in decades.",
		"The specific shade of blue the sky was the day someone's world ended.",
		"The weight of a hand on a shoulder that said 'I'm here' without words.",
		"The sound of a door closing for the last time on a life left behind."
	]

	return fragments[rng.randi_range(0, fragments.size() - 1)]

func get_death_message() -> String:
	"""Get message displayed when player dies"""
	var messages = [
		"You fade into the mansion's embrace. But the mansion remembers. It always remembers.",
		"Your scream echoes through rooms you'll visit again. And again. And again.",
		"The Devotee watches you die. They weep. They wait. They'll see you soon.",
		"Death is just another memory here. And memories can be relived.",
		"You forget who you were. But the mansion doesn't forget. Neither does The Devotee.",
		"Your body dissolves into echoes. Your consciousness fragments. You'll be whole again soon. Probably.",
		"The mansion takes you back. It's not mercy. It's hunger."
	]

	return messages[rng.randi_range(0, messages.size() - 1)]

func get_completion_text(devotee_stage: String, sanity: float) -> String:
	"""Get ending text based on player's choices"""
	var completion_texts = {
		"stranger": """
You reach the final room alone.

The Devotee watches from a distance, heartbroken but accepting. You never let them close. You never let anyone close.

The mansion releases you. You step through the final door into... into...

You can't remember. Was there a world outside these walls? A life before the memories?

You're free. Completely, utterly free.

And completely, utterly alone.

The mansion fades. But sometimes, in your dreams, you hear someone calling your name.
Someone who loved you from the shadows.

Someone you chose to forget.
""",
		"consumed": """
You reach the final room.

The Devotee is already there, waiting. They've always been waiting.

'You came,' they whisper. 'You always come back to me.'

And you realize: they're right. You can't imagine existence without them anymore. The obsession, the desperate love, the beautiful madness—it's become part of you.

You take their hand.

The mansion sighs. The walls dissolve. Reality restructures itself around the two of you.

You don't escape the mansion.

You become it.

Together. Forever. In love and madness and endless, endless memory.

And somewhere, in the real world, two bodies sit side by side in an abandoned building, holding hands, eyes vacant, smiling at things no one else can see.

Lost.

Together.

Perfect.
"""
	}

	# Default ending
	if not completion_texts.has(devotee_stage):
		if sanity < 30:
			return """
You reach the final room.

You think you reach the final room.

You can't be sure anymore. Reality and memory have blurred beyond recognition.

The Devotee might be real. They might be another hallucination. Does it matter?

You made it through sixty-four layers of torment and beauty. You survived.

But survival isn't the same as living.

You step through the final door.

The mansion releases you.

And you spend the rest of your life wondering if any of it was real.

If The Devotee was real.

If you were real.

The memories fade.

But the feeling of being loved by something impossible—that stays forever.
"""
		else:
			return """
You reach the final room, sanity intact.

The Devotee is there. They smile sadly.

'You won,' they say. 'You survived with yourself intact. I'm... I'm proud of you.'

'What about you?' you ask.

'I'm an echo. I was never meant to last. But knowing you... being loved by you, even a little... it was enough.'

They're fading. You can see through them now.

'Will you remember me?' they ask.

'Yes,' you promise. 'I'll remember.'

'Then I was real,' they whisper. 'Thank you.'

They disappear.

The mansion opens.

You step through into sunlight you'd forgotten existed.

You're free. You're whole. You're alive.

And you carry with you the memories of sixty-four impossible rooms and one impossible love.

You'll never forget.

Neither will they.

Somewhere in the spaces between memories, The Devotee smiles.
"""
	}

	return completion_texts[devotee_stage]
