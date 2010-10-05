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
  local faces = {}

  local default_texture_vertex = {0, 0}

  for line in file:lines() do
    -- tokenize
    local tokens = tokenize(line, '[^ ]+')
    --print(line)
    
    if tokens[1] == 'v' then
      table.insert(vertices, {
        tonumber(tokens[2]),
        tonumber(tokens[3]),
        tonumber(tokens[4])
      })
    elseif tokens[1] == 'vt' then
      table.insert(texture_vertices, {
        tonumber(tokens[2]),
        tonumber(tokens[3])
      })
    elseif tokens[1] == 'f' then
      local face_vertices = {}
      local face_texture_vertices = {}

      for i = 2, #tokens do
        local fields = tokenize(tokens[i], '[^/]+')
        table.insert(
          face_vertices,
          vertices[tonumber(fields[1])])
        table.insert(
          face_texture_vertices,
          texture_vertices[tonumber(fields[2])] or default_texture_vertex)
      end

      table.insert(faces, {
        vertices = face_vertices,
        texture_vertices = face_texture_vertices
      })
      for _, v in ipairs(face_vertices) do
        for _, c in ipairs(v) do
          --io.write(tostring(c), ',')
        end
        --io.write('\t')
      end
      --io.write('\n')
    end
  end

  file:close()

  return faces
end

return {parse = parse}
