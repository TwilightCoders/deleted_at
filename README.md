[![Version      ](https://img.shields.io/gem/v/deleted_at.svg?maxAge=2592000)](https://rubygems.org/gems/deleted_at)
[![Build Status ](https://travis-ci.org/TwilightCoders/deleted_at.svg)](https://travis-ci.org/TwilightCoders/deleted_at)
[![Code Climate ](https://api.codeclimate.com/v1/badges/762cdcd63990efa768b0/maintainability)](https://codeclimate.com/github/TwilightCoders/deleted_at/maintainability)
[![Test Coverage](https://codeclimate.com/github/TwilightCoders/deleted_at/badges/coverage.svg)](https://codeclimate.com/github/TwilightCoders/deleted_at/coverage)
[![Dependencies ](https://gemnasium.com/badges/github.com/TwilightCoders/deleted_at.svg)](https://gemnasium.com/github.com/TwilightCoders/deleted_at)

# DeletedAt

Hide your "deleted" data (unless specifically asked for) without resorting to `default_scope` by leveraging in-line sub-selects.

## Requirements

- Ruby 2.3+
- ActiveRecord 4.2+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deleted_at'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deleted_at

## Usage

Invoking `with_deleted_at` sets the class up to use the `deleted_at` functionality.

```ruby
class User < ActiveRecord::Base
  with_deleted_at

  # the rest of your model code...
end
```

To work properly, the tables that back these models must have a `deleted_at` timestamp column.

```ruby
class AddDeletedAtColumnToUsers < ActiveRecord::Migration

  def up
    add_column :users, :deleted_at, 'timestamp with time zone'
  end

  def down
    remove_column :users, :deleted_at, 'timestamp with time zone'
  end

end
```

If you're starting with a brand-new table, the existing `timestamps` DSL has been extended to accept `deleted_at: true` as an option, for convenience. Or you can do it seperately as shown above.

```ruby
class CreatCommentsTable < ActiveRecord::Migration

  def up
    create_table :comments do |t|
      # ...
      #  to the `timestamps` DSL
      t.timestamps null: false, deleted_at: true
    end
  end

  def down
    drop_table :comments
  end

end
```

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `bundle exec rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TwilightCoders/deleted_at. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
