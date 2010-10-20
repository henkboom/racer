local gl = require 'gl'
local memarray = require 'memarray'

color = color or false

local matrix = memarray('GLfloat', 16)
for i = 0, 14 do
  matrix[i] = 0
end
matrix[15] = 1

if resource then
  image = game.resources[resource]
end

function draw()
  local pos = self.transform.pos
  local facing = self.transform.facing
  local left = self.transform.left
  local up = self.transform.up

  -- i
  matrix[0] = facing[1] * self.transform.scale_x
  matrix[1] = facing[2] * self.transform.scale_x
  matrix[2] = facing[3] * self.transform.scale_x
  -- j
  matrix[4] = left[1] * self.transform.scale_y
  matrix[5] = left[2] * self.transform.scale_y
  matrix[6] = left[3] * self.transform.scale_y
  -- k
  matrix[8] = up[1] * self.transform.scale_z
  matrix[9] = up[2] * self.transform.scale_z
  matrix[10] = up[3] * self.transform.scale_z
  -- translation
  matrix[12] = pos[1]
  matrix[13] = pos[2]
  matrix[14] = pos[3]

  gl.glPushMatrix()
  gl.glMultMatrixf(matrix:ptr())

  if color then gl.glColor4d(color[1], color[2], color[3], color[4] or 1) end
  image:draw()
  if color then gl.glColor3d(1, 1, 1) end

  gl.glPopMatrix()
end
