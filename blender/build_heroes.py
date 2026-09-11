"""Run in a separate Blender scene; export original blockout variants for RIFT."""
import bpy
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def material(name,color):
    m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*color,1); p.inputs['Roughness'].default_value=.75
    return m
def cube(name,pos,size,mat):
    bpy.ops.mesh.primitive_cube_add(size=1,location=pos)
    o=bpy.context.object; o.name=name; o.scale=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    o.data.materials.append(mat)
    bevel=o.modifiers.new('Bevel','BEVEL'); bevel.width=.045; bevel.segments=2
    o.modifiers.new('Normals','WEIGHTED_NORMAL')
    return o
original=bpy.context.window.scene
for hero in ['warrior','mage']:
    scene=bpy.data.scenes.new('RIFT_'+hero)
    bpy.context.window.scene=scene
    with bpy.data.libraries.load(str(ROOT/'blender'/'sentinel.blend'),link=False) as (src,dst):
        dst.objects=src.objects
    for o in dst.objects:
        if o is not None:
            scene.collection.objects.link(o)
    steel=material(hero+' armor',(.32,.39,.39) if hero=='warrior' else (.20,.18,.34))
    gold=material(hero+' trim',(.52,.39,.20))
    for o in list(scene.objects):
        if o.type=='MESH' and any(w in o.name for w in ['Chest','Shoulder','Helmet']):
            o.data=o.data.copy(); o.data.materials.clear(); o.data.materials.append(steel)
        if o.name.startswith('Caster'):
            scene.collection.objects.unlink(o)
    if hero=='warrior':
        cube('Crest',(0,0,2.08),(.15,.49,.15),gold)
        for side in [-1,1]:
            cube('Pauldron',(side*.54,0,1.47),(.42,.55,.22),steel)
    else:
        bpy.ops.mesh.primitive_cone_add(vertices=8,radius1=.5,radius2=.29,depth=.88,location=(0,0,.71))
        bpy.context.object.name='Robe'; bpy.context.object.data.materials.append(steel)
        bpy.ops.mesh.primitive_cone_add(vertices=8,radius1=.4,radius2=.04,depth=.55,location=(0,0,2.23))
        bpy.context.object.name='Mage hood'; bpy.context.object.data.materials.append(steel)
        cube('Mantle',(0,.29,1.17),(.74,.08,.95),steel)
    bpy.data.libraries.write(str(ROOT/'blender'/f'{hero}.blend'),{scene})
    bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets'/f'{hero}.glb'),export_format='GLB',use_active_scene=True)
bpy.context.window.scene=original
print('HERO_ASSETS_READY')
