local http = require "resty.http"
local inspect = require "inspect"
local json = require('cjson')
local TokenHandler = {
    VERSION = "1.0",
    PRIORITY = 1000
}

local function get_access_token(conf, access_token)
    local httpc = http:new()

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

    return res
end

function TokenHandler:access(conf)
    if (conf.public_path) then
        for _, value in pairs(conf.public_path) do

            if kong.request.get_path() == value then
                kong.log("next ", value)
                return
            end
        end
    end
    local access_token = ngx.req.get_headers()[conf.token_header]
    if not access_token then
        kong.response.exit(401, {
            success = false,
            message = 'Unauthorized'
        })
    end
    local res, err = get_access_token(conf, access_token)
    local user = json.decode(res.body).data;
    local user_info = {
        userID = user._id,
        username = user.username
    }
    kong.log('key_add_header ', conf.key_add_header)
    kong.log('data_add_header ', json.encode(user_info))
    kong.service.request.set_header(conf.key_add_header, json.encode(user_info))
end

return TokenHandler
