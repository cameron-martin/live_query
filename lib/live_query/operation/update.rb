module LiveQuery
  class Operation
    class Update < Operation

      attr_reader :table_name, :old_row, :new_row

      def initialize(table_name, old_row, new_row)
        @table_name = table_name
        @old_row = old_row
        @new_row = new_row
      end


    end
  end
end
