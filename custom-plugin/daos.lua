local typedefs = require "kong.db.schema.typedefs"

return {
    custom_plugin_fields = {
        ttl = true,
        primary_key = {"id"},
        name = "custom_plugin",
        endpoint_key = "key",
        cache_key = {"key", "name"},
        workspaceable = true,
        admin_api_name = "key-auths",
        admin_api_nested_name = "key-auth",
        fields = {{
            id = typedefs.uuid
        }, {
            created_at = typedefs.auto_timestamp_s
        }, {
            consumer = {
                type = "foreign",
                reference = "consumers",
                required = true,
                on_delete = "cascade"
            }
        }, {
            key = {
                type = "string",
                required = false,
                unique = true,
                auto = true
            }
        }, {
            name = {
                type = "string",
                required = false,
                unique = true,
                auto = true
            }
        }, {
            tags = typedefs.tags
        }}
    }
}

