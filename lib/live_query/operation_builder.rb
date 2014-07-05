module LiveQuery
  class OperationBuilder

    def self.build(hash)
      new(hash).build
    end

    def initialize(hash)
      @hash = hash
    end

    def build
      case operation
        when 'INSERT'
          Operation::Insert.new(table_name, new_row)
        when 'UPDATE'
          Operation::Update.new(table_name, old_row, new_row)
        when 'DELETE'
          Operation::Delete.new(table_name, old_row)
        else
          raise 'Invalid operation'
      end
    end

  private

    def operation
      @hash['operation']
    end

    def table_name
      @hash['table_name']
    end

    def old_row
      hstore_field('old_row')
    end

    def new_row
      hstore_field('new_row')
    end

    def hstore_field(field)
      symbolize_keys(PgHstore.load(@hash[field]))
    end

    def symbolize_keys(hash)
      Hash[hash.map {|k, v| [k.to_sym, v] }]
    end

  end
end