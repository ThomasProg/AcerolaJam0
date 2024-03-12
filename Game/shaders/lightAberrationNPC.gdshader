shader_type canvas_item;

uniform sampler2D noise;

#include "includes/sdf.gdshaderinc"

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float v = clamp(-5.0 * sdBox(UV-vec2(0.5), vec2(0.5, 0.5)), 0.0, 1.0);
	COLOR = COLOR * vec4(v) * texture(noise, UV);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
