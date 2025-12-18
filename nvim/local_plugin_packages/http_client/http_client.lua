local http = require("socket.http")
local ltn12 = require("ltn12")

local function http_request(method, url, data)
    local response_body = {}
    local request_params = {
        method = method,
        url = url,
        sink = ltn12.sink.table(response_body)
    }

    if data then
        request_params.source = ltn12.source.string(data)
        request_params.headers = {
            ["content-length"] = tostring(#data),
            ["content-type"] = "application/x-www-form-urlencoded"
        }
    end

    local _, code, headers, status = http.request(request_params)
    return table.concat(response_body), code, headers, status
end

local http_get = function(url)
    return http_request("GET", url)
end

local http_post = function(url, data)
    return http_request("POST", url, data)
end

-- Example usage:
local url = "http://dynatrace.com"
local response, code, headers, status = http_get(url)
print("GET Response:", response)

local post_data = "key1=value1&key2=value2"
response, code, headers, status = http_post(url, post_data)
print("POST Response:", response)
