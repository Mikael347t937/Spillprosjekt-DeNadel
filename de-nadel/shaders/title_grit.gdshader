shader_type canvas_item;
void fragment() {
	vec4 ink = COLOR;
	float n = fract(sin(dot(floor(FRAGCOORD.xy / 1.4), vec2(23.14, 61.7))) * 15731.7);
	ink.a *= n < 0.035 ? 0.22 : 1.0;
	COLOR = ink;
}
