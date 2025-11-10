shader_type canvas_item;

// Sanity Effect Shader - Visual distortion based on player's mental state

uniform float sanity : hint_range(0.0, 1.0) = 1.0;
uniform float chromatic_aberration : hint_range(0.0, 0.1) = 0.0;
uniform float vignette : hint_range(0.0, 1.0) = 0.3;
uniform float distortion : hint_range(0.0, 0.5) = 0.0;
uniform float time_param = 0.0;

// Simple noise function
float noise(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float insanity = 1.0 - sanity;

	// Distortion effect - warps screen at low sanity
	if (distortion > 0.0) {
		vec2 center = vec2(0.5, 0.5);
		vec2 offset = uv - center;
		float dist = length(offset);

		// Sinusoidal distortion that pulses
		float wave = sin(dist * 20.0 - time_param * 2.0) * distortion * insanity;
		uv += offset * wave;
	}

	// Chromatic aberration - RGB split at low sanity
	vec4 color;
	if (chromatic_aberration > 0.0) {
		float r = texture(TEXTURE, uv + vec2(chromatic_aberration, 0.0)).r;
		float g = texture(TEXTURE, uv).g;
		float b = texture(TEXTURE, uv - vec2(chromatic_aberration, 0.0)).b;
		color = vec4(r, g, b, 1.0);
	} else {
		color = texture(TEXTURE, uv);
	}

	// Vignette effect - darkness at edges
	vec2 center_dist = UV - vec2(0.5, 0.5);
	float vignette_amount = 1.0 - length(center_dist) * vignette;
	vignette_amount = clamp(vignette_amount, 0.0, 1.0);
	color.rgb *= vignette_amount;

	// Add visual noise at low sanity
	if (insanity > 0.3) {
		float noise_val = noise(UV * 100.0 + time_param);
		color.rgb += (noise_val - 0.5) * insanity * 0.1;
	}

	// Desaturation at low sanity
	float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	color.rgb = mix(color.rgb, vec3(gray), insanity * 0.5);

	// Subtle color shift based on sanity
	color.rgb += vec3(insanity * 0.1, 0.0, insanity * 0.2);

	COLOR = color;
}
