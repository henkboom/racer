local collision = require 'dokidoki.collision'
local v2 = require 'dokidoki.v2'

player_ship = game.make_blueprint('player_ship',
  {'transform', scale_x=1/2, scale_y=1/2},
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
