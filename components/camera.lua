local glu = require 'glu'
local v2 = require 'dokidoki.v2'

local target
local pos
local vel
local up

local function is_small(v)
  return v2.sqrmag(v) <= 0.00001
end

function set_target(new_target)
  target = new_target
  if target then
    pos = target.transform.pos
    vel = v2(0, 0)
    up = target.transform.facing
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

      if not is_small(vel) then
        local new_up = up + 0.05 * v2.norm(vel)
        if is_small(new_up) then
          new_up = v2.norm(vel)
        end

        if not is_small(new_up) then
          up = v2.norm(new_up)
        end
      end
    end
  end
  function draw_setup()
    if pos then
      local source = pos - vel * 3
      local subject = pos + vel * 6
      local height = math.max(80 - v2.mag(vel) * 15, 10)

      glu.gluLookAt(source.x, source.y, height,
                    subject.x, subject.y, 0,
                    up.x, up.y, 0)
    end
  end
end)
