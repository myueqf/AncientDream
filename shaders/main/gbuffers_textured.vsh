#version 120 compatibility

// 输出变量
varying vec2 texCoord;
varying vec2 lightCoord;
varying vec4 vertColor;

// Uniform矩阵
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;

void main() {
    // 纹理坐标转换
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    // 顶点属性处理
    vertColor = gl_Color;
    vec4 viewSpacePos = gl_ModelViewMatrix * gl_Vertex;

    // 空间坐标转换
    vec3 worldVertex = (gbufferModelViewInverse * viewSpacePos).xyz;
    gl_Position = gbufferProjection * gbufferModelView * vec4(worldVertex, 1.0);
}
