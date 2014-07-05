require 'dotenv'

require 'live_query'
require 'fixtures'

Dotenv.load


# Clean the database before running tests
conn = LiveQuery::Fixtures.create_connection

LiveQuery::Migration.new(conn).down
LiveQuery::Fixtures.new(conn).drop_all_tables