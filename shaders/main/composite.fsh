#version 120
uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;
const mat3 VINTAGE_MATRIX = mat3(
    0.93, 0.05, 0.05,
    0.09, 0.89, 0.09,
    0.07, 0.07, 0.83
);
const float FADE_STRENGTH = 0.3;    
const vec3 FADE_COLOR = vec3(0.9, 0.8, 0.7);    
const float CONTRAST = 2.2;
const float BRIGHTNESS = 0.05;    
const float SATURATION = 1.2;    
const float EXPOSURE = 1.3;    
const float GAMMA = 1.0;    
const float HIGHLIGHT_RECOVERY = 0.2;    
const float SHADOW_STRENGTH = 0.7;    
const int SHADOW_SAMPLES = 4;    
const float SHADOW_SOFTNESS = 2.0;    
const float SHADOW_RADIUS = 8.0;    
const float FOG_STRENGTH = 0.8;        
const float FOG_CURVE = 2.0;           
const float FOG_BORDER_SIZE = 0.3;     
const vec3 FOG_COLOR = vec3(0.1, 0.1, 0.1); 
float calculateVignette(vec2 texcoord) {
    vec2 position = (texcoord - 0.5) * 2.0;
    float dist = length(position);
    float vignette = 1.0 - dist * FOG_BORDER_SIZE;
    vignette = pow(clamp(vignette, 0.0, 1.0), FOG_CURVE);
    return mix(1.0, vignette, FOG_STRENGTH);
}
float calculateShadow(vec2 texcoord) {
    float shadow = 0.0;
    vec2 pixelSize = 1.0 / vec2(viewWidth, viewHeight);
    for(int x = -SHADOW_SAMPLES; x <= SHADOW_SAMPLES; x++) {
        for(int y = -SHADOW_SAMPLES; y <= SHADOW_SAMPLES; y++) {
            vec2 offset = vec2(x, y) * pixelSize * SHADOW_RADIUS;
            vec3 color = texture2D(colortex0, texcoord + offset).rgb;
            float luminance = dot(color, vec3(0.2126, 0.7152, 0.0722));
            shadow += smoothstep(0.3, 0.7, luminance);
        }
    }
    shadow /= float((SHADOW_SAMPLES * 2 + 1) * (SHADOW_SAMPLES * 2 + 1));
    shadow = pow(shadow, SHADOW_SOFTNESS);
    return mix(1.0, shadow, SHADOW_STRENGTH);
}
vec3 adjustExposure(vec3 color) {
    vec3 exposed = color * EXPOSURE;
    vec3 highlights = exposed * (1.0 - HIGHLIGHT_RECOVERY * smoothstep(0.8, 1.0, exposed));
    return pow(highlights, vec3(1.0 / GAMMA));
}
vec3 adjustContrast(vec3 color) {
    vec3 contrasted = (color - 0.5) * CONTRAST + 0.5;
    contrasted += BRIGHTNESS;
    float luminance = dot(contrasted, vec3(0.2126, 0.7152, 0.0722));
    contrasted = mix(vec3(luminance), contrasted, SATURATION);
    return clamp(contrasted, 0.0, 1.0);
}
void main() {
    vec2 texcoord = gl_TexCoord[0].st;
    float shadow = calculateShadow(texcoord);
    float vignette = calculateVignette(texcoord);
    vec2 offset = vec2(5.0/1920.0, 0.0);
    vec3 color;
    color.r = texture2D(colortex0, texcoord - offset).r;
    color.g = texture2D(colortex0, texcoord).g;
    color.b = texture2D(colortex0, texcoord + offset).b;
    color *= shadow;
    color = mix(FOG_COLOR, color, vignette);
    color = adjustExposure(color);
    color = VINTAGE_MATRIX * color;
    color = mix(color, FADE_COLOR, FADE_STRENGTH);
    color = adjustContrast(color);
    color = clamp(color, 0.0, 1.0);
    gl_FragColor = vec4(color, 1.0);
}