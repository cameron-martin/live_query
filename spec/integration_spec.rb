require 'timeout'
require 'spec_helper'

describe 'Integration' do

  let(:conn_send) { LiveQuery::Fixtures.create_connection }
  let(:migration) { LiveQuery::Migration.new(conn_send) }
  let(:fixtures) { LiveQuery::Fixtures.new(conn_send) }

  let(:conn_rec) { LiveQuery::Fixtures.create_connection }
  let(:notification_receiver) { LiveQuery::NotificationReceiver.new(conn_rec) }

  before(:each) do
    fixtures.create_table(:test_table, ['col varchar'])
    migration.up
  end

  after(:each) do
    migration.down
    fixtures.drop_table(:test_table)
  end

  describe 'notification receiver' do

    it 'yields an id when rows are inserted' do

      Thread.new do
        sleep(0.1) # HACK: Tests based on timing
        fixtures.insert(:test_table, { col: 'test' })
      end

      payloads = []

      Timeout::timeout(1) do
        notification_receiver.receive(1) do |payload|
          payloads << payload
        end
      end

      expect(payloads.first).to match(/[0-9]+/)

    end

  end

end