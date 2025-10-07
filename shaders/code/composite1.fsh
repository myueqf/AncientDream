#version 120

varying vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex1;
uniform int heldItemId;
uniform int heldItemId2;
uniform float aspectRatio;
uniform float near;
uniform float far;
uniform float frameTimeCounter;

#define FLASHLIGHT_COLOR   vec3(1.0, 0.6, 0.3)  // 核心光颜色
#define EDGE_COLOR         vec3(0.8, 0.5, 0.3)  // 边缘光颜色
#define COLOR_INTENSITY    0.9                    // 整体强度[0.3 0.5 0.8 1.2 1.5 2.0]
#define COLOR_FALLOFF      0.5                    // 颜色过渡锐度[0.3 0.5 0.8 1.2 1.5 1.8 2.2 2.5 2.8 3.3]
#define MAX_DISTANCE       12.0                   // 最大照射距离 [5.0 8.0 11.0 12.0 14.0 18.0 22.0]
#define CORE_DISTANCE      8.0                    // 核心光有效距离
#define DEPTH_ATTEN        0.12                   // 深度衰减
#define EDGE_SHRINK        0.035                  // 光斑收缩
float linearizeDepthFast(float depth) {
    return (near * far) / (depth * (near - far) + far);
}
float rand(float n) {
    return fract(sin(n) * 43758.5453123);
}
void main() {
    vec3 color = texture2D(colortex0, texcoord).rgb;
    float depth = texture2D(depthtex1, texcoord).r;
    if(depth == 1.0) {
        gl_FragData[0] = vec4(color, 1.0);
        return;
    }

    depth = linearizeDepthFast(depth);
    vec3 normal = texture2D(colortex1, texcoord).rgb * 2.0 - 1.0;
    vec3 flashlight = vec3(0.0);

    if (heldItemId == 1 || heldItemId2 == 1) {
        float flashlightDepth = min(depth, MAX_DISTANCE);
        float screenDist = length((texcoord - 0.5) * vec2(max(aspectRatio, 1.0), max(1.0/aspectRatio, 1.0)));
        float adjustedDist = screenDist / (1.0 + flashlightDepth * EDGE_SHRINK);
        float base = clamp(1.0 - (adjustedDist / 0.4) * 10.0 + 5.0, 0.0, 1.0);
        base *= smoothstep(MAX_DISTANCE, CORE_DISTANCE, flashlightDepth);
        float intensity = -(cos(base * 1.1415) - 1.0) * 0.5;
        intensity = clamp(intensity + (0.4 - (adjustedDist / 1.0) * 3.0 + 0.9) * 0.7, 0.0, 1.0);
        intensity = clamp(intensity + (0.4 - (adjustedDist / 1.0) * 1.0 + 0.8) * 0.1, 0.0, 1.0);
        float colorMix = pow(intensity, COLOR_FALLOFF);
        vec3 mixedColor = mix(EDGE_COLOR, FLASHLIGHT_COLOR, colorMix);
        float depthAtten = pow(max(1.0 - flashlightDepth/MAX_DISTANCE, 0.0), 2.0);
        depthAtten *= clamp(1.0 - flashlightDepth * DEPTH_ATTEN, 0.0, 1.0);
        float normalAtten = sqrt(max(normal.z, 0.0)) * 0.5 + 0.5;
        flashlight = mixedColor * intensity * depthAtten * normalAtten * COLOR_INTENSITY;
        flashlight *= step(flashlightDepth, MAX_DISTANCE);
    }
    color = 1.0 - (1.0 - color) * (1.0 - flashlight);
    gl_FragData[0] = vec4(color, 1.0);
}
