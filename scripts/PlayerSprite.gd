extends Sprite

# PlayerSprite - Generate player appearance

func _ready():
	generate_player_sprite()

func generate_player_sprite():
	"""Generate a simple player sprite"""
	var size = 48
	var img = Image.new()
	img.create(size, size, false, Image.FORMAT_RGBA8)


	var center = size / 2

	# Draw simple humanoid figure
	for y in range(size):
		for x in range(size):
			var dx = x - center
			var dy = y - center

			# Head
			if dy < -size * 0.1 and dy > -size * 0.35:
				if sqrt(dx * dx + dy * dy) < size * 0.15:
					img.set_pixel(x, y, Color(0.3, 0.7, 0.9, 1.0))

			# Body
			if dy >= -size * 0.1 and dy < size * 0.25:
				if abs(dx) < size * 0.15:
					img.set_pixel(x, y, Color(0.3, 0.7, 0.9, 1.0))

			# Legs
			if dy >= size * 0.25 and dy < size * 0.45:
				if abs(dx - size * 0.08) < size * 0.07 or abs(dx + size * 0.08) < size * 0.07:
					img.set_pixel(x, y, Color(0.3, 0.7, 0.9, 1.0))


	var tex = ImageTexture.new()
	tex.create_from_image(img)
	texture = tex
