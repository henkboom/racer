local collision = require 'dokidoki.collision'
local obj = require 'obj'
local v2 = require 'dokidoki.v2'

player_ship = game.make_blueprint('player_ship',
  {'transform', scale_x=1/8, scale_y=1/8},
  {'sprite', resource='ship_sprite'},
  {'collider', class='ship', poly=collision.make_rectangle(6, 4)},
  {'player_ship_control'},
  {'ship'})

terrain = game.make_blueprint('terrain',
  {'transform'},
  {'sprite', resource='terrain_sprite'})

obstacle = game.make_blueprint('obstacle',
  {'transform'},
  {'collider', class='obstacle'})

track = game.make_blueprint('track',
  {'transform'},
  {'mesh_renderer', mesh=obj.parse('tracks/track.obj')})
