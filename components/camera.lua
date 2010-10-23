local glu = require 'glu'
local vect = require 'geom.vect'

local target
local pos
local vel
local up
local source_elevation_direction = vect(0, 0, 1)

function set_target(new_target)
  target = new_target
  if target then
    pos = target.transform.pos
    vel = vect(0, 0, 0)
    up = target.transform.facing
    source_elevation_direction = target.transform.up
  end
end

game.actors.new_generic('camera', function ()
  function update_cleanup()
    if target and target.dead then
      target = nil
    end

    local new_pos = target and target.transform.pos or pos

    -- if new_pos is false then we've never had a target
    if new_pos then
      local new_vel = new_pos - pos
      vel = vel * 0.93 + new_vel * 0.07
      pos = new_pos
      if target then
        source_elevation_direction =
          vect.norm(source_elevation_direction * 0.93 +
          target.transform.up * 0.07)
      end

      if not vect.is_small(vel) then
        local new_up = up + 0.05 * vect.norm(vel)
        if vect.is_small(new_up) then
          new_up = vect.norm(vel)
        end

        if not vect.is_small(new_up) then
          up = vect.norm(new_up)
        end
      end
    end
  end
  function draw_setup()
    if pos then
      local height = math.max(15 - vect.mag(vel)*8, 2)
      local source = pos - vel * 6 + source_elevation_direction * height
      local subject = pos + vel * 12

      glu.gluLookAt(source[1], source[2], source[3],
                    subject[1], subject[2], subject[3],
                    up[1], up[2], up[3])
    end
  end
end)
