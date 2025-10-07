#version 330 compatibility

uniform sampler2D gColor;
varying vec2 texCoord;
uniform int worldTime;

// 竖向格栅
#define CRT_GRID_WIDTH 160.0       // 密度
#define CRT_GRID_INTENSITY 0.35     // 强度
#define CRT_GRID_THICKNESS 1.0     // 相对厚度

// 横向扫描线
#define CRT_SCANLINE_RES 120.0     // 密度
#define CRT_SCANLINE_DECAY 0.1     // 变暗程度
#define CRT_SCANLINE_THICKNESS 1.0 // 的相对厚度
#define CRT_SCANLINE_SPEED 0.2     // 滚动速度

// 刷新光束
#define CRT_BEAM_HEIGHT 0.3        // 高度占屏幕比例
#define CRT_BEAM_FADE 2.8          // 底部向上渐变的柔和度
#define CRT_BEAM_SPEED 0.0004      // 滚动的速度 [0.0004 0.0008 0.001 0.002 0.01 0.1 0.2 0.5]
#define CRT_BEAM_INTENSITY 0.8     // 变暗强度

void main() {
    vec4 color = texture2D(gColor, texCoord);
    float col_val = texCoord.x * CRT_GRID_WIDTH;
    float col_fract = fract(col_val);
    float col_line_center = 1.0 - abs(col_fract - 0.5) * 2.0;
    float grid_smooth_transition = smoothstep(1.0 - CRT_GRID_THICKNESS, 1.0, col_line_center);
    float grid_effect = 1.0 - (grid_smooth_transition * CRT_GRID_INTENSITY);
    float row_val_fixed = texCoord.y * CRT_SCANLINE_RES + worldTime * CRT_SCANLINE_SPEED;
    float row_fract_fixed = fract(row_val_fixed);
    float row_line_center = abs(row_fract_fixed - 0.5) * 2.0;
    float scanline_smooth_transition = smoothstep(0.0, CRT_SCANLINE_THICKNESS, row_line_center);
    float scanline_effect = 1.0 - (scanline_smooth_transition * CRT_SCANLINE_DECAY);
    float beam_pos_y = fract(texCoord.y + worldTime * CRT_BEAM_SPEED);
    float norm_y = (beam_pos_y - (1.0 - CRT_BEAM_HEIGHT)) / CRT_BEAM_HEIGHT;
    float beam_clamp = clamp(norm_y, 0.0, 1.0);
    float fade_top = smoothstep(1.0 - CRT_BEAM_FADE, 1.0, beam_clamp);
    float fade_bottom = step(0.0, beam_clamp);
    float beam_decay = mix(1.0, 1.0 - CRT_BEAM_INTENSITY, 1.0 - fade_top);

    if (beam_pos_y > (1.0 - CRT_BEAM_HEIGHT)) {
        color.rgb *= beam_decay;
    }

    color.rgb *= scanline_effect;
    color.rgb *= grid_effect;
    gl_FragData[0] = color;
}