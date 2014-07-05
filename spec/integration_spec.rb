require 'timeout'
require 'spec_helper'

describe 'Integration' do

  let(:conn_send) { LiveQuery::Fixtures.create_connection }
  let(:migration) { LiveQuery::Migration.new(conn_send) }
  let(:fixtures) { LiveQuery::Fixtures.new(conn_send) }

  let(:conn_rec) { LiveQuery::Fixtures.create_connection }
  let(:changes_server) { LiveQuery::ChangesServer.new(conn_rec) }

  before(:each) do
    fixtures.create_table(:test_table, ['col varchar'])
    migration.up
  end

  after(:each) do
    migration.down
    fixtures.drop_table(:test_table)
  end

  # Sets up a server to receive an operation, and triggers it in a different thread, then returns the operation.

  def receive_operation(server)
    Thread.new do
      sleep(0.1) # HACK: Tests based on timing
      yield
    end

    operations = []

    Timeout::timeout(1) do
      server.receive(1) do |operation|
        operations << operation
      end
    end

    operations.first

  end

  describe 'changes server' do

    it 'yields an insert operation when rows are inserted' do

      operation = receive_operation(changes_server) { fixtures.insert(:test_table, { col: 'test' }) }

      expect(operation).to be_a(LiveQuery::Operation::Insert)
      expect(operation.row).to eq({ col: 'test' })


    end

    it 'yields a delete operation when rows are deleted' do

      fixtures.insert(:test_table, { col: 'test' })

      operation = receive_operation(changes_server) { conn_send.exec("DELETE FROM test_table WHERE col='test'") }

      expect(operation).to be_a(LiveQuery::Operation::Delete)
      expect(operation.row).to eq({ col: 'test' })


    end

    it 'yields a update operation when rows are updated' do

      fixtures.insert(:test_table, { col: 'test' })

      operation = receive_operation(changes_server) { conn_send.exec("UPDATE test_table SET col='test2' WHERE col='test'") }

      expect(operation).to be_a(LiveQuery::Operation::Update)
      expect(operation.old_row).to eq({ col: 'test' })
      expect(operation.new_row).to eq({ col: 'test2' })


    end



  end

end