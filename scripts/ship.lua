local v2 = require 'dokidoki.v2'
local vect = require 'geom.vect'

self.tags.ship = true

-- controls access
accel = 0
turn = 0
brake = false
boost = false

-- read only please
vel = v2(0, 0)

local buffered_turn = 0
local buffered_accel = 0

local function damp(value, scalar, multiplier)
  local sign = value > 0 and 1 or -1
  return math.max(value * sign - scalar, 0) * multiplier * sign
end

local function damp_v2(vect, scalar, multiplier)
  local mag = v2.mag(vect)
  if mag > 0 then
    return vect * damp(mag, scalar, multiplier) / mag
  else
    return vect
  end
end


function draw_debug()
  local gl = require 'gl'
  local ground_pos, ground_normal = game.track.trace_gravity_ray(
    vect(self.transform.pos.x, self.transform.pos.y, 0), vect(0, 0, -1))
  if ground_pos then
    --gl.glDepthFunc(gl.GL_ALWAYS)

    gl.glBegin(gl.GL_LINES)
    gl.glColor3d(0, 1, 0)
    gl.glVertex3d(self.transform.pos.x, self.transform.pos.y, 0)
    gl.glColor3d(1, 1, 1)
    gl.glVertex3d(ground_pos[1], ground_pos[2], ground_pos[3])
    gl.glEnd()
    gl.glPointSize(10)

    gl.glBegin(gl.GL_POINTS)
    gl.glColor3d(1, 0, 0)
    gl.glVertex3d(ground_pos[1], ground_pos[2], ground_pos[3])
    gl.glEnd()
    gl.glColor3d(1, 1, 1)

    --gl.glDepthFunc(gl.GL_LESS)
  end
end

function update()
  buffered_accel = buffered_accel * 0.85 + accel * 0.15
  buffered_turn = buffered_turn * 0.85 + turn * 0.15
  self.transform.facing =
    v2.norm(v2.rotate(self.transform.facing, buffered_turn / 10))

  local current_accel = buffered_accel * 0.005
  if boost then current_accel = current_accel + 0.005 end

  -- acceleration
  vel = vel + self.transform.facing * current_accel
  -- general damping
  vel = damp_v2(vel, 0.001, 0.995)
  -- braking damping
  if brake then
    vel =
      v2.project(vel, self.transform.facing)  * 0.99 +
      damp_v2(v2.project(vel, v2.rotate90(self.transform.facing)), 0.001, 0.97)
  end

  self.transform.pos = self.transform.pos + vel
end

function self.collider.on_collide(normal)
  local normal_vel = v2.project(vel, normal)
  local tangent_vel = vel - normal_vel
  if v2.dot(normal_vel, normal) < 0 then
    vel = -0.2 * normal_vel +
          damp_v2(tangent_vel, v2.mag(normal_vel)*0.75, 1)
  end
end
