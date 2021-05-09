return {
    postgres = {
        up = [[
          CREATE TABLE IF NOT EXISTS "custom_plugin" (
            "id"           UUID                         PRIMARY KEY,
            "created_at"   TIMESTAMP WITH TIME ZONE     DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'),
            "consumer_id"  UUID                         REFERENCES "consumers" ("id") ON DELETE CASCADE,
            "key"          TEXT                         UNIQUE
          );

          DO $$
          BEGIN
            CREATE INDEX IF NOT EXISTS "custom_plugin_consumer_id_idx" ON "custom_plugin" ("consumer_id");
          EXCEPTION WHEN UNDEFINED_COLUMN THEN
            -- Do nothing, accept existing state
          END$$;

          DO $$
          BEGIN
            ALTER TABLE IF EXISTS ONLY custom_plugin ADD tags TEXT[];
          EXCEPTION WHEN DUPLICATE_COLUMN THEN
            -- Do nothing, accept existing state
          END$$;

          DO $$
          BEGIN
            CREATE INDEX IF NOT EXISTS keyauth_tags_idex_tags_idx ON custom_plugin USING GIN(tags);
          EXCEPTION WHEN UNDEFINED_COLUMN THEN
            -- Do nothing, accept existing state
          END$$;

          DROP TRIGGER IF EXISTS keyauth_sync_tags_trigger ON custom_plugin;

          DO $$
          BEGIN
            CREATE TRIGGER keyauth_sync_tags_trigger
            AFTER INSERT OR UPDATE OF tags OR DELETE ON custom_plugin
            FOR EACH ROW
            EXECUTE PROCEDURE sync_tags();
          EXCEPTION WHEN UNDEFINED_COLUMN OR UNDEFINED_TABLE THEN
            -- Do nothing, accept existing state
          END$$;

          DO $$
          BEGIN
            ALTER TABLE IF EXISTS ONLY "custom_plugin" ADD "ttl" TIMESTAMP WITH TIME ZONE;
          EXCEPTION WHEN DUPLICATE_COLUMN THEN
            -- Do nothing, accept existing state
          END$$;

          DO $$
          BEGIN
            CREATE INDEX IF NOT EXISTS custom_plugin_ttl_idx ON custom_plugin (ttl);
          EXCEPTION WHEN UNDEFINED_TABLE THEN
            -- Do nothing, accept existing state
          END$$;
        ]]
    },
    cassandra = {
        up = [[
          CREATE TABLE IF NOT EXISTS custom_plugin(
            id          uuid PRIMARY KEY,
            created_at  timestamp,
            consumer_id uuid,
            key         text
          );
          CREATE INDEX IF NOT EXISTS ON custom_plugin(key);
          CREATE INDEX IF NOT EXISTS ON custom_plugin(consumer_id);
        ]]
    }
}
