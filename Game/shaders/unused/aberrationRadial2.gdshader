shader_type canvas_item;

uniform bool apply = true;
uniform float amount = 1.0;
uniform sampler2D offset_texture;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}


void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec4 color = texture_color;
	
	if (apply == true) {
		float uvx = UV.x;
		float uvy = UV.y;

		vec2 center = vec2(0.5, 0.5);
		vec2 pointToCenter = center - UV;
		
		float angle = acos(dot(normalize(pointToCenter), vec2(1,0)));
		
		if (pointToCenter.y < 0.0)
			angle = 2.0 * PI - angle;
		
		float noise = amount * texture(offset_texture, UV).r / 100.0;
		vec2 newPointRed = center + vec2(length(pointToCenter) * cos(angle+noise), length(pointToCenter) * sin(angle+0.1));
		vec2 newPointBlue = center + vec2(length(pointToCenter) * cos(angle-noise), length(pointToCenter) * sin(angle+0.1));

		//color.g = 0.0;
		//color.b = 0.0;
		//color.r = angle / 3.1415 / 2.0;


		//color.a = texture(TEXTURE, newPointRed).a;
		color.r = texture(TEXTURE, newPointRed).r;
		color.g = texture(TEXTURE, UV).g;
		color.b = texture(TEXTURE, newPointBlue).b; //texture(TEXTURE, vec2(angle - adjusted_amount, angle)).b;
	}
	COLOR = color;
}