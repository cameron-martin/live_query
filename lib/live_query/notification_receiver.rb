module LiveQuery
  class NotificationReceiver

    def initialize(connection)
      @connection = connection
      @channel = 'live_query_operation' # TODO: Have some sort of global configuration for this
    end

    def receive(n=nil)
      start_listening
      if n
        n.times { yield receive_payload }
      else
        loop { yield receive_payload }
      end
    ensure
      stop_listening
    end

  private

    def start_listening
      @connection.exec("LISTEN #{@channel}");
    end

    def stop_listening
      @connection.exec("UNLISTEN #{@channel}");
    end

    def receive_payload
      @connection.wait_for_notify do |channel, pid, payload|
        next unless channel == @channel
        return payload
      end
    end

  end
end