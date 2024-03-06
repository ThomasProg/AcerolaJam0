shader_type canvas_item;

#include "res://shaders/includes/sdf.gdshaderinc"

uniform float u_speed = 20;

uniform sampler2D u_mask: repeat_enable;

uniform float size = 100.0;
uniform float glow = 2.0;
uniform float triangleShape = 250.0;

const vec2 center = vec2(0.5);

float getAnimTime() {
	return TIME * u_speed;
}

varying vec2 worldPosition;

void vertex() {
	worldPosition = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float boxsdf = min(-sdEquilateralTriangle(triangleShape*(UV-center), size),2.0);
		
	COLOR = glow * boxsdf * COLOR * texture(u_mask, vec2(UV.x/2.0 + getAnimTime(), UV.y/2.0));
}
