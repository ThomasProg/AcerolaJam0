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
	
	vec4 baseColor = glow * COLOR * texture(u_mask, vec2(UV.x/2.0 + getAnimTime(), UV.y/2.0));
	
	float gradientYMin = 0.75;
	float gradientYMax = 0.9;
	if (UV.y < gradientYMin)
		COLOR = baseColor;
	else
	{
		//float a = (UV.y-gradientYMin)/(gradientYMax - gradientYMin);
		////COLOR = u_color * (glow*baseColor.a);
		//COLOR = mix(glow*baseColor, glow*glow*baseColor.a * u_color, a*a);

		//if (baseColor.a > 0.0)
			//COLOR = baseColor;
		//else
			//COLOR = u_color; 
			
		COLOR = mix(u_color, baseColor, clamp(baseColor.a, 0.0, 1.0));
	}
	
	
	

	//COLOR = glow * baseColor;

	//COLOR = vec4(((UV.y-0.5)*2.0));
}
