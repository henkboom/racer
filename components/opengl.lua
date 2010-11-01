local gl = require 'gl'
local glu = require 'glu'
local memarray = require 'memarray'

local tmp_array = memarray('GLfloat', 4)
local function fv(a, b, c, d)
  tmp_array[0] = a
  tmp_array[1] = b
  tmp_array[2] = c
  tmp_array[3] = d
  return tmp_array:ptr()
end

game.actors.new_generic("opengl", function ()
  function draw_setup()
    gl.glClearColor(0, 0, 0, 0)
    gl.glClear(gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT)

    gl.glEnable(gl.GL_BLEND)
    gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
    gl.glEnable(gl.GL_DEPTH_TEST)
    gl.glDepthFunc(gl.GL_LESS)
    gl.glEnable(gl.GL_ALPHA_TEST)
    gl.glAlphaFunc(gl.GL_GREATER, 0)
    gl.glShadeModel(gl.GL_SMOOTH)

    gl.glEnable(gl.GL_LIGHTING)
    gl.glEnable(gl.GL_LIGHT0)
    gl.glLightfv(gl.GL_LIGHT0, gl.GL_AMBIENT, fv(0.5, 0.5, 0.5, 1.0))
    gl.glLightfv(gl.GL_LIGHT0, gl.GL_DIFFUSE, fv(0.5, 0.5, 0.5, 1.0))
    gl.glLightfv(gl.GL_LIGHT0, gl.GL_SPECULAR, fv(0, 0, 0, 0))
    gl.glLightfv(gl.GL_LIGHT0, gl.GL_POSITION, fv(0, 0, 64, 0))

    gl.glMatrixMode(gl.GL_PROJECTION)
    gl.glLoadIdentity()
    glu.gluPerspective(70, 16/9, 1, 10000)
    gl.glMatrixMode(gl.GL_MODELVIEW)
    gl.glLoadIdentity()
  end
end)
