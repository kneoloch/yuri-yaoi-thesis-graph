shader_type spatial;

uniform vec4 pos_n: source_color;
uniform vec4 neg_n: source_color;

void fragment() {
	ALBEDO = mix(pos_n.rgb, neg_n.rgb, UV.y);
	ALPHA = mix(pos_n.a, neg_n.a, UV.y);
}