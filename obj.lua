local geom = require 'geom'
local vect = geom.vect

local function tokenize(str, token_pattern)
  local tokens = {}
  for t in str:gmatch(token_pattern) do
    table.insert(tokens, t)
  end
  return tokens
end

local function parse(filename)
  file, err = io.open(filename, 'r')
  if not file then return nil, err end

  local vertices = {}
  local texture_vertices = {}
  local vertex_normals = {}
  local faces = {}

  for line in file:lines() do
    -- tokenize
    local tokens = tokenize(line, '[^ ]+')
    --print(line)
    
    if tokens[1] == 'v' then
      table.insert(vertices, vect(
        tonumber(tokens[2]),
        tonumber(tokens[3]),
        tonumber(tokens[4])))
    elseif tokens[1] == 'vt' then
      table.insert(texture_vertices, vect(
        tonumber(tokens[2]),
        tonumber(tokens[3]),
        tonumber(tokens[4] or 0)))
    elseif tokens[1] == 'vn' then
      table.insert(vertices, vect.norm(vect(
        tonumber(tokens[2]),
        tonumber(tokens[3]),
        tonumber(tokens[4]))))
    elseif tokens[1] == 'f' then
      local face_vertices = {}
      --local face_texture_vertices = {}

      for i = 2, #tokens do
        local fields = tokenize(tokens[i], '[^/]+')
        local vertex_index = tonumber(fields[1])
        local texcoord_index = tonumber(fields[2])
        local normal_index = tonumber(fields[3])
        table.insert(face_vertices, geom.vertex(
          vertices[tonumber(fields[1])],
          normal_index and vertex_normals[normal_index] or nil))
      end

      table.insert(faces, geom.face(face_vertices))
      --for _, v in ipairs(face_vertices) do
      --  for _, c in ipairs(v) do
      --    io.write(tostring(c), ',')
      --  end
      --  io.write('\t')
      --end
      --io.write('\n')
    end
  end

  file:close()

  return faces
end

return {parse = parse}
