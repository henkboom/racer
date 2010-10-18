local vect = require 'geom.vect'

local function make(vertices)
  assert(type(vertices == 'table') and (#vertices == 3 or #vertices == 4))
  local normal = vect.cross(
    vertices[2].pos - vertices[1].pos,
    vertices[3].pos - vertices[1].pos)
  assert(vect.sqrmag(normal) > 0, 'invalid face')
  normal = vect.norm(normal)
  
  return {vertices=vertices, normal=normal}
end

return make
