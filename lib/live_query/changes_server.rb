module LiveQuery
  class ChangesServer
    def initialize(conn, &block)
      @conn = conn
      @notifications_server = NotificationsServer.new(@conn)

      receive(&block) if block_given?
    end

    def receive(n=nil)
      @notifications_server.receive(n) do |payload|
        id = payload.to_i
        yield operation_by_id(id)
      end
    end

  private

    def operation_by_id(id)
      @conn.exec("SELECT * FROM live_query_log WHERE id = #{id} LIMIT 1") do |result|
        raise 'Cannot find operation' if result.ntuples < 1

        OperationBuilder.build(result[0])
      end
    end

  end
end