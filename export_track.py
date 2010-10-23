import sys
import bpy

i = 1
while i < len(sys.argv) and sys.argv[i] != "--":
    i = i + 1
args = sys.argv[i+1:]

bpy.ops.export_scene.obj(
    filepath=args[0],
    use_rotate_x90=False,
    use_materials=False,
    use_normals=True,
    use_triangles=True)

bpy.ops.wm.quit_blender()
