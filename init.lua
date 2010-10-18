package.path = '?.lua;?/init.lua'

require 'dokidoki.module' [[]]

local kernel = require 'dokidoki.kernel'
local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

kernel.set_ratio(16/9)
kernel.set_video_mode(1024, 576)

kernel.start_main_loop(game.make_game(
  {'update_setup', 'update', 'collision_check', 'update_cleanup'},
  {'draw_setup', 'draw_terrain', 'draw', '_draw_debug'},
  function (game)
    game.init_component('exit_handler')
    game.exit_handler.trap_esc = true
    game.init_component('keyboard')

    game.init_component('resources')
    game.init_component('blueprints')
    game.init_component('opengl')
    game.init_component('camera')
    game.init_component('collision')

    local player = game.actors.new(game.blueprints.player_ship,
      {'transform', pos=v2(0, 0)})

    game.actors.new(game.blueprints.track)

    game.camera.set_target(player)
  end))
