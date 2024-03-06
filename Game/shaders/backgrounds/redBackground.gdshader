shader_type canvas_item;

uniform vec4 color1 : source_color = vec4(1.0);
uniform vec4 color2 : source_color = vec4(1.0);
uniform vec4 color3 : source_color = vec4(1.0);
uniform vec4 color4 : source_color = vec4(1.0);

uniform sampler2D noise;

varying vec2 worldPosition;

vec2 rotate(vec2 uv, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	
	uv = uv * rotation;
	return uv;
}

// Box - exact   (https://www.youtube.com/watch?v=62-pRVZuS5c)
float sdEquilateralTriangle(in vec2 p, in float r)
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

float repBox(in vec2 p, in float halfLengths, in float space)
{
	vec2 relPos = mod(p+halfLengths*1.5, 3.0*halfLengths + space) - halfLengths*1.5;
	
	vec2 squareCenterCoords = p - relPos;
	float n = texture(noise, mod(abs(squareCenterCoords) / 20000.0, 1.0)).r;
	//float n = 0.0;
	//return n;
	return 1.0-max(sdEquilateralTriangle(rotate(relPos, 2.0*PI * n), halfLengths) / 5.0, 0.0);
	
	//return length(squareCenterCoords) - 100.0;
	//if (length(squareCenterCoords - p) < 100.0)
		//return 1.0;
	//else
		//return 0.0;
}

void vertex() {
	worldPosition = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}




void fragment() {
	//float v1 = repBox(worldPosition, vec2(100, 100));
	
	//float v1 = repBox(worldPosition, vec2(100, 100));
	
	//float v1 = repBox(0.5*worldPosition+vec2(0,0)+1000.0*texture(noise, UV).xy, vec2(100, 100));
	//float v2 = repBox(0.9*worldPosition+vec2(-980,500)+5000.0*texture(noise, UV).xy, vec2(100, 100));
	//float v3 = repBox(worldPosition+vec2(300,942)+10000.0*texture(noise, UV).xy, vec2(100, 100));

	float v1 = repBox(rotate(worldPosition, 3.14/6.0) +vec2(0,0), 100, 000.0);
	float v2 = repBox(rotate(worldPosition, -67.0 * 3.14/100.0) +vec2(-300,0), 100, 000.0);
	float v3 = repBox(rotate(worldPosition, 3.14/8.0) +vec2(0,0), 100, 0.0);
	float v4 = repBox(rotate(worldPosition, 64) +vec2(433,237), 100, 0.0);




	if (v1 > 0.0)
		COLOR = vec4(color1.rgb*vec3(v1), 1.0);
	else if (v2 > 0.0)
		COLOR = vec4(color2.rgb*vec3(v2), 1.0);
	else if (v3 > 0.0)
		COLOR = vec4(color3.rgb*vec3(v3), 1.0);
	else if (v4 > 0.0)
		COLOR = vec4(color4.rgb*vec3(v4), 1.0);
	else 
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);

	//COLOR = vec4(color1.rgb*vec3(v1) + color2.rgb*vec3(v2), 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
