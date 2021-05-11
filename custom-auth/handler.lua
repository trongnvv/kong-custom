local http = require "resty.http"
local utils = require "kong.tools.utils"
local inspect = require "inspect"
local TokenHandler = {
    VERSION = "1.0",
    PRIORITY = 1000
}

local function introspect_access_token(conf, access_token)
    local httpc = http:new()

    -- step 2: validate the customer access rights
    local res, err = httpc:request_uri(conf.authorization_endpoint, {
        method = "GET",
        ssl_verify = false,
        headers = {
            -- ["Content-Type"] = "application/json",
            ["Authorization"] = access_token
        }
    })

    if not res then
        kong.log.err("failed to call authorization endpoint: ", err)
        return kong.response.exit(500)
    end
    if res.status ~= 200 then
        kong.log.err("authorization endpoint responded with status: ", res.status)
        return kong.response.exit(500)
    end

    return true -- all is well
end

function TokenHandler:access(conf)
    local access_token = ngx.req.get_headers()[conf.token_header]
    if not access_token then
        kong.response.exit(401) -- unauthorized
    end
    introspect_access_token(conf, access_token)

    kong.service.request.clear_header(conf.token_header)
end

return TokenHandler
