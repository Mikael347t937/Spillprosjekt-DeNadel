shader_type canvas_item;

void fragment() {
    vec4 ink = texture(TEXTURE, UV);
    float brightest = max(ink.r, max(ink.g, ink.b));
    bool red_ink = ink.r > ink.g * 1.5 && ink.r > ink.b * 1.5;
    bool dark_outline = brightest < 0.16;
    bool yellow_mark = ink.r > 0.6 && ink.g > 0.6 && ink.b < 0.35;
    if (red_ink) {
        COLOR = vec4(0.72, 0.15, 0.12, ink.a);
    } else if (dark_outline) {
        COLOR = vec4(0.75, 0.69, 0.60, ink.a * 0.9);
    } else if (yellow_mark) {
        COLOR = ink;
    } else {
        COLOR = vec4(0.0);
    }
}
