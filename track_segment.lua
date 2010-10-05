local function make ()
  local self = {}

  -- returns solid track edges
  function self.get_edges()
    return {}
  end

  -- returns links to other track segments
  function self.get_links()
    return {}
  end

  -- returns the position/forward/up vectors which correspond to the give 2d
  -- position and forward vectors
  function map_pos(pos, forward)
    return {pos.x, pos.y, 0}, {forward.x, forward.y, 0}, {0, 0, 1}
  end

end

return {make = make}
