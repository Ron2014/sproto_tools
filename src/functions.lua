function string.split(str, delimiter)
    if not str or str == '' then return {} end
    if delimiter == '' then return {} end
    local arr = {}
    for k, v in string.gmatch(str, "[^%"..delimiter.."]+") do
        arr[#arr + 1] = k
    end
    return arr
end

function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

local function urlencodeChar(char)
    return "%" .. string.format("%02X", string.byte(c))
end

function string.urlencode(str)
    -- convert line endings
    str = string.gsub(tostring(str), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    str = string.gsub(str, "([^%w%.%- ])", urlencodeChar)
    -- convert spaces to "+" symbols
    return string.gsub(str, " ", "+")
end

function string.urldecode(str)
    str = string.gsub (str, "+", " ")
    str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonum(h,16)) end)
    str = string.gsub (str, "\r\n", "\n")
    return str
end

function string.utf8len(str)
    local len  = #str
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.utf8sub(str, start, last)
	if start > last then
		return ""
	end
    local len  = #str
    local left = len
    local cnt  = 0
	local startByte = len + 1
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
		if cnt == start then
			startByte = len - (left + i) + 1
		end
		if cnt == last then
			return string.sub(str, startByte, len - left)
		end
    end
	return string.sub(str, startByte, len)
end

function string.formatNumberThousands(num)
    local formatted = tostring(tonum(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end


-- 单行打印一个table
function tableToLine(t)
    if type(t) ~= "table" then
        return tostring(t)
    end
    local count = 0
	local index = {}
	for k in pairs(t) do
        table.insert(index, k)
        count = count + 1
    end
    local array = (#t == count)
    table.sort(index, function(a, b) return tostring(a) < tostring(b) end)
    local result = {}
    for _,v in ipairs(index) do
        if array then
            table.insert(result, string.format("%s", tableToLine(t[v])))
        else
            table.insert(result, string.format("%s:%s", v, tableToLine(t[v])))
        end
    end
    if array then
        return string.format("[%s]", table.concat(result, ","))
    else
        return string.format("{%s}", table.concat(result, ","))
    end
end

-- 树形打印一个table
function tableToString(value, desciption, nesting)
    return dumpTable(value, desciption, nesting)
end

local function dump_key_(v)
    if type(v) == "string" then
        v = "[\"" .. v .. "\"]"
    elseif type(v) == "number" then
        v = "[" .. v .. "]"
    end
    return tostring(v)
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v) .. ","
end

function dump(value, desciption, nesting)
    print(dumpTable(value, desciption, nesting, 4))
end

function dumpTable(value, desciption, nesting, tracedeep)
    tracedeep = tracedeep or 3
    if type(nesting) ~= "number" then nesting = 5 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 1), "\n")
    local info = "dump from: " .. string.trim(traceback[tracedeep] or "") .. "\n"

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_key_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_key_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_key_(desciption))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_key_(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_key_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s},", indent)
            end
        end
    end
    dump_(value, desciption, "", 1)


    for i, line in ipairs(result) do
        info = info .. line .. "\n"
    end
    info = string.sub(info, 1, #info - 1)
    return info
end
