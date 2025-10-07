#version 120
/* 像素化 */
uniform sampler2D gColor;
varying vec2 texCoord;
#define PIXEL 640 // [160 320 640 1280]

#if PIXEL == 160
const vec2 gridRes = vec2(160.0, 120.0);
#elif PIXEL == 320
const vec2 gridRes = vec2(320.0, 240.0);
#elif PIXEL == 640
const vec2 gridRes = vec2(640.0, 480.0);
#else PIXEL == 1280
const vec2 gridRes = vec2(1280.0, 960.0);
#endif

void main() {
    vec2 pixelCoord = floor(texCoord * gridRes) / gridRes;
    vec3 color = texture2D(gColor, pixelCoord).rgb;

    gl_FragData[0] = vec4(color, 1.0);
}