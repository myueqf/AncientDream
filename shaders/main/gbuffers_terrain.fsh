#version 120 compatibility

varying vec2 texCoord;
varying vec2 lightCoord;
varying vec4 vertColor;
varying float vertDist;
varying vec3 viewNormal;

layout(location = 0) out vec4 fragColor;

uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform float ambientLight;
uniform float screenBrightness;
uniform int heldItemId;
uniform int heldItemId2;

vec3 getBlockLight(vec2 coord) {
	float light = pow(coord.x, 3.5);
	return light * vec3(1.0, 0.6, 0.5) * 0.8;
}

vec3 getHeldLight(float dist) {
	if (heldItemId == 1 || heldItemId2 == 1) {
		float attenuation = pow(max(0.0, (7.0 - dist)/7.0), 4.3);
		return attenuation * 2.5 * vec3(1.0, 0.9, 0.8);
	}
	return vec3(0.0);
}

void main() {
	vec4 tex = texture2D(gtexture, texCoord) * vertColor;
	if (tex.a < 0.1) discard;
	vec3 lightmapColor = texture2D(lightmap, lightCoord).rgb;

	if(lightCoord.y <= 0.95) {
		lightmapColor *= vec3(0.7) * (lightCoord.x + 0.7); // 保持横向光照渐变
	}

	vec3 blockLight = getBlockLight(lightCoord);
	vec3 heldLight = getHeldLight(vertDist);
	vec3 dynamicLight = blockLight + heldLight;
	vec3 ambientSystem = vec3(ambientLight) + screenBrightness * vec3(0.3);
	vec3 finalLight = lightmapColor + max(ambientSystem, dynamicLight);

	tex.rgb *= finalLight;
	fragColor = vec4(tex.rgb, tex.a);
}