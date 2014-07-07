require 'spec_helper'

describe LiveQuery::Migration do

  let(:conn) { LiveQuery::Fixtures.create_connection }
  let(:migration) { LiveQuery::Migration.new(conn) }
  let(:fixtures) { LiveQuery::Fixtures.new(conn) }

  describe '#create_log_table' do

    it 'does not raise error' do
      fixtures.rollback do
        expect { migration.create_log_table }.to_not raise_error
      end
    end

    it 'creates log table' do
      fixtures.rollback do
        migration.create_log_table

        expect(fixtures.table_exists?(:live_query_log)).to eq(true)
      end
    end

  end

  describe '#create_function' do
    it 'does not raise error' do
      fixtures.rollback do
        expect { migration.create_function }.to_not raise_error
      end
    end
  end


  describe '#create_triggers' do
    it 'does not raise error' do
      fixtures.rollback do
        fixtures.create_table(:test_table)
        migration.create_function

        expect { migration.create_triggers(:test_table) }.to_not raise_error
      end
    end
  end

  describe '#up' do
    it 'does not raise error' do
      fixtures.rollback do
        fixtures.create_table(:test_table)

        expect { migration.up }.to_not raise_error
      end
    end

    it 'does not raise error after full cycle' do
      fixtures.rollback do
        fixtures.create_table(:test_table)
        migration.up
        migration.down

        expect { migration.up }.to_not raise_error
      end
    end
  end


  describe '#down' do
    it 'does not raise error' do
      fixtures.rollback do
        fixtures.create_table(:test_table)
        migration.up

        expect { migration.down }.to_not raise_error
      end
    end
  end

  describe '#get_tables' do

    it 'returns empty list when no tables' do
      expect(migration.get_tables).to eq([])
    end

    it 'returns tables when present' do
      fixtures.rollback do
        fixtures.create_table(:test_table)

        expect(migration.get_tables).to eq(['test_table'])
      end
    end

    it 'excludes live_query_log table' do
      fixtures.rollback do
        fixtures.create_table(:live_query_log)

        expect(migration.get_tables).to eq([])
      end
    end

  end
end