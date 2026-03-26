shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform vec2 center = vec2(0.5, 0.5);
uniform bool smooth_edge = true;
uniform float edge_softness : hint_range(0.0, 0.1) = 0.005;

void fragment() {
    vec2 uv = UV;
    
    // Get the aspect ratio of the texture to keep the circle round
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    float aspect = tex_size.x / tex_size.y;
    
    // Adjust UV for aspect ratio
    vec2 uv_centered = uv - center;
    uv_centered.x *= aspect;
    
    float adjusted_radius = radius * aspect;
    float dist = length(uv_centered);
    
    vec4 tex_color = texture(TEXTURE, uv);
    
    if (smooth_edge) {
        float alpha = 1.0 - smoothstep(adjusted_radius - edge_softness, adjusted_radius + edge_softness, dist);
        COLOR = vec4(tex_color.rgb, tex_color.a * alpha);
    } else {
        if (dist > adjusted_radius) {
            discard;
        }
        COLOR = tex_color;
    }
}