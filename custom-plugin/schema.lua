local typedefs = require "kong.db.schema.typedefs"

return {
    name = "custom-plugin",
    fields = {{
        consumer = typedefs.no_consumer
    }, {
        protocols = typedefs.protocols_http
    }, {
        config = {
            type = "record",
            fields = {{
                say_hello = {
                    type = "boolean",
                    default = true
                }
            }}
        }
    }}
}
