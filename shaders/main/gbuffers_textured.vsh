#version 120 compatibility

varying vec2 texCoord;
varying vec2 lightCoord;
varying vec4 vertColor;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vertColor = gl_Color;
    vec4 viewSpacePos = gl_ModelViewMatrix * gl_Vertex;
    vec3 worldVertex = (gbufferModelViewInverse * viewSpacePos).xyz;
    gl_Position = gbufferProjection * gbufferModelView * vec4(worldVertex, 1.0);
}
