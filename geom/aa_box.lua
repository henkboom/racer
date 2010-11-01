local mt = {}
mt.__index = mt

function mt.intersect_aa_box(a, b)
  local a_min = a.min
  local a_max = a.max
  local b_min = b.min
  local b_max = b.max

  for i = 1, 3 do
    if a_max[i] <= b_min[i] or b_max[i] <= a_min[i] then
      return false
    end
  end
  return true
end

function mt.intersect_ray(box, ray_origin, ray_direction)
  local t_enter = 0
  local t_leave = math.huge

  for i = 1, 3 do
    if ray_direction[i] == 0 then
      if ray_origin[i] < box.min[i] or box.max[i] < ray_origin[i] then
        return false
      end
    else
      local first = box.min[i]
      local second = box.max[i]
      if ray_direction[i] < 0 then
        first, second = second, first
      end
      t_enter = math.max(t_enter, (first-ray_origin[i])/ray_direction[i])
      t_leave = math.min(t_leave, (second-ray_origin[i])/ray_direction[i])

      if t_leave < 0 or t_leave < t_enter then
        --print('failing on axis ' .. i .. ': ', t_enter, t_leave)
        return false
      end
    end
  end

  return true
end

local function make(min, max)
  return setmetatable({min=min, max=max}, mt)
end

return make
