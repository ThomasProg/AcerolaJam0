shader_type canvas_item;

#include "includes/sdf.gdshaderinc"

uniform vec2 u_resolution = vec2(500, 500);
uniform float u_speed = 20;
//uniform sampler3D u_mask: repeat_enable;
uniform sampler2D u_mask: repeat_enable;
uniform float amount = 1.0;
uniform float minColorMult = 0.2;

float getAnimTime() {
	return TIME * u_speed;
}

varying vec2 worldPosition;
varying flat mat4 modelMatrix;

void vertex() {
	worldPosition = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	modelMatrix = MODEL_MATRIX;
}

void fragment() {
	float noise2 = texture(u_mask, vec2(worldPosition.x/2000.0 + getAnimTime() / 100.0, worldPosition.y/2000.0)).r-(1.0-amount);
	//float noise2 = texture(u_mask, vec3(worldPosition.xy/1000.0, getAnimTime() / 100.0)).r-(1.0-amount);
	COLOR = COLOR * vec4(vec3(1.0), noise2);
}
