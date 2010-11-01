-- some stuff that I never ported. it doesn't run anymore, it's just here as a
-- reminder

---- Controllers --------------------------------------------------------------

function make_dumb_controller(game)
  local self = {}
  local ship

  self.accel = 1
  self.turn = 0
  self.brake = false
  self.boost = false

  function self.set_ship(new_ship)
    ship = new_ship
  end

  function self.pre_update ()
    assert(ship)
    self.turn = math.max(-0.1, math.min(0.1, math.random() * 0.2 - 0.1))
    self.boost = false
    self.brake = false

    local facing = v2.unit(ship.angle)
    local facing_vel = math.max(0, v2.dot(facing, ship.vel)) * facing

    if game.collision_test(ship.pos + 30 * facing_vel + v2.rotate(v2(15, -15), ship.angle)) then
      self.turn = self.turn - 1
    elseif game.collision_test(ship.pos + 30 * facing_vel + v2.rotate(v2(15, 15), ship.angle)) then
      self.turn = self.turn + 1
    end

    if game.collision_test(ship.pos + ship.vel * 30) then
      self.brake = true
    elseif not game.collision_test(ship.pos + facing_vel * 60) then
      self.boost = true
    end
  end

  return self
end

