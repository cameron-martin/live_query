module LiveQuery
  class Operation
    class Insert < Operation

      attr_reader :table_name, :row

      def initialize(table_name, row)
        @table_name = table_name
        @row = row
      end


    end
  end
end
