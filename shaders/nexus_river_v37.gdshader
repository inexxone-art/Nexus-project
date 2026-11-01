shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;
uniform vec4 deep_color : source_color = vec4(0.055,0.20,0.22,1.0);
uniform vec4 whitewater_color : source_color = vec4(0.72,0.82,0.79,1.0);
uniform float current_speed : hint_range(0.1,6.0) = 2.1;
uniform float turbulence : hint_range(0.0,2.0) = 0.8;
uniform float rain_strength : hint_range(0.0,1.0) = 0.5;
varying vec3 world_coord;
void vertex(){
    VERTEX.y += sin(VERTEX.x*0.68+TIME*current_speed)*0.21*turbulence
        +cos(VERTEX.z*1.17-TIME*1.33)*0.12*turbulence;
    world_coord = (MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}
void fragment() {
    vec2 stream = vec2(world_coord.x*0.3-TIME*current_speed, world_coord.z*0.37+TIME*0.34);
    float upstream = sin(stream.x*3.4+cos(stream.y*2.3))*sin(stream.y*4.3-stream.x*0.75);
    float high_freq = sin(stream.x*14.2+sin(stream.y*3.8));
    float bank_foam = smoothstep(0.30,0.48,abs(UV.y-0.5));
    float splashes = smoothstep(0.68,0.92,0.5+0.39*upstream+0.20*high_freq);
    float foam = clamp(bank_foam*0.62+splashes*0.57,0.0,1.0);
    vec3 water = mix(deep_color.rgb,whitewater_color.rgb,foam);
    float rain_rings = sin(world_coord.x*12.0+TIME*17.0)*sin(world_coord.z*11.4-TIME*9.0);
    ALBEDO = water + 0.025*rain_strength*rain_rings;
    ROUGHNESS = mix(0.085,0.46,foam)+0.04*rain_strength;
    METALLIC = 0.0;
    SPECULAR = 0.68;
    NORMAL = normalize(vec3(-0.16*cos(stream.x*3.4),1.0,-0.19*sin(stream.y*4.3)));
}
