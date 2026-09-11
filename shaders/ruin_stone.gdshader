shader_type spatial;
varying vec3 world_position;
varying vec3 world_normal;
void vertex(){world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;world_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec2 p=abs(world_normal.x)>.5 ? world_position.zy : world_position.xy;
 if(abs(world_normal.y)>.5){p=world_position.xz;}
 vec2 tile=vec2(p.x/1.15+mod(floor(p.y/.48),2.0)*.5,p.y/.48);
 vec2 f=fract(tile);float edge=min(min(f.x,1.0-f.x),min(f.y,1.0-f.y));
 float aa=max(fwidth(edge)*.6,.004);float mortar=smoothstep(.006-aa,.016+aa,edge);
 vec3 stone=mix(vec3(.22,.28,.265),vec3(.30,.35,.315),hash(floor(tile)));
 float moss=(1.0-smoothstep(.0,.65,world_position.y))*.3;
 stone=mix(stone,vec3(.14,.23,.12),moss);
 ALBEDO=mix(stone*.62,stone,mortar);
 ROUGHNESS=.95;
}
