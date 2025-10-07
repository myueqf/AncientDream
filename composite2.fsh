#version 120
uniform sampler2D screenTexture;
uniform float time;
const float scanlineIntensity = 0.015;    
const float scanlineCount = 400.0;        
const float vignetteStrength = 0.25;      
const float distortionStrength = 0.330;   
float scanline(vec2 uv) {
    return sin(uv.y * scanlineCount) * scanlineIntensity;
}
float vignette(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    return clamp(1.0 - dot(uv, uv) * vignetteStrength, 0.0, 1.0);
}
void main() {
    vec2 texCoord = gl_TexCoord[0].st;
    vec2 distortedUV = texCoord;
    distortedUV -= vec2(0.5);
    float distortFactor = dot(distortedUV, distortedUV) * distortionStrength;
    distortedUV *= 1.0 + distortFactor;
    distortedUV += vec2(0.5);
    vec3 color = texture2D(screenTexture, distortedUV).rgb;
    float scan = scanline(distortedUV);
    color += vec3(scan);
    float vig = vignette(texCoord);
    color *= vig;
    float flicker = 1.0 + 0.015 * sin(time * 10.0);
    color *= flicker;
    color = clamp(color, 0.0, 1.0);
    gl_FragColor = vec4(color, 1.0);
}