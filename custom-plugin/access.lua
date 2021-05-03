local _M = {}

function _M.execute(conf)
    kong.log('trongnv: ', kong.request.get_header('auth'))
end

return _M
