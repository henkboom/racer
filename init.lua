require 'dokidoki.module' [[]]

local kernel = require 'dokidoki.kernel'
local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

kernel.set_ratio(16/9)

kernel.start_main_loop(game.make_game(
  {'update_setup', 'update', 'collision_check', 'update_cleanup'},
  {'draw_setup', 'draw_terrain', 'draw', '_draw_debug', 'draw_minimap_setup',
   'draw_minimap_terrain', 'draw_minimap'},
  function (game)
    game.init_component('exit_handler')
    game.exit_handler.trap_esc = true
    game.init_component('keyboard')

    game.init_component('blueprints')
    game.init_component('opengl')
    game.init_component('resources')
    game.init_component('camera')
    game.init_component('collision')
    game.init_component('level')
    game.level.load(loadfile('level_data.lua')())

    game.actors.new(game.blueprints.terrain)
    local player = game.actors.new(game.blueprints.player_ship,
      {'transform', pos=v2(100, 100)})

    game.camera.set_target(player)
  end))
