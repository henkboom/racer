local gl = require 'gl'

assert(mesh, 'missing mesh argument')
color = color or false

function draw()
  self.transform.pos = game.actors.get('player_ship')[1].transform.pos
  -- TODO: do these transforms directly, much faster!
  gl.glPushMatrix()
  gl.glTranslated(self.transform.pos.x, self.transform.pos.y, 0)
  -- slooooow and stupid rotation:
  local f = self.transform.facing
  gl.glRotated(180/math.pi * math.atan2(f.y, f.x), 0, 0, 1)
  gl.glScaled(self.transform.scale_x, self.transform.scale_y, self.transform.scale_z)

  if color then gl.glColor4d(color[1], color[2], color[3], color[4] or 1) end

  for _, face in ipairs(mesh) do
    gl.glBegin(gl.GL_LINE_LOOP)
    for _, vertex in ipairs(face.vertices) do
      gl.glVertex3d(vertex[1], vertex[3], vertex[2])
    end
    gl.glEnd()
  end

  if color then gl.glColor3d(1, 1, 1) end

  gl.glPopMatrix()
end
