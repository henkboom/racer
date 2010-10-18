local gl = require 'gl'
local glu = require 'glu'

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

    gl.glMatrixMode(gl.GL_PROJECTION)
    gl.glLoadIdentity()
    glu.gluPerspective(70, 16/9, 1, 10000)
    gl.glMatrixMode(gl.GL_MODELVIEW)
    gl.glLoadIdentity()
  end
end)
