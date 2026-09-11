shader_type spatial;
render_mode cull_disabled;
uniform float metalness : hint_range(0.0,1.0) = 0.0;
uniform float surface_roughness : hint_range(0.0,1.0) = .8;
vec3 linear_to_srgb(vec3 color){
 return mix(color*12.92,1.055*pow(max(color,vec3(0.0)),vec3(1.0/2.4))-.055,step(vec3(.0031308),color));
}
void fragment(){
 ALBEDO=OUTPUT_IS_SRGB ? linear_to_srgb(COLOR.rgb) : COLOR.rgb;
 METALLIC=metalness;
 ROUGHNESS=surface_roughness;
}
