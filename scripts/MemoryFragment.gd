extends Area2D

# Memory Fragment - Collectible that restores sanity and reveals story

var collected = false

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _process(_delta):
	# Gentle floating animation
	if not collected:
		position.y += sin(OS.get_ticks_msec() / 200.0) * 0.1

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
	var tween = Tween.new()
	add_child(tween)

	if has_node("Sprite"):
		var sprite = get_node("Sprite")
		tween.interpolate_property(sprite, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(sprite, "scale", sprite.scale, sprite.scale * 2.0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)

	tween.start()
	yield(tween, "tween_all_completed")

	queue_free()
