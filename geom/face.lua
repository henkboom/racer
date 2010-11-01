local aa_box = require 'geom.aa_box'
local vect = require 'geom.vect'

local mt = {}
mt.__index = mt

function mt.get_bounds(face)
  local min = {math.huge, math.huge, math.huge}
  local max = {-math.huge, -math.huge, -math.huge}

  for vert = 1, 3 do
    for coord = 1, 3 do
      if face.vertices[vert].pos[coord] < min[coord] then
        min[coord] = face.vertices[vert].pos[coord]
      end
      if face.vertices[vert].pos[coord] > max[coord] then
        max[coord] = face.vertices[vert].pos[coord]
      end
    end
  end

  return aa_box(vect(unpack(min)), vect(unpack(max)))
end

local function in_halfspace(v1, v2, normal, p)
  return vect.dot(normal, vect.cross(v2 - v1, p - v1)) >= 0
end

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

  local inside =
    in_halfspace(vertices[1].pos, vertices[2].pos, face.normal, plane_hit) and
    in_halfspace(vertices[2].pos, vertices[3].pos, face.normal, plane_hit) and
    in_halfspace(vertices[3].pos, vertices[1].pos, face.normal, plane_hit)

  if inside then
    return face, plane_hit, face.normal
  else
    return nil
  end
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

  if vect.sqrmag(interpolated) == 0 then
    return self.normal
  else
    return vect.norm(interpolated)
  end
end

local function make(vertices)
  assert(type(vertices == 'table') and #vertices == 3)
  local normal = vect.cross(
    vertices[2].pos - vertices[1].pos,
    vertices[3].pos - vertices[1].pos)
  assert(vect.sqrmag(normal) > 0, 'invalid face')
  normal = vect.norm(normal)
  
  return setmetatable({vertices=vertices, normal=normal}, mt)
end

return make
