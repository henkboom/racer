local vect = require 'geom.vect'

local mt = {}
mt.__index = mt

function mt.intersect_ray(face, ray_origin, ray_direction)
  -- if the ray starts behind the face don't even bother
  if vect.dot(ray_origin - face.vertices[1].pos, face.normal) <= 0 then
    return nil
  end

  local vertices = face.vertices
  local vertex_count = #vertices

  -- plane-line intersection, look it up
  local t
  local plane_hit
  do
    local denominator = vect.dot(ray_direction, face.normal)
    -- if the ray is parallel to the face let's say they aren't intersecting
    if denominator == 0 then
      return nil
    end

    local numerator = vect.dot(vertices[1].pos - ray_origin, face.normal)
    t = numerator / denominator
    -- if t is negative then the ray is pointing the wrong way
    if t < 0 then
      return nil
    end
    plane_hit = ray_origin + ray_direction * t
  end

  -- now see if it's inside the half-spaces defined by the edges
  -- 0-based loop so that we can use modular arithmetic
  for i = 0, vertex_count-1 do
    local from = vertices[i + 1].pos
    local to = vertices[(i+1) % vertex_count + 1].pos
    if vect.dot(face.normal, vect.cross(to - from, plane_hit - from)) < 0 then
      return nil
    end
  end

  -- it's inside!
  return face, plane_hit, face.normal
end

local function make(vertices)
  assert(type(vertices == 'table') and (#vertices == 3 or #vertices == 4))
  local normal = vect.cross(
    vertices[2].pos - vertices[1].pos,
    vertices[3].pos - vertices[1].pos)
  assert(vect.sqrmag(normal) > 0, 'invalid face')
  normal = vect.norm(normal)
  
  return setmetatable({vertices=vertices, normal=normal}, mt)
end

return make
