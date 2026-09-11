shader_type spatial;
render_mode diffuse_burley;
varying vec3 world_position;
void vertex(){world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise2(vec2 p){vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void fragment(){
 vec2 p=world_position.xz;
 float row=floor(p.y/1.55);
 vec2 tile=vec2(p.x/2.3+mod(row,2.0)*.5,p.y/1.55);
 vec2 cell=floor(tile);vec2 f=fract(tile);
 float edge=min(min(f.x,1.0-f.x),min(f.y,1.0-f.y));
 float aa=max(fwidth(edge)*.8,.003);
 float seam=smoothstep(.006-aa,.016+aa,edge);
 float variation=hash(cell);
 vec3 stone=mix(vec3(.21,.235,.215),vec3(.30,.325,.29),variation);
 stone*=.94+.10*noise2(p*3.2);
 float border=max(smoothstep(17.0,23.0,abs(p.x)),smoothstep(14.0,19.5,abs(p.y)));
 float moss=smoothstep(.4,.78,noise2(p*.55))*border*.55;
 stone=mix(stone,vec3(.13,.205,.11),moss);
 float ring=1.0-smoothstep(.04,.09,abs(length(p)-5.8));
 ALBEDO=mix(vec3(.12,.145,.12),stone,seam);
 ALBEDO=mix(ALBEDO,vec3(.38,.35,.235),ring*.5);
 ROUGHNESS=.93;
}
