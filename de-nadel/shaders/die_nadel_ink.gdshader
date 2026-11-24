shader_type canvas_item;

uniform vec4 ink_color : source_color = vec4(0.075, 0.065, 0.07, 1.0);
uniform vec4 red_color : source_color = vec4(0.72, 0.11, 0.12, 1.0);

varying vec4 node_tint;

void vertex() {
	node_tint = COLOR;
}

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float background = smoothstep(0.82, 0.98, min(source.r, min(source.g, source.b)));
	float red_ink = step(0.15, source.r - max(source.g, source.b));
	COLOR = vec4(mix(ink_color.rgb, red_color.rgb, red_ink), source.a * (1.0 - background)) * node_tint;
}
