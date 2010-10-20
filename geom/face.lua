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

local function to_barycentric_2d(v1, v2, v3, p)
  local a = ((v2[2]-v3[2])*(p[1]-v3[1]) + (v3[1]-v2[1])*(p[2]-v3[2])) /
            ((v2[2]-v3[2])*(v1[1]-v3[1]) + (v3[1]-v2[1])*(v1[2]-v3[2]))
  local b = ((v3[2]-v1[2])*(p[1]-v3[1]) + (v1[1]-v3[1])*(p[2]-v3[2])) /
            ((v3[2]-v1[2])*(v2[1]-v3[1]) + (v1[1]-v3[1])*(v2[2]-v3[2]))
  local c = 1 - a - b
  return a, b, c
end

-- this actually uses the basis vectors i*unit(i), etc. but it works the same
-- in this context
local function to_2d_basis(i, j, v)
  return vect(vect.dot(v, i), vect.dot(v, j), 0)
end

local function to_barycentric(v1, v2, v3, p)
  local i = v2 - v1
  local j = vect.cross(vect.cross(i, v3 - v1), i)
  return to_barycentric_2d(
    to_2d_basis(i, j, v1),
    to_2d_basis(i, j, v2),
    to_2d_basis(i, j, v3),
    to_2d_basis(i, j, p))
end

function mt.interpolate_normal(self, pos)
  local verts = self.vertices
  local a, b, c = to_barycentric(verts[1].pos, verts[2].pos, verts[3].pos, pos)
  local d = 0
  if b < 0 and #verts > 3 then
    b = 0
    c, d, a = to_barycentric(verts[3].pos, verts[4].pos, verts[1].pos, pos)
  end
  local interpolated =
    a * verts[1].normal +
    b * verts[2].normal +
    c * verts[3].normal +
    (d ~= 0 and d * verts[4].normal or vect(0, 0, 0))

  print(string.format("%.3f %.3f %.3f %.3f", a, b, c, d))
  if vect.sqrmag(interpolated) == 0 then
    return self.normal
  else
    return vect.norm(interpolated)
  end
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
