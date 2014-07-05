module LiveQuery
  class Migration

    def initialize(connection)
      @connection = connection
    end

    def up
      create_log_table
      create_function
      create_all_triggers
    end

    def down
      remove_all_triggers
      remove_function
      remove_log_table
    end

    def create_function
      @connection.exec <<-SQL
        CREATE FUNCTION live_query_logger() RETURNS TRIGGER AS $$
          DECLARE
            log_id varchar;
          BEGIN

            IF (TG_OP = 'DELETE') THEN
              INSERT INTO live_query_log ( table_name, operation, old_row ) VALUES ( TG_TABLE_NAME, TG_OP, hstore(OLD.*) ) RETURNING id INTO log_id;
              PERFORM pg_notify('live_query_operation', log_id);
              RETURN OLD;
            ELSIF (TG_OP = 'UPDATE') THEN
              INSERT INTO live_query_log ( table_name, operation, old_row, new_row ) VALUES ( TG_TABLE_NAME, TG_OP, hstore(OLD.*), hstore(NEW.*) ) RETURNING id INTO log_id;
              PERFORM pg_notify('live_query_operation', log_id);
              RETURN NEW;
            ELSIF (TG_OP = 'INSERT') THEN
              INSERT INTO live_query_log ( table_name, operation, new_row ) VALUES ( TG_TABLE_NAME, TG_OP, hstore(NEW.*) ) RETURNING id INTO log_id;
              PERFORM pg_notify('live_query_operation', log_id);
              RETURN NEW;
            END IF;


          END;
        $$ LANGUAGE plpgsql;

      SQL
    end

    def remove_function
      @connection.exec("DROP FUNCTION IF EXISTS live_query_logger()")
    end

    def create_log_table
      @connection.exec <<-SQL
        CREATE TABLE live_query_log (
          id SERIAL,
          table_name varchar,
          operation varchar,
          old_row hstore,
          new_row hstore
        );
      SQL
    end

    def remove_log_table
      @connection.exec <<-SQL
        DROP TABLE IF EXISTS live_query_log;
      SQL
    end

    def create_triggers(*tables)

      tables.each do |table|
        @connection.exec <<-SQL
          CREATE TRIGGER live_query_#{table}_trigger AFTER INSERT OR UPDATE OR DELETE ON #{table}
          FOR EACH ROW EXECUTE PROCEDURE live_query_logger();
        SQL
      end

    end

    def remove_triggers(*tables)
      tables.each do |table|
        @connection.exec("DROP TRIGGER IF EXISTS live_query_#{table}_trigger ON #{table}")
      end
    end

    def remove_all_triggers
      remove_triggers(*get_tables)
    end

    def create_all_triggers
      create_triggers(*get_tables)
    end

    def get_tables
      @connection.exec("SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_name != 'live_query_log'") do |result|
        result.column_values(0)
      end
    end


  end
end