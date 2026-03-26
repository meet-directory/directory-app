shader_type canvas_item;

uniform float line_width : hint_range(0.0, 1.0) = 0.15;
uniform float speed : hint_range(0.1, 10.0) = 1.0;
uniform float brightness : hint_range(0.0, 2.0) = 0.8;
uniform float softness : hint_range(0.001, 0.3) = 0.08;
uniform float pause_duration : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    float diag = UV.x + (1.0 - UV.y);

    // Total travel distance across the diagonal
    float travel = 2.0 + line_width * 2.0;

    // Cycle = time to cross + pause. During the pause the line is off-screen.
    float sweep_duration = travel / speed;
    float cycle = sweep_duration + pause_duration;

    float t = mod(TIME, cycle);

    // Map t to line position — only moves during sweep_duration, then stalls off-screen
    float line_pos = (t / sweep_duration) * travel - line_width;
    // Clamp so it parks off the far edge during the pause window
    line_pos = min(line_pos, travel);

    float dist = abs(diag - line_pos);
    float shine = smoothstep(line_width, line_width - softness, dist);
    shine *= tex.a;

    vec3 final_color = tex.rgb + vec3(shine * brightness);
    COLOR = vec4(final_color, tex.a);
}