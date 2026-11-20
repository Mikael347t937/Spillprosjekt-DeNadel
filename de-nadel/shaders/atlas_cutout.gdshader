shader_type canvas_item;

// The supplied sheet has a flat grey backing. Keep the drawn object, not its cell.
void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	vec3 difference = abs(pixel.rgb - vec3(0.24, 0.233, 0.275));
	float distance_from_backing = max(difference.r, max(difference.g, difference.b));
	COLOR = vec4(pixel.rgb, pixel.a * step(0.045, distance_from_backing));
}
