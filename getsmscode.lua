local http = require('socket.http')
local socket = require('socket')

getsmscode = {
    endpoint1 = 'http://www.getsmscode.com/do.php?',
    endpoint2 = 'http://www.getsmscode.com/vndo.php?'
}
getsmscode.__index = getsmscode

function getsmscode:in_table(value, tab)
    for _, element in pairs(tab) do
        if element == value then
            return true
        end
    end
    return false
end

function getsmscode:explode(div,str) -- credit: http://richard.warburton.it
  if (div=='') then return false end
  local pos,arr = 0,{}
  -- for each divider found
  for st,sp in function() return string.find(str,div,pos,true) end do
    table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
    pos = sp + 1 -- Jump past current divider
  end
  table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
  return arr
end

function getsmscode:strpos (haystack, needle, offset)  -- credit: https://gist.github.com/cristobal/5346946
  local pattern = string.format("(%s)", needle)
  local i       = string.find (haystack, pattern, (offset or 0))
  
  return (i ~= nil and i or false)
end

function getsmscode:http_build_query(args)
    local first = true
    local str = ''
    for index, element in pairs(args) do
        if not first then
            str = str..'&'..tostring(index)..'='..tostring(element)
        else
            str = str..tostring(index)..'='..tostring(element)
            first = false
        end
    end
    return str
end

function getsmscode:sleep(sec)
    socket.sleep(sec)
end

function getsmscode:req(args, endpoint)
    if not self:in_table(endpoint, {1, 2}) then
        error('Endpoint must be 1 or 2.')
    end
    if endpoint == 1 then
        return http.request(self.endpoint1..self:http_build_query(args))
    elseif endpoint == 2 then
        return http.request(self.endpoint2..self:http_build_query(args))
    end
end

function getsmscode:new(u, t)
    local self = setmetatable({}, getsmscode)
    local res = self:req({action = 'login', username = u, token = t}, 1)
    if res == 'username is wrong' then
        error(res)
    elseif res == 'token is wrong' then
        error(res)
    else
        self.username = u
        self.token = t
    end
    return self
end

function getsmscode:get_balance()
    local res = self:req({action = 'login', username = self.username, token = self.token}, 1)
    local args = self:explode('|', res)
    if args[2] == nil then
        error(req)
    end
    return args[2]
end

function getsmscode:get_number(p_id, co_code)
    if co_code == 'cn' then
        res = self:req({action = 'getmobile', username = self.username, token = self.token, pid = p_id}, 1)
    else
        res = self:req({action = 'getmobile', username = self.username, token = self.token, pid = p_id, cocode = co_code}, 2)
    end
    if tonumber(res) == nil then
        error(res)
    end
    return res
end

function getsmscode:get_sms(number, p_id, co_code)
    if co_code == 'cn' then
        res = self:req({action = 'getsms', username = self.username, token = self.token, pid = p_id, mobile = number, author = self.username}, 1)
    else
        res = self:req({action = 'getsms', username = self.username, token = self.token, pid = p_id, mobile = number, cocode = co_code}, 2)
    end
    if self:strpos(res, '1|') == 1 then
        local replaced, c = string.gsub(res, '1|', '', 1)
        return replaced
    end
    return false
end

function getsmscode:add_blacklist(number, p_id, co_code)
    if co_code == 'cn' then
        res = self:req({action = 'addblack', username = self.username, token = self.token, pid = p_id, mobile = number}, 1)
    else
        res = self:req({action = 'addblack', username = self.username, token = self.token, pid = p_id, mobile = number, cocode = co_code}, 2)
    end
    if res == 'Message|Had add black list' then
        return true
    end
    return false
end

return getsmscode
