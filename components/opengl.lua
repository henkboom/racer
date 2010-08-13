local gl = require 'gl'
local glu = require 'glu'

game.actors.new_generic("opengl", function ()
  function draw_setup()
    gl.glClearColor(0, 0, 0, 0)
    gl.glClear(gl.GL_COLOR_BUFFER_BIT)
    gl.glEnable(gl.GL_BLEND)
    gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
    gl.glMatrixMode(gl.GL_PROJECTION)
    gl.glLoadIdentity()
    glu.gluPerspective(100, 16/9, 1, 10000)
    gl.glMatrixMode(gl.GL_MODELVIEW)
    gl.glLoadIdentity()
  end

  function draw_minimap_setup()
    gl.glMatrixMode(gl.GL_PROJECTION)
    gl.glLoadIdentity()
    gl.glOrtho(0, 640, 0, 480, 1, -1)
    gl.glMatrixMode(gl.GL_MODELVIEW)
    gl.glLoadIdentity()
    gl.glScaled(0.1, 0.1, 0.1)
  end
end)
