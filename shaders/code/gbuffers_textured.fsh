#version 120 compatibility

varying vec2 texCoord;
varying vec2 lightCoord;
varying vec4 vertColor;

layout(location = 0) out vec4 fragColor;

uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform float ambientLight;
uniform float screenBrightness;

vec3 getBlockLight(vec2 coord) {
    float light = pow(coord.x, 3.3);
    return light * vec3(1.0, 0.5, 0.3) * 2.2;
}

void main() {
    vec4 tex = texture2D(gtexture, texCoord) * vertColor;
    if (tex.a < 0.1) discard;
    vec3 lightmapColor = texture2D(lightmap, lightCoord).rgb;
    vec3 blockLight = getBlockLight(lightCoord);
    vec3 ambientSystem = vec3(ambientLight) + screenBrightness * vec3(0.3);
    vec3 finalLight = lightmapColor + max(ambientSystem, blockLight);
    tex.rgb *= finalLight;
    fragColor = vec4(tex.rgb, tex.a);
}
