extends Area2D

# Item - Collectible items (health, sanity restore, etc.)

var collected = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if collected:
		return

	if body.is_in_group("player"):
		collect(body)

func interact(player):
	"""Interact with item"""
	collect(player)

func collect(player):
	"""Collect this item"""
	if collected:
		return

	collected = true

	var item_type = get_meta("item_type") if has_meta("item_type") else "health"

	match item_type:
		"health":
			print("+ Health restored +")
			if player.has_method("heal"):
				player.heal(30)
		"sanity":
			print("+ Sanity restored +")
			if player.has_method("restore_sanity"):
				player.restore_sanity(30)

	# Visual collection effect
	var tween = create_tween().set_parallel(true)

	if has_node("Sprite"):
		var sprite = get_node("Sprite")
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "position:y", sprite.position.y - 30, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await tween.finished

	queue_free()
