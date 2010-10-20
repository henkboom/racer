local collision = require 'dokidoki.collision'
local vect = require 'geom.vect'

player_ship = game.make_blueprint('player_ship',
  {'transform', scale_x=1/8, scale_y=1/8, pos = vect(1, 1, 1)},
  {'sprite', resource='ship_sprite'},
  {'collider', class='ship', poly=collision.make_rectangle(6, 4)},
  {'player_ship_control'},
  {'ship'})

terrain = game.make_blueprint('terrain',
  {'transform'},
  {'sprite', resource='terrain_sprite'})

track = game.make_blueprint('track',
  {'transform'},
  {'mesh_renderer'})
