shader_type spatial;
render_mode cull_back;

// High-density physically based terrain blending: rock on slopes / banks,
// forest soil and grass on flats, macro color break-up, rain-darkened stone.
// Uses actual licensed PBR surfaces already in assets/production/materials.
uniform sampler2D rock_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D asphalt_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float detail_tiling : hint_range(0.03,1.0) = 0.19;
uniform float rainfall : hint_range(0.0,1.0) = 0.0;
uniform float rock_transition : hint_range(0.0,1.0) = 0.31;
varying vec3 world_point;
varying vec3 world_normal;

void vertex() {
    world_point = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

vec3 triplanar_blend(vec3 n) {
    vec3 w = pow(abs(n), vec3(4.5));
    return w / max(dot(w,vec3(1.0)),0.0001);
}

vec3 tri_color(sampler2D texture_map, vec3 p, vec3 weights) {
    vec3 x = texture(texture_map,p.zy).rgb;
    vec3 y = texture(texture_map,p.xz).rgb;
    vec3 z = texture(texture_map,p.xy).rgb;
    return x*weights.x + y*weights.y + z*weights.z;
}

float tri_channel(sampler2D texture_map, vec3 p, vec3 weights) {
    return dot(vec3(texture(texture_map,p.zy).r,
                    texture(texture_map,p.xz).r,
                    texture(texture_map,p.xy).r),weights);
}

void fragment() {
    vec3 weights = triplanar_blend(world_normal);
    vec3 coord = world_point*detail_tiling;
    vec3 stone = tri_color(rock_albedo,coord,weights);
    vec3 grass = tri_color(grass_albedo,coord,weights);
    float slope = 1.0-abs(world_normal.y);
    float fractured = sin(world_point.x*0.11 + world_point.z*0.065)
                    * sin(world_point.z*0.08-world_point.x*0.032);
    float rock_amount = smoothstep(rock_transition-0.18,rock_transition+0.25,
                                   slope + (world_point.y < -8.0 ? 0.52 : 0.0) + fractured*0.1);
    vec3 base = mix(grass,stone,rock_amount);
    float wet = rainfall*0.47 + (1.0-smoothstep(-36.0,-24.0,world_point.y))*0.38;
    vec3 map_tint = mix(vec3(1.0),COLOR.rgb,0.48);
    float blotch = 0.88+0.10*sin(world_point.x*0.038+world_point.z*0.064)
                  +0.07*cos(world_point.z*0.092-world_point.x*0.043);
    ALBEDO = clamp(base*map_tint*blotch*(1.0-0.32*wet),vec3(0.0),vec3(1.0));
    float stone_roughness = tri_channel(rock_roughness,coord,weights);
    float grass_rough_sample = tri_channel(grass_roughness,coord,weights);
    ROUGHNESS = clamp(mix(grass_rough_sample,stone_roughness,rock_amount)*(1.0-0.30*wet),0.17,1.0);
    METALLIC = 0.0;
    SPECULAR = 0.5;
}
