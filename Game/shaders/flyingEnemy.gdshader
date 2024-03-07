shader_type canvas_item;

uniform vec2 u_resolution = vec2(500, 500);
uniform float u_speed = 20;
uniform vec4 u_color : source_color;
uniform sampler2D u_mask: repeat_enable;
uniform float amount = 1.0;
uniform float minColorMult = 0.2;
uniform float glow = 2.0;

float getAnimTime() {
	return TIME * u_speed;
}

varying vec2 worldPosition;

void vertex() {
	worldPosition = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	//vec2 center = vec2(0.5, 0.5);
	//vec2 pointToCenter = center - UV;
	//float pointToCenterLength = length(pointToCenter) * 2.0;
	//
	//float angle = acos(dot(normalize(pointToCenter), vec2(1,0)));
	//
	//if (pointToCenter.y < 0.0)
		//angle = 2.0 * PI - angle;

	//vec4 noiseColor = texture(u_mask, vec3(UV.x + getAnimTime(), UV.y, 0.0));
	
	//float noise = amount * noiseColor.r; //texture(offset_texture, UV).r / 100.0;
	//vec2 newPoint = center + (pointToCenterLength - noise) * vec2(cos(angle), sin(angle));
	
	COLOR = glow * COLOR * texture(u_mask, vec2(UV.x/2.0 + getAnimTime(), UV.y/2.0));
}
