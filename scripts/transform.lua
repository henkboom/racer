local vect = require 'geom.vect'

-- todo: verify orthogonality

pos = pos or vect(0, 0, 0)
facing = facing or vect(1, 0, 0)
left = left or vect(0, 1, 0)
up = up or vect(0, 0, 1)
scale_x = scale_x or 1
scale_y = scale_y or 1
scale_z = scale_z or 1

function rotate(axis, angle)
  facing = vect.norm(vect.rotate(facing, axis, angle))
  left = vect.rotate(left, axis, angle)
  left = vect.norm(left - vect.project(left, facing))
  up = vect.cross(facing, left)
end
