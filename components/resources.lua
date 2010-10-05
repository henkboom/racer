local graphics = require 'dokidoki.graphics'
local obj = require 'obj'

terrain_sprite = graphics.sprite_from_image('sprites/terrain.png')
ship_sprite = graphics.sprite_from_image('sprites/ship.png', nil, 'center')

track_mesh = obj.parse('tracks/track.obj')
