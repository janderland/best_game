extends Node

# Procedural Art Generator - Creates unique visual elements for each playthrough

var rng = RandomNumberGenerator.new()

# Color palettes based on themes
var theme_palettes = {
	"childhood_memory": [
		Color(0.9, 0.7, 0.5, 1.0),  # Warm yellows
		Color(0.7, 0.5, 0.8, 1.0),  # Soft purple
		Color(0.5, 0.8, 0.9, 1.0),  # Sky blue
		Color(0.9, 0.6, 0.7, 1.0)   # Pink
	],
	"lost_love": [
		Color(0.9, 0.3, 0.4, 1.0),  # Deep red
		Color(0.4, 0.2, 0.5, 1.0),  # Dark purple
		Color(0.8, 0.7, 0.6, 1.0),  # Faded rose
		Color(0.3, 0.3, 0.4, 1.0)   # Melancholy gray
	],
	"regret": [
		Color(0.4, 0.4, 0.3, 1.0),  # Muddy brown
		Color(0.5, 0.5, 0.6, 1.0),  # Gray
		Color(0.3, 0.4, 0.4, 1.0),  # Teal-gray
		Color(0.6, 0.5, 0.4, 1.0)   # Dusty orange
	],
	"fear": [
		Color(0.2, 0.2, 0.3, 1.0),  # Deep blue-black
		Color(0.4, 0.2, 0.2, 1.0),  # Dark red
		Color(0.3, 0.3, 0.3, 1.0),  # Shadow gray
		Color(0.5, 0.4, 0.5, 1.0)   # Bruise purple
	],
	"joy": [
		Color(1.0, 0.9, 0.4, 1.0),  # Bright yellow
		Color(1.0, 0.6, 0.4, 1.0),  # Orange
		Color(0.4, 0.9, 0.6, 1.0),  # Bright green
		Color(0.9, 0.5, 0.8, 1.0)   # Magenta
	],
	"betrayal": [
		Color(0.6, 0.3, 0.2, 1.0),  # Rust
		Color(0.3, 0.5, 0.3, 1.0),  # Sickly green
		Color(0.5, 0.4, 0.5, 1.0),  # Bruised purple
		Color(0.4, 0.4, 0.4, 1.0)   # Ash
	],
	"loneliness": [
		Color(0.3, 0.4, 0.5, 1.0),  # Cold blue
		Color(0.4, 0.4, 0.5, 1.0),  # Slate
		Color(0.5, 0.5, 0.6, 1.0),  # Silver
		Color(0.3, 0.3, 0.4, 1.0)   # Midnight
	],
	"rage": [
		Color(0.9, 0.2, 0.1, 1.0),  # Burning red
		Color(1.0, 0.4, 0.0, 1.0),  # Flame orange
		Color(0.7, 0.1, 0.1, 1.0),  # Blood
		Color(0.9, 0.7, 0.2, 1.0)   # Hot yellow
	],
	"grief": [
		Color(0.3, 0.3, 0.4, 1.0),  # Stormy blue
		Color(0.4, 0.4, 0.4, 1.0),  # Mourning gray
		Color(0.3, 0.3, 0.3, 1.0),  # Charcoal
		Color(0.4, 0.4, 0.5, 1.0)   # Rain
	],
	"hope": [
		Color(0.9, 0.9, 0.7, 1.0),  # Dawn yellow
		Color(0.6, 0.8, 0.9, 1.0),  # Sky blue
		Color(0.7, 0.9, 0.7, 1.0),  # Spring green
		Color(0.9, 0.8, 0.9, 1.0)   # Soft pink
	]
}

func _ready():
	rng.randomize()
	print("Procedural Art system initialized")

func generate_texture_for_theme(theme: String, size: Vector2, seed_val: int = -1) -> Image:
	"""Generate a procedural texture based on theme"""
	if seed_val >= 0:
		rng.seed = seed_val

	var image = Image.new()
	image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)


	var palette = get_palette_for_theme(theme)

	# Generate based on pattern type
	var pattern_type = rng.randi_range(0, 3)

	match pattern_type:
		0:  # Noise pattern
			generate_noise_pattern(image, palette)
		1:  # Geometric pattern
			generate_geometric_pattern(image, palette)
		2:  # Organic pattern
			generate_organic_pattern(image, palette)
		3:  # Memory fragments pattern
			generate_fragment_pattern(image, palette)

	return image

func get_palette_for_theme(theme: String) -> Array:
	"""Get color palette for a theme"""
	if theme_palettes.has(theme):
		return theme_palettes[theme]

	# Default palette
	return [
		Color(0.5, 0.5, 0.5, 1.0),
		Color(0.6, 0.6, 0.6, 1.0),
		Color(0.4, 0.4, 0.4, 1.0),
		Color(0.7, 0.7, 0.7, 1.0)
	]

func generate_noise_pattern(image: Image, palette: Array):
	"""Generate noise-based pattern"""
	var width = image.get_width()
	var height = image.get_height()

	for y in range(height):
		for x in range(width):
			var noise_val = generate_noise(x * 0.1, y * 0.1, rng.seed)
			var color_idx = int(abs(noise_val) * palette.size()) % palette.size()
			var color = palette[color_idx]

			# Add some variation
			var variation = (noise_val - 0.5) * 0.2
			color = Color(
				clamp(color.r + variation, 0, 1),
				clamp(color.g + variation, 0, 1),
				clamp(color.b + variation, 0, 1),
				color.a
			)

			image.set_pixel(x, y, color)

func generate_geometric_pattern(image: Image, palette: Array):
	"""Generate geometric shapes pattern"""
	var width = image.get_width()
	var height = image.get_height()

	# Fill with base color
	var base_color = palette[0]
	for y in range(height):
		for x in range(width):
			image.set_pixel(x, y, base_color)

	# Add geometric shapes
	var num_shapes = rng.randi_range(5, 15)
	for _i in range(num_shapes):
		var shape_type = rng.randi_range(0, 2)
		var color = palette[rng.randi_range(0, palette.size() - 1)]

		match shape_type:
			0:  # Circle
				draw_circle(image, rng.randi_range(0, width), rng.randi_range(0, height),
							rng.randi_range(10, 50), color)
			1:  # Rectangle
				draw_rect(image, rng.randi_range(0, width), rng.randi_range(0, height),
						  rng.randi_range(20, 100), rng.randi_range(20, 100), color)
			2:  # Line
				draw_line(image, rng.randi_range(0, width), rng.randi_range(0, height),
						  rng.randi_range(0, width), rng.randi_range(0, height), color)

func generate_organic_pattern(image: Image, palette: Array):
	"""Generate organic, flowing pattern"""
	var width = image.get_width()
	var height = image.get_height()

	for y in range(height):
		for x in range(width):
			# Use multiple octaves of noise for organic feel
			var val = 0.0
			val += generate_noise(x * 0.05, y * 0.05, rng.seed) * 0.5
			val += generate_noise(x * 0.1, y * 0.1, rng.seed + 1) * 0.3
			val += generate_noise(x * 0.2, y * 0.2, rng.seed + 2) * 0.2

			val = (val + 1.0) / 2.0  # Normalize to 0-1

			# Interpolate between palette colors
			var t = val * (palette.size() - 1)
			var idx1 = int(t) % palette.size()
			var idx2 = (idx1 + 1) % palette.size()
			var blend = t - floor(t)

			var color = palette[idx1].linear_interpolate(palette[idx2], blend)
			image.set_pixel(x, y, color)

func generate_fragment_pattern(image: Image, palette: Array):
	"""Generate shattered/fragmented pattern"""
	var width = image.get_width()
	var height = image.get_height()

	# Create voronoi-like cells
	var num_points = rng.randi_range(8, 20)
	var points = []
	var point_colors = []

	for _i in range(num_points):
		points.append(Vector2(rng.randi_range(0, width), rng.randi_range(0, height)))
		point_colors.append(palette[rng.randi_range(0, palette.size() - 1)])

	# Fill pixels based on nearest point
	for y in range(height):
		for x in range(width):
			var pos = Vector2(x, y)
			var nearest_dist = INF
			var nearest_idx = 0

			for i in range(points.size()):
				var dist = pos.distance_to(points[i])
				if dist < nearest_dist:
					nearest_dist = dist
					nearest_idx = i

			var color = point_colors[nearest_idx]

			# Add edge darkening
			if nearest_dist < 3:
				color = color.darkened(0.5)

			image.set_pixel(x, y, color)

func draw_circle(image: Image, cx: int, cy: int, radius: int, color: Color):
	"""Draw a circle on image"""
	var width = image.get_width()
	var height = image.get_height()

	for y in range(max(0, cy - radius), min(height, cy + radius + 1)):
		for x in range(max(0, cx - radius), min(width, cx + radius + 1)):
			var dx = x - cx
			var dy = y - cy
			if dx * dx + dy * dy <= radius * radius:
				image.set_pixel(x, y, color)

func draw_rect(image: Image, x: int, y: int, w: int, h: int, color: Color):
	"""Draw a rectangle on image"""
	var width = image.get_width()
	var height = image.get_height()

	for py in range(max(0, y), min(height, y + h)):
		for px in range(max(0, x), min(width, x + w)):
			image.set_pixel(px, py, color)

func draw_line(image: Image, x1: int, y1: int, x2: int, y2: int, color: Color):
	"""Draw a line on image using Bresenham's algorithm"""
	var dx = abs(x2 - x1)
	var dy = abs(y2 - y1)
	var sx = 1 if x1 < x2 else -1
	var sy = 1 if y1 < y2 else -1
	var err = dx - dy

	var x = x1
	var y = y1

	var width = image.get_width()
	var height = image.get_height()

	while true:
		if x >= 0 and x < width and y >= 0 and y < height:
			image.set_pixel(x, y, color)

		if x == x2 and y == y2:
			break

		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy

func generate_noise(x: float, y: float, seed_val: int) -> float:
	"""Simple noise function (pseudo-random based on position)"""
	var n = int(x * 374761393 + y * 668265263 + seed_val)
	n = (n ^ (n >> 13)) * 1274126177
	n = n ^ (n >> 16)

	return float(n % 1000) / 1000.0

func generate_character_sprite(character_type: String, size: int = 64) -> Image:
	"""Generate a unique sprite for a character"""
	var image = Image.new()
	image.create(size, size, false, Image.FORMAT_RGBA8)


	# Different appearance for each character type
	match character_type:
		"devotee":
			generate_devotee_sprite(image)
		"hollow_child":
			generate_hollow_child_sprite(image)
		"broken_soldier":
			generate_broken_soldier_sprite(image)
		"weeping_artist":
			generate_weeping_artist_sprite(image)
		"forgotten_mother":
			generate_forgotten_mother_sprite(image)
		"mirror_twin":
			generate_mirror_twin_sprite(image)
		_:
			generate_generic_sprite(image)

	return image

func generate_devotee_sprite(image: Image):
	"""Generate The Devotee's appearance - shifting and ethereal"""
	var size = image.get_width()
	var center = size / 2

	# Humanoid silhouette with ethereal edges
	for y in range(size):
		for x in range(size):
			var dx = x - center
			var dy = y - center
			var dist = sqrt(dx * dx + dy * dy)

			# Basic humanoid shape
			var alpha = 0.0

			# Head
			if dy < -size * 0.2 and dist < size * 0.2:
				alpha = 1.0 - (dist / (size * 0.2))

			# Body
			if dy >= -size * 0.2 and dy < size * 0.3 and abs(dx) < size * 0.15:
				alpha = 0.8

			# Add ethereal shimmer
			var noise = generate_noise(x * 0.2, y * 0.2, rng.seed)
			alpha *= 0.7 + noise * 0.3

			if alpha > 0:
				var color = Color(0.9, 0.8, 0.9, alpha)
				image.set_pixel(x, y, color)

func generate_hollow_child_sprite(image: Image):
	"""Generate Hollow Child - small, unsettling"""
	var size = image.get_width()
	var center = size / 2

	for y in range(size):
		for x in range(size):
			var dx = x - center
			var dy = y - center

			# Small child silhouette
			if dy < -size * 0.1 and sqrt(dx * dx + dy * dy) < size * 0.15:
				# Head with hollow eyes
				if abs(dx) > size * 0.05 and abs(dy + size * 0.1) < size * 0.03:
					image.set_pixel(x, y, Color(0, 0, 0, 1))  # Eyes
				else:
					image.set_pixel(x, y, Color(0.8, 0.8, 0.7, 1.0))
			elif dy >= -size * 0.1 and dy < size * 0.2 and abs(dx) < size * 0.1:
				# Body
				image.set_pixel(x, y, Color(0.7, 0.7, 0.6, 1.0))

func generate_broken_soldier_sprite(image: Image):
	"""Generate Broken Soldier - angular, aggressive"""
	var size = image.get_width()
	var center = size / 2

	for y in range(size):
		for x in range(size):
			# Angular, military silhouette
			var in_shape = false

			# Helmet
			if y < center * 0.8 and abs(x - center) < size * 0.2:
				in_shape = true

			# Body
			if y >= center * 0.8 and y < center * 1.6 and abs(x - center) < size * 0.18:
				in_shape = true

			if in_shape:
				var color = Color(0.3, 0.4, 0.3, 1.0)  # Military green-gray
				# Add glitches
				if rng.randf() < 0.1:
					color = Color(0.8, 0.2, 0.2, 1.0)
				image.set_pixel(x, y, color)

func generate_weeping_artist_sprite(image: Image):
	"""Generate Weeping Artist - dramatic, flowing"""
	var size = image.get_width()

	for y in range(size):
		for x in range(size):
			# Flowing robes
			var noise = generate_noise(x * 0.1, y * 0.1 + OS.get_ticks_msec() * 0.001, rng.seed)

			if noise > 0.4:
				var color = Color(0.4, 0.3, 0.5, 0.6 + noise * 0.4)
				image.set_pixel(x, y, color)

func generate_forgotten_mother_sprite(image: Image):
	"""Generate Forgotten Mother - sad, nurturing silhouette"""
	var size = image.get_width()
	var center = size / 2

	for y in range(size):
		for x in range(size):
			var dx = x - center
			var dy = y - center

			# Gentle, rounded maternal shape
			if dy < 0 and sqrt(dx * dx + dy * dy) < size * 0.18:
				# Head
				image.set_pixel(x, y, Color(0.7, 0.6, 0.5, 0.9))
			elif dy >= 0 and dy < size * 0.4:
				# Dress/body
				if abs(dx) < size * 0.15 + dy * 0.3:
					image.set_pixel(x, y, Color(0.5, 0.5, 0.6, 0.8))

func generate_mirror_twin_sprite(image: Image):
	"""Generate Mirror Twin - symmetrical, uncanny"""
	var size = image.get_width()
	var center = size / 2

	for y in range(size):
		for x in range(size):
			# Create perfectly symmetrical shape
			var dist_from_center = abs(x - center)

			# Humanoid but perfectly symmetrical (uncanny)
			if y < center and dist_from_center < size * 0.15:
				image.set_pixel(x, y, Color(0.6, 0.6, 0.7, 1.0))
			elif y >= center and y < center * 1.5 and dist_from_center < size * 0.12:
				image.set_pixel(x, y, Color(0.6, 0.6, 0.7, 1.0))

			# Mirror line
			if x == center:
				image.set_pixel(x, y, Color(1, 1, 1, 0.5))

func generate_generic_sprite(image: Image):
	"""Generate generic character sprite"""
	var size = image.get_width()
	var center = size / 2

	# Simple blob shape
	for y in range(size):
		for x in range(size):
			var dx = x - center
			var dy = y - center
			var dist = sqrt(dx * dx + dy * dy)

			if dist < size * 0.3:
				var alpha = 1.0 - (dist / (size * 0.3))
				image.set_pixel(x, y, Color(0.6, 0.6, 0.6, alpha))

func generate_enemy_sprite(enemy_type: String, size: int = 64) -> Image:
	"""Generate enemy sprite based on type"""
	var image = Image.new()
	image.create(size, size, false, Image.FORMAT_RGBA8)


	match enemy_type:
		"shadow_lurker":
			generate_shadow_lurker(image)
		"memory_wraith":
			generate_memory_wraith(image)
		"forgotten_one":
			generate_forgotten_one(image)
		"grief_incarnate":
			generate_grief_incarnate(image)
		"hollow_echo":
			generate_hollow_echo(image)
		_:
			generate_generic_enemy(image)

	return image

func generate_shadow_lurker(image: Image):
	"""Dark, amorphous entity"""
	var size = image.get_width()

	for y in range(size):
		for x in range(size):
			var noise = generate_noise(x * 0.15, y * 0.15, rng.seed)
			if noise > 0.5:
				var alpha = (noise - 0.5) * 2.0
				image.set_pixel(x, y, Color(0.1, 0.05, 0.15, alpha * 0.8))

func generate_memory_wraith(image: Image):
	"""Ghostly, fading entity"""
	var size = image.get_width()
	var center = size / 2

	for y in range(size):
		for x in range(size):
			var dx = x - center
			var dy = y - center
			var dist = sqrt(dx * dx + dy * dy)

			if dist < size * 0.35:
				var alpha = 0.6 * (1.0 - dist / (size * 0.35))
				image.set_pixel(x, y, Color(0.7, 0.7, 0.8, alpha))

func generate_forgotten_one(image: Image):
	"""Humanoid but wrong"""
	var size = image.get_width()
	var center = size / 2

	for y in range(size):
		for x in range(size):
			var dx = x - center
			var dy = y - center

			# Distorted humanoid
			if sqrt(dx * dx + dy * dy) < size * 0.25:
				var noise = generate_noise(x * 0.3, y * 0.3, rng.seed)
				if noise > 0.3:
					image.set_pixel(x, y, Color(0.4, 0.35, 0.4, 0.9))

func generate_grief_incarnate(image: Image):
	"""Heavy, oppressive presence"""
	var size = image.get_width()

	for y in range(size):
		for x in range(size):
			var darkness = float(y) / float(size)
			image.set_pixel(x, y, Color(0.2, 0.2, 0.25, darkness * 0.9))

func generate_hollow_echo(image: Image):
	"""Outline of a person, nothing inside"""
	var size = image.get_width()
	var center = size / 2

	for y in range(size):
		for x in range(size):
			var dx = x - center
			var dy = y - center
			var dist = sqrt(dx * dx + dy * dy)

			# Ring shape (outline only)
			if dist > size * 0.2 and dist < size * 0.28:
				image.set_pixel(x, y, Color(0.5, 0.5, 0.5, 0.7))

func generate_generic_enemy(image: Image):
	"""Generic threatening shape"""
	var size = image.get_width()
	var center = size / 2

	for y in range(size):
		for x in range(size):
			var dx = x - center
			var dy = y - center
			var dist = sqrt(dx * dx + dy * dy)

			if dist < size * 0.3:
				image.set_pixel(x, y, Color(0.7, 0.2, 0.2, 0.8))
