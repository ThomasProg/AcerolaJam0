shader_type canvas_item;

uniform vec2 u_resolution = vec2(500, 500);
uniform float u_speed = 20;
uniform vec4 u_color : source_color;
uniform sampler3D u_mask: repeat_enable;
uniform float amount = 1.0;
uniform float minColorMult = 0.2;

float getAnimTime() {
	return TIME * u_speed;
}

varying vec2 worldPosition;

void vertex() {
	worldPosition = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	vec2 pointToCenter = center - UV;
	float pointToCenterLength = length(pointToCenter) * 2.0;
	
	float angle = acos(dot(normalize(pointToCenter), vec2(1,0)));
	
	if (pointToCenter.y < 0.0)
		angle = 2.0 * PI - angle;

	//vec4 texColor = texture(TEXTURE, UV);
	float f = 1.f;
	//vec4 noiseColor = texture(u_mask, vec3(getAnimTime(), UV.x/2.0, UV.y));//+ modf(getAnimTime(), f));
	vec4 noiseColor = texture(u_mask, vec3(UV.x + getAnimTime(), UV.y, 0.0));
	
	float noise = amount * noiseColor.r; //texture(offset_texture, UV).r / 100.0;
	vec2 newPoint = center + (pointToCenterLength - noise) * vec2(cos(angle), sin(angle));
	//vec2 newPointBlue = center + (pointToCenterLength - noise) * vec2(cos(angle-noise), sin(angle-noise));
	
	//COLOR = texture(TEXTURE, newPoint);
	
	float boxsdf = -sdBox(5.0*(UV - vec2(0.5, 0.5)), vec2(1.0,1.0)) + 0.8;
		
	COLOR = 2.0 * boxsdf * texture(TEXTURE, UV) * texture(u_mask, vec3(UV.x/2.0 + getAnimTime(), UV.y/2.0, 0.0));
	
	//COLOR = texture(u_mask, vec3(UV / 2.0, 0.0));
	
	//COLOR = noiseColor;

	//COLOR = vec4((f*f*f+.6*f*f+.5*f)*texColor);
	
	//COLOR = u_color;
	//COLOR = vec4(0.0);


	//COLOR = 2.0 * mask + 1.0 - vec4((f*f*f+.6*f*f+.5*f)*color) - minColorMult;
}
