require 'spec_helper'

describe LiveQuery::NotificationsServer do

  let(:conn_send) { LiveQuery::Fixtures.create_connection }

  let(:conn_rec) { LiveQuery::Fixtures.create_connection }
  let(:notification_receiver) { LiveQuery::NotificationsServer.new(conn_rec) }

  describe '#run' do

    it 'returns payload after being notified' do

      Thread.new do
        sleep(0.1) # HACK: Tests based on timing
        conn_send.exec("NOTIFY live_query_operation, 'payload'")
      end

      payloads = []

      Timeout::timeout(1) do
        notification_receiver.receive(1) do |payload|
          payloads << payload
        end
      end

      expect(payloads).to eq(['payload'])

    end

  end

end