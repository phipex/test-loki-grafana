-- Definimos una tabla para guardar los valores de a y b
local valoresCPU = {a = {}, b = {}}
local valoresMEN = {a = {}, b = {}}

local cantidadMaxima = 5

local limit_system_p = 40
local limit_user_p = 85

local limit_swag = 30
local limit_men = 95


-- Definimos una función para calcular el promedio de una tabla
local function promedio(t)
  local suma = 0
  for _, v in ipairs(t) do
    suma = suma + v
  end
  return suma / #t
end

-- Definimos la función que recibe a y b
local function promedioTabla(a, b,valores)
  -- Añadimos los valores a la tabla correspondiente
  table.insert(valores.a, a)
  table.insert(valores.b, b)
  -- Contamos cuántas veces se ha llamado a la función
  local llamadas = #valores.a
  -- Si se ha llamado cinco veces, calculamos los promedios y los retornamos
  if llamadas % cantidadMaxima == 0 then
    local promedio_a = promedio(valores.a)
    local promedio_b = promedio(valores.b)
    -- Vaciamos las tablas para empezar de nuevo
    valores.a = {}
    valores.b = {}
    return promedio_a, promedio_b
  end
end

function promedioCPU(tag, timestamp, record)
    --print("timestamp",timestamp)
    --print("tag",tag)
    --tprint(record)
    local user_p = record["user_p"]
    local system_p = record["system_p"]
    --print(user_p,system_p)
    local avg_user_p, avg_system_p = promedioTabla(user_p,system_p,valoresCPU)
    --tprint(valoresCPU)
    if avg_user_p and avg_system_p then
        
        local resultado = {}
        resultado["avg_user_p"]=avg_user_p
        resultado["avg_system_p"]=avg_system_p
        tprint(resultado)
        return 1, timestamp, resultado
    else
        return -1, 0, 0 -- drop the log
    end
end

function promedioMen(tag, timestamp, record)
  --print("timestamp",timestamp)
  --print("tag",tag)
  --tprint(record)
  local swap = record["swap"]
  local men = record["men"]
  --print(user_p,system_p)
  local avg_swap, avg_men = promedioTabla(swap,men,valoresMEN)
  --tprint(valoresCPU)
  if avg_swap and avg_men then
      
      local resultado = {}
      resultado["avg_swap"]=avg_swap
      resultado["avg_men"]=avg_men
      tprint(resultado)
      return 1, timestamp, resultado
  else
      return -1, 0, 0 -- drop the log
  end
end


function avgMaxCpu(tag, timestamp, record)
    local code, timestamp, record = promedioCPU(tag, timestamp, record)
    if code ~= 1 then
      return -1, 0, 0 -- drop the log
    end
        
    local user_p = record["avg_user_p"]
    local system_p = record["avg_system_p"]  
    if(user_p >= limit_user_p or system_p >=limit_system_p) then
      return code, timestamp, record
    else
      return -1, 0, 0 -- drop the log
    end
end

function avgMaxMen(tag, timestamp, record)
  tprint(record)
  local new_record = record
  local swapTotal = record["Swap.total"]
  local swapUsed = record["Swap.used"]
  new_record["swap"] = (100*swapUsed)/swapTotal
  print(  new_record["swap"] , swapUsed ,swapTotal)


  local menTotal = record["Mem.total"]
  local menFree = record["Mem.free"]
  local menUsed = menTotal-menFree
  new_record["men"] = (100*menUsed)/menTotal
  print(new_record["men"] , menUsed,menTotal)

  local code, timestamp, record = promedioMen(tag, timestamp, new_record)
  if code ~= 1 then
    return -1, 0, 0 -- drop the log
  end
  --tprint(record)
  --print(limit_swag, limit_men)    
  local swag = record["avg_swap"]
  local men = record["avg_men"]
  print(swag , limit_swag , men , limit_men)  
--  if(swag >= limit_swag or men >= limit_men) then
  if(swag >= limit_swag) then
    return code, timestamp, record
  else
    return -1, 0, 0 -- drop the log
  end
end



function printTable(table)
    for index, data in ipairs(table) do
        print(index)
    
        for key, value in pairs(data) do
            print('\t', key, value)
        end
    end
end


function append_tag(tag, timestamp, record)
  print("timestamp",timestamp)
  print("tag",tag)
  tprint(record)
  new_record = record
  new_record["tag"] = tag
  return 1, timestamp, new_record
end

function tprint (t, s)
  for k, v in pairs(t) do
      local kfmt = '["' .. tostring(k) ..'"]'
      if type(k) ~= 'string' then
          kfmt = '[' .. k .. ']'
      end
      local vfmt = '"'.. tostring(v) ..'"'
      if type(v) == 'table' then
          tprint(v, (s or '')..kfmt)
      else
          if type(v) ~= 'string' then
              vfmt = tostring(v)
          end
          print(type(t)..(s or '')..kfmt..' = '..vfmt)
      end
  end
end
