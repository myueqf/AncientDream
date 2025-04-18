#version 120
uniform int fogMode;
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform float frameTimeCounter;
varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}
void main() {
    gl_FragData[0] = texture2D(texture, texcoord.st) * texture2D(lightmap, lmcoord.st) * color;
    if(fogMode == 9729)
        gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp((gl_Fog.end - gl_FogFragCoord) / (gl_Fog.end - gl_Fog.start), 0.0, 1.0));
    else if(fogMode == 2048)
        gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0.0, 1.0));
    float brightness = dot(gl_FragData[0].rgb, vec3(0.2126, 0.7152, 0.0722));
    vec2 screenPos = gl_FragCoord.xy;
    vec2 gridPos = floor(screenPos / 200.0); 
    float rand = random(gridPos + floor(frameTimeCounter / 5.0));
    if(brightness < 0.1 && rand > 0.99) {
        vec2 cellCenter = (floor(screenPos / 200.0) * 200.0) + 100.0;
        vec2 eyeOffset = screenPos - cellCenter;
        float leftEye = length(eyeOffset + vec2(8.0, 0.0));
        float rightEye = length(eyeOffset - vec2(80.0, 0.0));
        float eyeTime = mod(frameTimeCounter, 5.0);
        float eyeFade = 1.0 - (eyeTime / 5.0);
        if(leftEye < 3.0 || rightEye < 3.0) {
            gl_FragData[0].rgb = mix(gl_FragData[0].rgb, vec3(1.0), eyeFade * 0.8);
        }
    }
}