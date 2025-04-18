#version 120 compatibility

attribute vec3 mc_Entity;
attribute vec4 at_midBlock;

varying vec2 texCoord;
varying vec2 lightCoord;
varying vec4 vertColor;
varying float camVertDist;
varying float vertDist;
varying vec3 viewNormal;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform vec3 cameraPosition;
uniform vec3 eyePosition;

void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lightCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

	vertColor = gl_Color;
	vec4 viewSpacePos = gl_ModelViewMatrix * gl_Vertex;
	camVertDist = length(viewSpacePos.xyz);
	vertDist = camVertDist - length(eyePosition - cameraPosition);
	viewNormal = gl_NormalMatrix * gl_Normal;

	vec3 worldVertex = (gbufferModelViewInverse * viewSpacePos).xyz;
	gl_Position = gbufferProjection * gbufferModelView * vec4(worldVertex, 1.0);
}