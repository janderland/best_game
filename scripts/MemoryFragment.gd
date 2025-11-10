extends Area2D

# Memory Fragment - Collectible that restores sanity and reveals story

var collected = false

func _ready():
	body_entered.connect(_on_body_entered)

func _process(_delta):
	# Gentle floating animation
	if not collected:
		position.y += sin(Time.get_ticks_msec() / 200.0) * 0.1

func _on_body_entered(body):
	if collected:
		return

	if body.is_in_group("player"):
		collect()

func interact(player):
	"""Interact with memory fragment"""
	collect()

func collect():
	"""Collect this memory fragment"""
	if collected:
		return

	collected = true

	print("\n*** MEMORY FRAGMENT COLLECTED ***")

	# Get memory text
	var memory_text = NarrativeManager.get_memory_fragment_text()
	print(memory_text)
	print("***\n")

	# Update game manager
	GameManager.collect_memory_fragment()

	# Visual collection effect
	var tween = create_tween().set_parallel(true)

	if has_node("Sprite"):
		var sprite = get_node("Sprite")
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "scale", sprite.scale * 2.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await tween.finished

	queue_free()
