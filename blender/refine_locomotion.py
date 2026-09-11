"""Original directional running cycles and distinct ready stances."""
import bpy,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
original=bpy.context.window.scene
try:
 for hero in ['warrior','mage']:
  with bpy.data.libraries.load(str(ROOT/'blender'/f'{hero}_painted.blend'),link=False) as (src,dst):dst.scenes=src.scenes
  scene=dst.scenes[0];bpy.context.window.scene=scene;scene.render.fps=30
  arm=next(o for o in scene.objects if o.type=='ARMATURE')
  for name in ['idle','forward','backward','left','right']:
   for track in arm.animation_data.nla_tracks:track.mute=True
   arm.animation_data.action=None
   last=60 if name=='idle' else 18
   for frame in range(last+1):
    phase=frame/last;stride=math.sin(phase*math.tau)
    for b in arm.pose.bones:b.rotation_mode='XYZ';b.rotation_euler=(0,0,0);b.location=(0,0,0)
    arm.pose.bones['chest'].rotation_euler.x=.045 if hero=='warrior' else -.025
    arm.pose.bones['forearm_r'].rotation_euler.x=-.15 if hero=='warrior' else -.23
    if name=='idle':
     arm.pose.bones['chest'].rotation_euler.x+=math.sin(phase*math.tau)*.018
     arm.pose.bones['upper_arm_l'].rotation_euler.x=-.10 if hero=='warrior' else -.04
    else:
     for side,sign in [('r',1),('l',-1)]:
      leg=arm.pose.bones['thigh_'+side]
      leg.rotation_euler.x=stride*.88*sign*(-.7 if name=='backward' else 1)
      if name in ['left','right']:
       leg.rotation_euler.x*=.25
       leg.rotation_euler.z=stride*.5*sign*(1 if name=='left' else -1)
      arm.pose.bones['shin_'+side].rotation_euler.x=-max(0,-stride*sign)*.85
      arm.pose.bones['upper_arm_'+side].rotation_euler.x=-stride*.27*sign
     arm.pose.bones['pelvis'].location.y=abs(stride)*.045
     arm.pose.bones['chest'].rotation_euler.y=stride*.04
    for b in arm.pose.bones:
     b.keyframe_insert('rotation_euler',frame=frame,group=b.name)
     b.keyframe_insert('location',frame=frame,group=b.name)
   action=arm.animation_data.action;action.name=hero+'_'+name+'_refined';action.use_fake_user=True
   arm.animation_data.action=None
   track=next(tr for tr in arm.animation_data.nla_tracks if tr.name==name)
   for strip in list(track.strips):track.strips.remove(strip)
   strip=track.strips.new(name,0,action);strip.action_frame_start=0;strip.action_frame_end=last
  for track in arm.animation_data.nla_tracks:track.mute=False
  scene.frame_set(0)
  bpy.data.libraries.write(str(ROOT/'blender'/f'{hero}_final.blend'),{scene})
  bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets'/f'{hero}_animated.glb'),export_format='GLB',use_active_scene=True,export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_vertex_color='ACTIVE',export_all_vertex_colors=False)
finally:bpy.context.window.scene=original
print('LOCOMOTION_REFINED')
