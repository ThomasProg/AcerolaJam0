shader_type canvas_item;

uniform sampler2D noise;

#include "includes/sdf.gdshaderinc"

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}


void fragment() {

	COLOR = COLOR * texture(noise, UV) * (-sdCircle(UV-vec2(0.5,0.5), 1));
}