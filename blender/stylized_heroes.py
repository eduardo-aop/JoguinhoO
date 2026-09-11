"""Original stylized fantasy armor over the existing RIFT animation rigs."""
import bpy, math
from mathutils import Vector
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
original=bpy.context.window.scene

def material(name,color,metal=0):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=.48 if metal else .8
 return m

def skin(o,bone,mat):
 o.data.materials.append(mat)
 bpy.context.view_layer.objects.active=o;o.select_set(True)
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 o.vertex_groups.new(name=bone).add(list(range(len(o.data.vertices))),1,'REPLACE')
 mod=o.modifiers.new('Rig deformation','ARMATURE');mod.object=arm;o.parent=arm
 o.select_set(False)
 return o

def rings(name,levels,bone,mat,n=10):
 verts=[]
 for z,rx,ry,cx,cy in levels:
  for j in range(n):
   a=math.tau*j/n;verts.append((cx+rx*math.cos(a),cy+ry*math.sin(a),z))
 faces=[tuple(reversed(range(n)))]
 for i in range(len(levels)-1):
  for j in range(n):faces.append((i*n+j,i*n+(j+1)%n,(i+1)*n+(j+1)%n,(i+1)*n+j))
 faces.append(tuple((len(levels)-1)*n+j for j in range(n)))
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update()
 o=bpy.data.objects.new(name,mesh);scene.collection.objects.link(o);return skin(o,bone,mat)

def orb(name,pos,scale,bone,mat):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=6,location=pos)
 o=bpy.context.object;o.name=name;o.scale=scale;return skin(o,bone,mat)

def blade(name,points,width,bone,mat):
 levels=[(p[2],width*(1-i/(len(points)-.1)),width*.65*(1-i/(len(points)-.1)),p[0],p[1]) for i,p in enumerate(points)]
 return rings(name,levels,bone,mat,6)

try:
 for hero in ['warrior','mage']:
  with bpy.data.libraries.load(str(ROOT/'blender'/f'{hero}_animated.blend'),link=False) as (src,dst):dst.scenes=src.scenes
  scene=dst.scenes[0];scene.name='RIFT_Fantasy_'+hero;bpy.context.window.scene=scene
  arm=next(o for o in scene.objects if o.type=='ARMATURE')
  for o in list(scene.objects):
   if o.type=='MESH':bpy.data.objects.remove(o,do_unlink=True)
  for o in scene.objects:o.select_set(False)
  for tr in arm.animation_data.nla_tracks:tr.mute=True
  for b in arm.pose.bones:b.rotation_euler=(0,0,0);b.location=(0,0,0)
  steel=material(hero+' enamel',(.075,.20,.24) if hero=='warrior' else (.16,.065,.29),.35)
  light=material(hero+' edge',(.23,.43,.45) if hero=='warrior' else (.38,.20,.52),.25)
  gold=material(hero+' antique gold',(.68,.42,.12),.7)
  dark=material(hero+' leather',(.045,.065,.08))
  cloth=material(hero+' cloth',(.30,.045,.055) if hero=='warrior' else (.055,.12,.22))
  gem=material(hero+' crystal',(.18,.82,.75) if hero=='warrior' else (.30,.62,1),.2)
  face=material(hero+' face',(.48,.30,.19))
  rings('Breastplate',[(.94,.28,.19,0,0),(1.12,.34,.24,0,0),(1.44,.47,.27,0,0),(1.61,.34,.20,0,0)],'chest',steel)
  rings('Golden gorget',[(1.55,.35,.22,0,0),(1.64,.34,.20,0,0),(1.68,.21,.17,0,0)],'chest',gold)
  rings('Belt',[(.88,.32,.23,0,0),(.98,.34,.24,0,0)],'pelvis',gold)
  orb('Heart sigil',(0,-.265,1.37),(.12,.055,.16),'chest',gem)
  orb('Face',(0,-.01,1.82),(.20,.19,.24),'head',face)
  if hero=='warrior':
   rings('Crowned helm',[(1.77,.24,.22,0,.015),(1.96,.26,.235,0,.015),(2.08,.17,.18,0,.015),(2.14,.04,.09,0,.015)],'head',steel)
   rings('Visor',[(1.80,.205,.025,0,-.195),(1.87,.205,.025,0,-.22)],'head',dark,8)
   for sign in [-1,1]:
    orb('Eye slit',(sign*.095,-.244,1.845),(.07,.025,.019),'head',gem)
    blade('Crown prong',[(sign*.19,.015,1.98),(sign*.32,.025,2.18),(sign*.26,.02,2.37)],.09,'head',gold)
  else:
   rings('Sorcerer hood',[(1.64,.28,.24,0,.09),(1.94,.28,.24,0,.08),(2.15,.20,.18,0,.08),(2.37,.025,.035,0,.04)],'head',steel)
   orb('Hood shadow',(0,-.165,1.83),(.18,.09,.20),'head',dark)
   for sign in [-1,1]:orb('Arcane eye',(sign*.065,-.258,1.88),(.035,.012,.022),'head',gem)
   blade('Diadem',[(0,-.15,2.04),(0,-.17,2.23),(0,-.15,2.43)],.105,'head',gold)
  for side,sign in [('r',1),('l',-1)]:
   x=sign*.23
   rings('Trouser '+side,[(.37,.145,.16,x,0),(.75,.175,.19,x,0),(.88,.18,.19,x,0)],'thigh_'+side,dark)
   rings('Greave '+side,[(.16,.15,.17,x,0),(.40,.18,.185,x,0),(.51,.16,.18,x,-.015)],'shin_'+side,steel)
   orb('Kneecap '+side,(x,-.16,.47),(.155,.065,.14),'shin_'+side,gold)
   rings('Sabatons '+side,[(.045,.17,.29,x,-.09),(.13,.18,.30,x,-.09),(.24,.145,.18,x,-.025)],'foot_'+side,dark)
   rings('Toe armor '+side,[(.07,.17,.13,x,-.27),(.15,.17,.13,x,-.27),(.19,.12,.09,x,-.24)],'foot_'+side,steel)
   orb('Upper sleeve '+side,(sign*.48,0,1.3),(.18,.19,.27),'upper_arm_'+side,dark)
   rings('Gauntlet '+side,[(.83,.16,.16,sign*.58,-.035),(1.06,.18,.18,sign*.58,0),(1.16,.145,.15,sign*.57,0)],'forearm_'+side,steel)
   rings('Bracer trim '+side,[(1.07,.183,.183,sign*.58,0),(1.12,.18,.18,sign*.58,0)],'forearm_'+side,gold)
   orb('Glove '+side,(sign*.58,-.065,.83),(.13,.13,.15),'hand_'+side,dark)
   rings('Pauldron gold '+side,[(1.39,.29,.29,sign*.5,0),(1.51,.35,.33,sign*.5,0),(1.72,.22,.23,sign*.5,0)],'upper_arm_'+side,gold)
   rings('Pauldron enamel '+side,[(1.44,.275,.28,sign*.5,0),(1.54,.33,.31,sign*.5,0),(1.76,.17,.19,sign*.5,0)],'upper_arm_'+side,steel)
   if hero=='warrior':blade('Shoulder crest '+side,[(sign*.62,0,1.65),(sign*.81,.03,1.91),(sign*.9,.08,2.02)],.12,'upper_arm_'+side,light)
   else:orb('Shoulder crystal '+side,(sign*.58,-.23,1.62),(.09,.05,.12),'upper_arm_'+side,gem)
  # Separate skirt panels preserve leg motion and add a recognizable silhouette.
  for j in range(8):
   a=j*math.tau/8
   z=.51 if hero=='warrior' else .27
   x,y=math.cos(a),math.sin(a)
   rings('Tabard panel',[(z,.14,.10,x*.37,y*.31),(.83,.13,.095,x*.28,y*.23),(.94,.12,.08,x*.27,y*.22)],'pelvis',cloth,6)
   orb('Belt stud',(x*.33,y*.25,.92),(.055,.045,.055),'pelvis',gold)
  # Faceted back mantle, readable from the third-person camera.
  rings('Mantle',[(.48 if hero=='warrior' else .32,.43,.045,0,.29),(1.15,.39,.05,0,.32),(1.59,.32,.045,0,.235)],'chest',cloth,8)
  for sign in [-1,1]:
   blade('Mantle embroidery',[(sign*.31,.344,.57),(sign*.27,.38,1.12),(sign*.22,.30,1.53)],.028,'chest',gold)
  orb('Mantle seal',(0,.31,1.47),(.11,.045,.11),'chest',gold)
  # glTF maps Blender +Y to Godot -Z, the gameplay forward direction.
  for o in list(scene.objects):
   if o.type=='MESH':
    o.location.y *= -1
    for v in o.data.vertices:v.co.y *= -1
    o.data.flip_normals()
  # Merge pieces sharing a material, retaining skin weights and reducing draws.
  groups={}
  for o in list(scene.objects):
   if o.type=='MESH':groups.setdefault(o.data.materials[0].name,[]).append(o)
  for name,parts in groups.items():
   bpy.ops.object.select_all(action='DESELECT')
   for o in parts:o.select_set(True)
   bpy.context.view_layer.objects.active=parts[0]
   if len(parts)>1:bpy.ops.object.join()
   bpy.context.object.name=hero+'_'+name.split()[-1]
  for tr in arm.animation_data.nla_tracks:tr.mute=False
  scene.frame_set(0)
  bpy.data.libraries.write(str(ROOT/'blender'/f'{hero}_fantasy.blend'),{scene})
  bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets'/f'{hero}_animated.glb'),export_format='GLB',use_active_scene=True,export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True)
finally:bpy.context.window.scene=original
print('FANTASY_HEROES_EXPORTED')
