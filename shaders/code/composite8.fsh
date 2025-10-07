#version 330 compatibility

uniform sampler2D gColor;
varying vec2 texCoord;

// 桶形失真
#define CRT_BARREL_POWER 0.15  // 强度
#define CRT_ZOOM_FACTOR 1.13   // 消除黑边（画面放大XwX）

// 晕影
#define CRT_VIGNETTE_START 0.8 // 开始的距离
#define CRT_VIGNETTE_END 1.5   // 结束的距离
#define CRT_VIGNETTE_INTENSITY 0.98 // 强度

void main() {
    vec2 pos = texCoord * 2.0 - 1.0;
    float dist = length(pos);
    float correction = 1.0 + (dist * dist) * CRT_BARREL_POWER;
    vec2 warpedPos = pos * correction;

    warpedPos /= CRT_ZOOM_FACTOR;

    vec2 warpedUV = warpedPos * 0.5 + 0.5;
    float vignette = 1.0;
    vec2 vignettePos = warpedUV * 2.0 - 1.0;
    float vignetteDist = length(vignettePos);

    if (vignetteDist > CRT_VIGNETTE_START) {
        vignette = 1.0 - smoothstep(CRT_VIGNETTE_START, CRT_VIGNETTE_END, vignetteDist) * CRT_VIGNETTE_INTENSITY;
    }

    if (warpedUV.x < 0.0 || warpedUV.x > 1.0 ||
    warpedUV.y < 0.0 || warpedUV.y > 1.0)
    {
        gl_FragData[0] = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        vec3 color = texture2D(gColor, warpedUV).rgb;
        color *= vignette;
        gl_FragData[0] = vec4(color, 1.0);
    }
}