shader_type canvas_item;
uniform float vignette_strength = 0.42;
void fragment() {
	vec4 original = texture(TEXTURE, UV);
	vec2 p = UV - vec2(0.5);
	float edge = smoothstep(0.15, 0.7, length(p * vec2(0.9, 1.0)));
	float grain = fract(sin(dot(floor(FRAGCOORD.xy), vec2(12.9898, 78.233))) * 43758.5453);
	vec3 tinted = original.rgb * mix(vec3(1.0), vec3(0.20, 0.22, 0.24), edge * vignette_strength);
	COLOR = vec4(tinted + (grain - 0.5) * 0.025, original.a);
}
