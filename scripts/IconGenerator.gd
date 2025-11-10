extends Node

# Generate game icon on startup

static func generate_icon():
	"""Generate game icon"""
	var size = 64
	var img = Image.new()
	img.create(size, size, false, Image.FORMAT_RGBA8)


	# Background
	for y in range(size):
		for x in range(size):
			img.set_pixel(x, y, Color(0.1, 0.1, 0.15, 1.0))

	# Draw an eye (symbolic of watching/memory/The Devotee)
	var center_x = size / 2
	var center_y = size / 2

	# Outer eye shape
	for y in range(size):
		for x in range(size):
			var dx = x - center_x
			var dy = y - center_y

			# Ellipse for eye
			if (dx * dx) / 500.0 + (dy * dy) / 100.0 < 1.0:
				img.set_pixel(x, y, Color(0.8, 0.75, 0.8, 1.0))

			# Pupil
			if sqrt(dx * dx + dy * dy) < 6:
				img.set_pixel(x, y, Color(0.2, 0.15, 0.3, 1.0))

			# Highlight
			if sqrt((dx - 2) * (dx - 2) + (dy - 2) * (dy - 2)) < 2:
				img.set_pixel(x, y, Color(0.9, 0.9, 1.0, 0.8))


	# Save as PNG
	img.save_png("res://icon.png")
	print("Icon generated")

	return img
