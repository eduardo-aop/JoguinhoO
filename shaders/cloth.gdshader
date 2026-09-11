shader_type spatial;
render_mode cull_disabled;
uniform float motion_strength : hint_range(0.0,1.0) = 0.0;
uniform vec4 team_tint : source_color = vec4(1.0);
uniform float team_strength : hint_range(0.0,1.0) = 0.0;
void vertex(){
 float loose=1.0-smoothstep(.5,1.58,VERTEX.y);
 float back=smoothstep(.20,.32,VERTEX.z);
 float wave=sin(TIME*4.3+VERTEX.y*3.5+VERTEX.x*2.0);
 VERTEX.z+=wave*loose*back*(.008+motion_strength*.05);
 VERTEX.x+=sin(TIME*3.2+VERTEX.y*2.0)*loose*back*motion_strength*.018;
}
vec3 linear_to_srgb(vec3 color){
 return mix(color*12.92,1.055*pow(max(color,vec3(0.0)),vec3(1.0/2.4))-.055,step(vec3(.0031308),color));
}
void fragment(){
 vec3 original=OUTPUT_IS_SRGB ? linear_to_srgb(COLOR.rgb) : COLOR.rgb;
 float shading=clamp(max(original.r,max(original.g,original.b))*1.7,.25,.95);
 ALBEDO=mix(original,team_tint.rgb*shading,team_strength);
 ROUGHNESS=.86;
}
