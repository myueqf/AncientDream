#version 330 compatibility

uniform sampler2D gColor;
#define XwX 0.002 // 色差强度
#define QAQ 1
varying vec2 texCoord;

void main() {
#if QAQ == 1
    vec2 offset = vec2(XwX, 0.0);
    float r = texture2D(gColor, texCoord + offset).r;
    float g = texture2D(gColor, texCoord).g;
    float b = texture2D(gColor, texCoord - offset).b;
    gl_FragData[0] = vec4(r, g, b, 1.0);
#endif
}