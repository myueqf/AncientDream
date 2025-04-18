#version 120 compatibility

// 输入属性（正确使用内置变量）
attribute vec3 mc_Entity;     // 仅保留实际需要的自定义属性
attribute vec4 at_midBlock;

// 输出变量
varying vec2 texCoord;
varying vec2 lightCoord;
varying vec4 vertColor;
varying float camVertDist;
varying float vertDist;
varying vec3 viewNormal;

// Uniform矩阵
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform vec3 cameraPosition;
uniform vec3 eyePosition;

void main() {
	// 直接使用内置纹理坐标（无需声明）
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lightCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

	// 顶点处理管线
	vertColor = gl_Color;
	vec4 viewSpacePos = gl_ModelViewMatrix * gl_Vertex;
	camVertDist = length(viewSpacePos.xyz);
	vertDist = camVertDist - length(eyePosition - cameraPosition);
	viewNormal = gl_NormalMatrix * gl_Normal;

	// 世界坐标转换（兼容性写法）
	vec3 worldVertex = (gbufferModelViewInverse * viewSpacePos).xyz;
	gl_Position = gbufferProjection * gbufferModelView * vec4(worldVertex, 1.0);
}