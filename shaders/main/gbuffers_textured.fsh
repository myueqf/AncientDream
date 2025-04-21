#version 120 compatibility

// 输入变量
varying vec2 texCoord;      // 纹理坐标
varying vec2 lightCoord;    // 光照贴图坐标
varying vec4 vertColor;     // 顶点颜色

// 输出到GBuffer
layout(location = 0) out vec4 fragColor;

// Uniforms
uniform sampler2D gtexture;         // 基础纹理
uniform sampler2D lightmap;         // 光照贴图
uniform float ambientLight;         // 环境光强度
uniform float screenBrightness;     // 屏幕亮度

// 方块光照计算函数
vec3 getBlockLight(vec2 coord) {
    float light = pow(coord.x, 3.3); // 光照强度曲线
    return light * vec3(1.0, 0.5, 0.3) * 2.2; // 暖色光输出
}

void main() {
    // 基础纹理采样
    vec4 tex = texture2D(gtexture, texCoord) * vertColor;
    if (tex.a < 0.1) discard;

    // 光照贴图采样
    vec3 lightmapColor = texture2D(lightmap, lightCoord).rgb;

    // 动态方块光照计算
    vec3 blockLight = getBlockLight(lightCoord);

    // 环境光系统
    vec3 ambientSystem = vec3(ambientLight) + screenBrightness * vec3(0.3);

    // 光照合成（动态光源与环境光取最大值）
    vec3 finalLight = lightmapColor + max(ambientSystem, blockLight);

    // 最终颜色输出
    tex.rgb *= finalLight;
    fragColor = vec4(tex.rgb, tex.a);
}
