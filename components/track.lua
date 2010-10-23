local vect = require 'geom.vect'

local mesh
local track_renderer

function load(new_mesh)
  mesh = new_mesh

  if track_renderer then
    track_renderer.dead = true
  end
  track_renderer = game.actors.new(game.blueprints.track,
    {'mesh_renderer', mesh=new_mesh})
end

function trace_gravity_ray(ray_origin, ray_direction)
  local faces = mesh.faces

  local closest_face, closest_pos

  for i = 1, #faces do
    local face, pos = faces[i]:intersect_ray(ray_origin, ray_direction)
    if face and (not closest_face or vect.sqrmag(ray_origin - pos) <
                vect.sqrmag(ray_origin - closest_pos)) then
      closest_face = face
      closest_pos = pos
    end
  end
  return closest_pos, closest_face:interpolate_normal(closest_pos)
end
