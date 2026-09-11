"""Retiming of the original RIFT rigs; preserves gameplay impact times."""
import bpy
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
original=bpy.context.window.scene
try:
 for hero in ['warrior','mage']:
  with bpy.data.libraries.load(str(ROOT/'blender'/f'{hero}_fantasy.blend'),link=False) as (src,dst): dst.scenes=src.scenes
  scene=dst.scenes[0];bpy.context.window.scene=scene;scene.render.fps=30
  arm=next(o for o in scene.objects if o.type=='ARMATURE')
  for tr in arm.animation_data.nla_tracks:tr.mute=True
  arm.animation_data.action=None
  impact=.22 if hero=='warrior' else .14
  duration=.85 if hero=='warrior' else .9
  for t in [0,impact*.55,impact,impact+.09,.5,duration]:
   for b in arm.pose.bones:
    b.rotation_mode='XYZ';b.rotation_euler=(0,0,0);b.location=(0,0,0)
   if t==0 or t==duration: strength=0;twist=0
   elif t < impact: strength=-.35;twist=-.45
   elif t==impact:strength=1;twist=.38
   elif t < .5:strength=.88;twist=.28
   else:strength=.22;twist=.10
   arm.pose.bones['upper_arm_r'].rotation_euler.x=-strength*(1.05 if hero=='mage' else .75)
   arm.pose.bones['upper_arm_r'].rotation_euler.z=twist*(.3 if hero=='mage' else 1)
   arm.pose.bones['forearm_r'].rotation_euler.x=-max(0,strength)*.25
   arm.pose.bones['chest'].rotation_euler.y=twist*.22
   if hero=='mage':arm.pose.bones['upper_arm_l'].rotation_euler.x=-max(0,strength)*.22
   for b in arm.pose.bones:
    b.keyframe_insert('rotation_euler',frame=t*30,group=b.name)
    b.keyframe_insert('location',frame=t*30,group=b.name)
  action=arm.animation_data.action;action.name=hero+'_attack_refined';action.use_fake_user=True
  arm.animation_data.action=None
  track=next(tr for tr in arm.animation_data.nla_tracks if tr.name=='attack')
  for strip in list(track.strips):track.strips.remove(strip)
  strip=track.strips.new('attack',0,action);strip.action_frame_start=0;strip.action_frame_end=duration*30
  for tr in arm.animation_data.nla_tracks:tr.mute=False
  scene.frame_set(0)
  bpy.data.libraries.write(str(ROOT/'blender'/f'{hero}_combat.blend'),{scene})
  bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets'/f'{hero}_animated.glb'),export_format='GLB',use_active_scene=True,export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True)
finally:bpy.context.window.scene=original
print('ATTACK_TIMING_UPDATED')
