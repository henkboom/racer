local vect = require 'geom.vect'
local aa_box = require 'geom.aa_box'

local MAX_OBJECTS = 10

local mt = {}
mt.__index = mt

local function append(dst, src)
  local offset = #dst
  for i = 1, #src do
    dst[offset+i] = src[i]
  end
end

-- returns the objects that may intersect
function mt.intersect_ray(tree, ray_origin, ray_direction)
  local results = {}
  --print('trying ray ' .. tostring(ray_origin) .. ' + t' .. tostring(ray_direction))
  if tree.volume:intersect_ray(ray_origin, ray_direction) then
    --print('got it')
    append(results, tree.objects)
    if tree.lower_tree then
      append(results,
        tree.lower_tree:intersect_ray(ray_origin, ray_direction))
    end
    if tree.upper_tree then
      append(results,
        tree.upper_tree:intersect_ray(ray_origin, ray_direction))
    end
  end
  --print('returning ' .. #results)
  return results
end

local function internal_make(objects, object_bounds, volume, axis)
  local ret = setmetatable({}, mt)

  ret.axis = axis
  ret.volume = volume

  if #objects <= MAX_OBJECTS then
    ret.objects = objects
  else
    local center = (volume.min[axis] + volume.max[axis]) / 2

    local self_objects = {}

    local lower_objects = {}
    local lower_bounds = {}
    local upper_objects = {}
    local upper_bounds = {}

    for i = 1, #objects do
      if object_bounds[i].max[axis] <= center then
        table.insert(lower_objects, objects[i])
        table.insert(lower_bounds, object_bounds[i])
      elseif object_bounds[i].min[axis] > center then
        table.insert(upper_objects, objects[i])
        table.insert(upper_bounds, object_bounds[i])
      else
        table.insert(self_objects, objects[i])
      end
    end

    local lower_volume_max = {volume.max[1], volume.max[2], volume.max[3]}
    lower_volume_max[axis] = center
    local lower_volume = aa_box(volume.min, vect(unpack(lower_volume_max)))

    local upper_volume_min = {volume.min[1], volume.min[2], volume.min[3]}
    upper_volume_min[axis] = center
    local upper_volume = aa_box(vect(unpack(upper_volume_min)), volume.max)

    local next_axis = (axis % 3) + 1

    ret.objects = self_objects
    if #lower_objects > 0 then
      ret.lower_tree =
        internal_make(lower_objects, lower_bounds, lower_volume, next_axis)
    end
    if #upper_objects > 0 then
      ret.upper_tree =
        internal_make(upper_objects, upper_bounds, upper_volume, next_axis)
    end
  end

  return ret
end

local function make(objects, bound_func)
  local min = {math.huge, math.huge, math.huge}
  local max = {-math.huge, -math.huge, -math.huge}

  local object_bounds = {}
  for i = 1, #objects do
    local bound = bound_func(objects[i])
    object_bounds[i] = bound

    for j = 1, 3 do
      if bound.min[j] < min[j] then min[j] = bound.min[j] end
      if bound.max[j] > max[j] then max[j] = bound.max[j] end
    end
  end
  return internal_make(
    objects, object_bounds, aa_box(vect(unpack(min)), vect(unpack(max))), 1)
end

return make
