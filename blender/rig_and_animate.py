"""Build original skeletal blockout animations. Run with Blender Python."""
import bpy, math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
BONES=[
 ('root',(0,0,0),(0,0,.25),None),
 ('pelvis',(0,0,.76),(0,0,1.04),'root'),
 ('chest',(0,0,1.04),(0,0,1.6),'pelvis'),
 ('head',(0,0,1.6),(0,0,2.0),'chest'),
]
for side,sign in [('r',1),('l',-1)]:
    BONES += [(f'upper_arm_{side}',(sign*.42,0,1.47),(sign*.58,0,1.10),'chest'),
              (f'forearm_{side}',(sign*.58,0,1.10),(sign*.58,-.04,.86),f'upper_arm_{side}'),
              (f'hand_{side}',(sign*.58,-.04,.86),(sign*.58,-.12,.76),f'forearm_{side}'),
              (f'thigh_{side}',(sign*.23,0,.76),(sign*.23,0,.42),'pelvis'),
              (f'shin_{side}',(sign*.23,0,.42),(sign*.23,0,.13),f'thigh_{side}'),
              (f'foot_{side}',(sign*.23,0,.13),(sign*.23,-.3,.13),f'shin_{side}')]
original=bpy.context.window.scene
try:
 for hero in ['warrior','mage']:
    scene=bpy.data.scenes.new('RIFT_animated_'+hero); scene.render.fps=30
    bpy.context.window.scene=scene
    with bpy.data.libraries.load(str(ROOT/'blender'/f'{hero}.blend'),link=False) as (src,dst):
        dst.objects=src.objects
    objects=[o for o in dst.objects if o and o.type=='MESH']
    for o in objects:
        scene.collection.objects.link(o)
        o.data=o.data.copy()
    arm_data=bpy.data.armatures.new(hero+'_skeleton')
    arm=bpy.data.objects.new('Rig',arm_data); scene.collection.objects.link(arm)
    bpy.context.view_layer.objects.active=arm; arm.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    for name,head,tail,parent in BONES:
        bone=arm_data.edit_bones.new(name); bone.head=head; bone.tail=tail
        if parent: bone.parent=arm_data.edit_bones[parent]
    bpy.ops.object.mode_set(mode='OBJECT')
    for o in objects:
        side='r' if o.location.x > 0 else 'l'; name=o.name.lower()
        bone='chest'
        if any(word in name for word in ['helmet','visor','crest','hood']): bone='head'
        elif 'shoulder' in name or 'pauldron' in name: bone='upper_arm_'+side
        elif name.startswith('arm'): bone='forearm_'+side
        elif name.startswith('leg'): bone='thigh_'+side
        elif name.startswith('boot'): bone='foot_'+side
        elif any(word in name for word in ['waist','robe']): bone='pelvis'
        group=o.vertex_groups.new(name=bone)
        group.add(list(range(len(o.data.vertices))),1.0,'REPLACE')
        # Blend the lower half of each leg to the shin, avoiding a rigid stick.
        if name.startswith('leg'):
            lower=o.vertex_groups.new(name='shin_'+side)
            for v in o.data.vertices:
                z=(o.matrix_world@v.co).z
                weight=max(0,min(1,(.50-z)/.16))
                group.add([v.index],1-weight,'REPLACE'); lower.add([v.index],weight,'REPLACE')
        mod=o.modifiers.new('Skeletal deformation','ARMATURE'); mod.object=arm
        o.parent=arm
    arm.animation_data_create()
    clips=[('idle',60),('forward',24),('backward',24),('left',24),('right',24),('attack',26 if hero=='warrior' else 27),('guard',30),('cast',24),('hit',12),('death',36)]
    for clip,last in clips:
        arm.animation_data.action=None
        for frame in range(last+1):
            phase=frame/last
            for b in arm.pose.bones:
                b.rotation_mode='XYZ'; b.rotation_euler=(0,0,0); b.location=(0,0,0)
            chest=arm.pose.bones['chest']
            if clip=='idle':
                chest.rotation_euler.x=math.sin(phase*math.tau)*.025
            elif clip in ['forward','backward','left','right']:
                stride=math.sin(phase*math.tau)
                for side,sign in [('r',1),('l',-1)]:
                    leg=arm.pose.bones['thigh_'+side]
                    leg.rotation_euler.x=stride*.5*sign*(-.65 if clip=='backward' else 1)
                    if clip in ['left','right']:
                        leg.rotation_euler.x*=.3; leg.rotation_euler.z=stride*.3*sign
                    arm.pose.bones['shin_'+side].rotation_euler.x=-max(0,-stride*sign)*.55
                    arm.pose.bones['upper_arm_'+side].rotation_euler.x=-stride*.18*sign
                arm.pose.bones['pelvis'].location.y=abs(stride)*.025
            elif clip=='attack':
                # The strongest sweep occurs at frame 7 (0.23 s), matching impact.
                if frame < 6: swing=-.65*frame/6
                elif frame < 9: swing=-.65+1.35*(frame-6)/3
                else: swing=.70*(1-(frame-9)/(last-9))
                chest.rotation_euler.y=swing*.28
                upper=arm.pose.bones['upper_arm_r']
                upper.rotation_euler.x=-.5 if hero=='warrior' else -.8*math.sin(phase*math.pi)
                upper.rotation_euler.z=swing
                arm.pose.bones['forearm_r'].rotation_euler.x=-.35
            elif clip=='guard':
                arm.pose.bones['upper_arm_l'].rotation_euler.x=-.95
                arm.pose.bones['forearm_l'].rotation_euler.x=-.6
                chest.rotation_euler.y=-.16
            elif clip=='cast':
                for side in ['r','l']:
                    arm.pose.bones['upper_arm_'+side].rotation_euler.x=-.9*math.sin(phase*math.pi)
            elif clip=='hit':
                chest.rotation_euler.x=-.12*math.sin(phase*math.pi)
            elif clip=='death':
                t=min(1,phase*1.5)
                arm.pose.bones['root'].rotation_euler.x=-1.4*t
                arm.pose.bones['root'].location.y=-.12*t
            for b in arm.pose.bones:
                b.keyframe_insert('rotation_euler',frame=frame,group=b.name)
                b.keyframe_insert('location',frame=frame,group=b.name)
        action=arm.animation_data.action; action.name=clip; action.use_fake_user=True
        track=arm.animation_data.nla_tracks.new(); track.name=clip
        strip=track.strips.new(clip,0,action); strip.action_frame_start=0; strip.action_frame_end=last
        track.mute=True
        arm.animation_data.action=None
    # NLA tracks are exported separately and do not play on top of one another.
    for track in arm.animation_data.nla_tracks: track.mute=False
    scene.frame_start=0; scene.frame_end=60; scene.frame_set(0)
    bpy.data.libraries.write(str(ROOT/'blender'/f'{hero}_animated.blend'),{scene})
    bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets'/f'{hero}_animated.glb'),export_format='GLB',use_active_scene=True,export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True)
finally:
    bpy.context.window.scene=original
print('SKELETAL_ASSETS_READY')
