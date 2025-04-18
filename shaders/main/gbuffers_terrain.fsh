#version 120 compatibility

// 输入变量
varying vec2 texCoord;      // 纹理坐标
varying vec2 lightCoord;    // 光照贴图坐标
varying vec4 vertColor;     // 顶点颜色
varying float vertDist;     // 到光源的距离
varying vec3 viewNormal;    // 视图空间法线

// 输出到GBuffer
layout(location = 0) out vec4 fragColor;

// Uniforms
uniform sampler2D gtexture;         // 基础纹理
uniform sampler2D lightmap;         // 光照贴图
uniform float ambientLight;         // 环境光强度
uniform float screenBrightness;     // 屏幕亮度
uniform int heldItemId;             // 主手持物品ID
uniform int heldItemId2;            // 副手持物品ID

// 方块光
vec3 getBlockLight(vec2 coord) {
	float light = pow(coord.x, 3.5);
	return light * vec3(1.0, 0.6, 0.5) * 0.7;
}

// 手持光
vec3 getHeldLight(float dist) {
	if (heldItemId == 1 || heldItemId2 == 1) {
		float attenuation = pow(max(0.0, (8.0 - dist)/8.0), 4.3);
		return attenuation * 2.5 * vec3(1.0, 0.9, 0.8);
	}
	return vec3(0.0);
}

void main() {
	// 基础纹理采样
	vec4 tex = texture2D(gtexture, texCoord) * vertColor;
	if (tex.a < 0.1) discard;

	// 光照贴图采样
	vec3 lightmapColor = texture2D(lightmap, lightCoord).rgb;

	// 非天空区域暗化处理（洞穴/室内）
	if(lightCoord.y <= 0.95) {
		lightmapColor *= vec3(0.7) * (lightCoord.x + 0.7); // 保持横向光照渐变
	}

	// 动态光源计算
	vec3 blockLight = getBlockLight(lightCoord);
	vec3 heldLight = getHeldLight(vertDist);
	vec3 dynamicLight = blockLight + heldLight;

	// 环境光系统（包含屏幕亮度补偿）
	vec3 ambientSystem = vec3(ambientLight) + screenBrightness * vec3(0.3);

	// 光照合成（动态光源与环境光取最大值）
	vec3 finalLight = lightmapColor + max(ambientSystem, dynamicLight);

	// 最终颜色输出
	tex.rgb *= finalLight;
	fragColor = vec4(tex.rgb, tex.a);
}