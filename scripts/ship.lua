local vect = require 'geom.vect'

self.tags.ship = true

local SHIP_HEIGHT = 0.3
local GRAVITY = 0.02

-- controls access
accel = 0
turn = 0
brake = false
boost = false

-- read only please
vel = vect(0, 0, 0)

local buffered_turn = 0
local buffered_accel = 0

local function damp(value, scalar, multiplier)
  local sign = value > 0 and 1 or -1
  return math.max(value * sign - scalar, 0) * multiplier * sign
end

local function damp_vect(v, scalar, multiplier)
  local mag = vect.mag(v)
  if mag > 0 then
    return v * damp(mag, scalar, multiplier) / mag
  else
    return v
  end
end


function draw_debug()
  local gl = require 'gl'
  local ground_pos, ground_normal = game.track.trace_gravity_ray(
    self.transform.pos, -self.transform.up)
  if ground_pos then
    gl.glBegin(gl.GL_LINES)
    gl.glColor3d(0, 1, 0)
    gl.glVertex3d(self.transform.pos[1], self.transform.pos[2], self.transform.pos[3])
    gl.glColor3d(1, 1, 1)
    gl.glVertex3d(ground_pos[1], ground_pos[2], ground_pos[3])
    gl.glEnd()
    gl.glPointSize(10)

    gl.glBegin(gl.GL_POINTS)
    gl.glColor3d(1, 0, 0)
    gl.glVertex3d(ground_pos[1], ground_pos[2], ground_pos[3])
    gl.glEnd()
    gl.glColor3d(1, 1, 1)
  end

  local function draw_vect(v)
    gl.glVertex3d(v[1], v[2], v[3])
  end
  gl.glBegin(gl.GL_LINES)
  gl.glColor3d(1, 0, 0)
  draw_vect(self.transform.pos)
  draw_vect(self.transform.pos + self.transform.facing)
  gl.glColor3d(0, 1, 0)
  draw_vect(self.transform.pos)
  draw_vect(self.transform.pos + self.transform.left)
  gl.glColor3d(0, 0, 1)
  draw_vect(self.transform.pos)
  draw_vect(self.transform.pos + self.transform.up)
  gl.glEnd()
  gl.glColor3d(1, 1, 1)
end

function update()
  buffered_accel = buffered_accel * 0.85 + accel * 0.15
  buffered_turn = buffered_turn * 0.85 + turn * 0.15
  self.transform.rotate(self.transform.up, buffered_turn / 10)

  local current_accel = buffered_accel * 0.005
  if boost then current_accel = current_accel + 0.005 end

  -- acceleration
  vel = vel + self.transform.facing * current_accel
  -- general damping
  vel = damp_vect(vel, 0.001, 0.995)
  -- braking damping
  if brake then
    vel =
      vect.project(vel, self.transform.facing)  * 0.99 +
      damp_vect(vect.project(vel, self.transform.left), 0.001, 0.97) +
      vect.project(vel, self.transform.up)
  end

  self.transform.pos = self.transform.pos + vel

  -- track handling
  local ground_pos, ground_normal = game.track.trace_gravity_ray(
    self.transform.pos + self.transform.up, -self.transform.up)
  if ground_pos then
    -- rotate to be in line with the ground
    local axis = vect.cross(self.transform.up, ground_normal)
    if not vect.is_small(axis) then
      local angle = math.acos(vect.dot(self.transform.up, ground_normal))
      self.transform.rotate(vect.norm(axis), math.min(math.pi/32, angle))
    end

    -- track collision
    local target_pos = ground_pos + ground_normal * SHIP_HEIGHT
    if vect.dot(target_pos - self.transform.pos, ground_normal) > 0 then
      self.transform.pos = target_pos
      vel = vel - vect.project(vel, ground_normal)
    end
  end

  -- gravity
  vel = vel - GRAVITY * (ground_normal or self.transform.up)
end

function self.collider.on_collide(normal)
  local normal_vel = vect.project(vel, normal)
  local tangent_vel = vel - normal_vel
  if vect.dot(normal_vel, normal) < 0 then
    vel = -0.2 * normal_vel +
          damp_vect(tangent_vel, vect.mag(normal_vel)*0.75, 1)
  end
end
