local gl = require 'gl'

assert(mesh, 'missing mesh argument')
color = color or false

--TODO: collect the display list to avoid memory leaks
local display_list

local function compile_display_list()
  display_list = gl.glGenLists(1)
  print(display_list)
  gl.glNewList(display_list, gl.GL_COMPILE)

  local faces = mesh.faces
  for i = 1, #mesh.faces do
    local face = faces[i]

    local color = 1
    gl.glBegin(gl.GL_TRIANGLE_FAN)
    for _, vertex in ipairs(face.vertices) do
      gl.glColor3d(color, color, color)
      gl.glNormal3d(vertex.normal[1], vertex.normal[2], vertex.normal[3])
      gl.glVertex3d(vertex.pos[1], vertex.pos[2], vertex.pos[3])
      color = color * 0.7
    end
    gl.glEnd()

    ---- draw normal
    --gl.glColor3d(1, 0, 1)
    --gl.glBegin(gl.GL_LINES)
    --local from = (face.vertices[1].pos + face.vertices[3].pos) / 2
    --local to = from + face.normal
    --gl.glVertex3d(from[1], from[2], from[3])
    --gl.glVertex3d(to[1], to[2], to[3])
    --gl.glEnd()

    ---- draw vertex normals
    --gl.glBegin(gl.GL_LINES)
    --for i = 1, #face.vertices do
    --  local vertex = face.vertices[i]
    --  local from = vertex.pos
    --  local to = from + vertex.normal
    --  gl.glVertex3d(from[1], from[2], from[3])
    --  gl.glVertex3d(to[1], to[2], to[3])
    --end
    --gl.glEnd()
  end

  gl.glColor3d(1, 1, 1)

  gl.glEndList()
end

function draw()
  if not display_list then
    compile_display_list()
  end

  -- TODO: do these transforms directly, much faster!
  gl.glPushMatrix()
  gl.glTranslated(self.transform.pos[1], self.transform.pos[2], 0)
  -- slooooow and stupid rotation:
  local f = self.transform.facing
  gl.glRotated(180/math.pi * math.atan2(f[2], f[1]), 0, 0, 1)

  gl.glCallList(display_list)

  gl.glPopMatrix()
end
