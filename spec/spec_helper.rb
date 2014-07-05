require 'dotenv'

require 'live_query'

Dotenv.load

module LiveQuery
  class Fixtures

    class Rollback < RuntimeError; end

    def self.create_connection
      PG.connect host: ENV['PG_HOST'], user: ENV['PG_USER'], password: ENV['PG_PASS'], dbname: ENV['PG_DB']
    end

    def initialize(conn)
      @conn = conn
    end

    def rollback

      begin
        @conn.transaction do |_|
          yield
          raise Rollback
        end
      rescue Rollback; end

    end

    def create_table(name, fields=['col varchar'])
      @conn.exec("CREATE TABLE #{name} ( #{fields.join(', ')} )")
    end

    def insert(table_name, relation)
      numbered_values = 1.upto(relation.count).map { |n| "$#{n}" }.join(', ')
      @conn.exec_params("INSERT INTO #{table_name} (#{relation.keys.join(', ')}) VALUES ( #{numbered_values} ) ", relation.values)
    end

    def drop_table(name)
      @conn.exec("DROP TABLE #{name}")
    end

  end
end