"""Vertex-painted tonal gradients on the original RIFT meshes."""
import bpy,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
original=bpy.context.window.scene
try:
 for hero in ['warrior','mage']:
  with bpy.data.libraries.load(str(ROOT/'blender'/f'{hero}_combat.blend'),link=False) as (src,dst): dst.scenes=src.scenes
  scene=dst.scenes[0];bpy.context.window.scene=scene
  for o in scene.objects:
   if o.type!='MESH':continue
   mesh=o.data;paint=mesh.color_attributes.new(name='RiftPaint',type='BYTE_COLOR',domain='CORNER')
   mesh.color_attributes.active_color=paint
   for polygon in mesh.polygons:
    for index in polygon.loop_indices:
     v=mesh.vertices[mesh.loops[index].vertex_index]
     p=o.matrix_world@v.co
     # Bright shoulders and head, quieter feet; mild facet variation.
     factor=.68+.28*max(0,min(1,p.z/2.2))+.04*max(0,polygon.normal.z)
     base=mesh.materials[polygon.material_index].node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value
     paint.data[index].color=(base[0]*factor,base[1]*factor,base[2]*factor,1)
   for material in mesh.materials:
    material.use_nodes=True
    nodes=material.node_tree.nodes;links=material.node_tree.links
    principled=nodes.get('Principled BSDF')
    base=tuple(principled.inputs['Base Color'].default_value)
    vertex=nodes.new('ShaderNodeVertexColor');vertex.layer_name='RiftPaint'
    links.new(vertex.outputs['Color'],principled.inputs['Base Color'])
  bpy.data.libraries.write(str(ROOT/'blender'/f'{hero}_painted.blend'),{scene})
  bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets'/f'{hero}_animated.glb'),export_format='GLB',use_active_scene=True,export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_vertex_color='ACTIVE',export_all_vertex_colors=False)
finally:bpy.context.window.scene=original
print('PAINTED_HEROES_EXPORTED')
