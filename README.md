# LiveQuery

Provides live database queries

## Installation

Add this line to your application's Gemfile:

    gem 'live_query'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install live_query

## Usage

```ruby
result_set = LiveQuery.execute('SELECT * FROM products') do |events|
  events.add do |row|

  end

  events.remove do |row|

  end

  events.change do |old_row, new_row|

  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/live_query/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
