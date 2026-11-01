shader_type spatial;
render_mode cull_back, depth_draw_opaque;

// Original NEXUS wet road shader: macro puddles + dynamically changing roughness.
uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float uv_tile : hint_range(1.0, 64.0) = 16.0;
uniform float wetness : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 coord = UV * uv_tile;
    vec3 asphalt = texture(albedo_tex, coord).rgb;
    float waves = sin(coord.x * 0.21 + 1.37) * sin(coord.y * 0.16 - 0.87);
    float puddle = smoothstep(0.10, 0.72, waves * 0.5 + 0.5);
    float water = clamp(wetness * (0.36 + puddle * 0.64), 0.0, 1.0);
    ALBEDO = asphalt * mix(vec3(1.0), vec3(0.61, 0.66, 0.72), water);
    METALLIC = 0.0;
    ROUGHNESS = mix(0.88, 0.10, water);
    SPECULAR = mix(0.48, 0.72, water);
    NORMAL_MAP = texture(normal_tex, coord).rgb;
    NORMAL_MAP_DEPTH = mix(0.65, 0.16, water);
}
