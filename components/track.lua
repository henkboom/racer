local geom = require 'geom'
local vect = geom.vect

local mesh
local track_renderer

local tree

local function print_tree(t, indent)
  indent = indent or 0
  print(string.rep('  ', indent) .. #t.objects)
  if t.lower_tree then
    print_tree(t.lower_tree, indent + 1)
  end
  if t.upper_tree then
    print_tree(t.upper_tree, indent + 1)
  end
end

local function draw_aa_box(box)
  local a = box.min
  local b = box.max
  local gl = require 'gl'
  gl.glBegin(gl.GL_LINE_LOOP)
  gl.glVertex3d(a[1], a[2], a[3])
  gl.glVertex3d(b[1], a[2], a[3])
  gl.glVertex3d(b[1], b[2], a[3])
  gl.glVertex3d(a[1], b[2], a[3])
  gl.glVertex3d(a[1], b[2], b[3])
  gl.glVertex3d(b[1], b[2], b[3])
  gl.glVertex3d(b[1], a[2], b[3])
  gl.glVertex3d(a[1], a[2], b[3])
  gl.glEnd()
  gl.glBegin(gl.GL_LINES)
  gl.glVertex3d(a[1], a[2], a[3])
  gl.glVertex3d(a[1], b[2], a[3])
  gl.glVertex3d(a[1], a[2], b[3])
  gl.glVertex3d(a[1], b[2], b[3])
  gl.glVertex3d(b[1], a[2], a[3])
  gl.glVertex3d(b[1], a[2], b[3])
  gl.glVertex3d(b[1], b[2], a[3])
  gl.glVertex3d(b[1], b[2], b[3])
  gl.glEnd()
end

local function draw_tree(t)
  local gl = require 'gl'

  local function draw(t, alpha)
    gl.glLineWidth(3)
    gl.glColor4d(0, 0, 0, alpha)
    draw_aa_box(t.volume)

    gl.glLineWidth(1)
    gl.glColor4d(0, 1, 0, alpha)
    draw_aa_box(t.volume)

    if t.lower_tree then
      draw(t.lower_tree, alpha)
    end
    if t.upper_tree then
      draw(t.upper_tree, alpha)
    end
  end

  gl.glDepthFunc(gl.GL_LEQUAL)
  draw(t, 0.5)

  gl.glClear(gl.GL_DEPTH_BUFFER_BIT)
  draw(t, 0.02)
  gl.glDepthFunc(gl.GL_LESS)
  gl.glColor3d(1, 1, 1)
end

function draw_debug()
  --draw_tree(tree)
end

function load(new_mesh)
  mesh = new_mesh
  tree = geom.kd_tree(mesh.faces, function (f) return f:get_bounds() end)
  print_tree(tree)

  if track_renderer then
    track_renderer.dead = true
  end
  track_renderer = game.actors.new(game.blueprints.track,
    {'mesh_renderer', mesh=new_mesh})
end

function trace_gravity_ray(ray_origin, ray_direction)
  local faces = tree:intersect_ray(ray_origin, ray_direction)
  --print(#tree.objects)
  --print(tree.volume.min, tree.volume.max)
  --local faces = mesh.faces
  print(#faces)

  local closest_face, closest_pos

  for i = 1, #faces do
    local face, pos = faces[i]:intersect_ray(ray_origin, ray_direction)
    if face and (not closest_face or vect.sqrmag(ray_origin - pos) <
                vect.sqrmag(ray_origin - closest_pos)) then
      closest_face = face
      closest_pos = pos
    end
  end
  if closest_face then
    return closest_pos, closest_face:interpolate_normal(closest_pos)
  else
    return false
  end
end
