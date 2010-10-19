local gl = require 'gl'

assert(mesh, 'missing mesh argument')
color = color or false

function draw()
  -- TODO: do these transforms directly, much faster!
  gl.glPushMatrix()
  gl.glTranslated(self.transform.pos.x, self.transform.pos.y, 0)
  -- slooooow and stupid rotation:
  local f = self.transform.facing
  gl.glRotated(180/math.pi * math.atan2(f.y, f.x), 0, 0, 1)

  for _, face in ipairs(mesh.faces) do
    local color = 0.5
    gl.glBegin(gl.GL_POLYGON)
    for _, vertex in ipairs(face.vertices) do
      gl.glColor3d(color, color, color)
      gl.glVertex3d(vertex.pos[1], vertex.pos[2], vertex.pos[3])
      color = color * 0.8
    end
    gl.glEnd()

    -- draw normal
    gl.glColor3d(1, 0, 1)
    gl.glBegin(gl.GL_LINES)
    local from = (face.vertices[1].pos + face.vertices[3].pos) / 2
    local to = from + face.normal
    gl.glVertex3d(from[1], from[2], from[3])
    gl.glVertex3d(to[1], to[2], to[3])
    gl.glEnd()
  end

  gl.glColor3d(1, 1, 1)

  gl.glPopMatrix()
end
