# LiveQuery

Library to fire events when your data changes. This is useful when wanting to, for example, update your UI in real-time.

This is a very early prototype, and currently only supports postgres. It uses postgres triggers and notifications.

## Installation

Add this line to your application's Gemfile:

    gem 'live_query'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install live_query

## Usage

### How it should work in the future

```ruby
LiveQuery.subscribe('SELECT * FROM products') do |events|
  events.add do |row|

  end

  events.remove do |row|

  end

  events.change do |old_row, new_row|

  end
end
```

### How it works now

This is where I'm at so far

```ruby

conn = PG.connect( ... )

migration = LiveQuery::Migration.new(conn)
migration.up # Migrate database, adding triggers to all tables, and creating a live_query_log table
migration.down # Undo all changes made to the database by LiveQuery, including dropping the live_query_log table


LiveQuery::ChangesServer.new(conn) do |operation|
  # Yields Operation objects.
end

```


## Contributing

1. Fork it ( https://github.com/cameron-martin/live_query/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
