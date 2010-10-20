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
  for i = 1, #faces do
    face, pos, normal = faces[i]:intersect_ray(ray_origin, ray_direction)
    if face then
      return pos, face:interpolate_normal(pos)
    end
  end
end
