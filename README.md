[![Version      ](https://img.shields.io/gem/v/deleted_at.svg?maxAge=2592000)](https://rubygems.org/gems/deleted_at)
[![Build Status ](https://travis-ci.org/TwilightCoders/deleted_at.svg)](https://travis-ci.org/TwilightCoders/deleted_at)
[![Code Climate ](https://codeclimate.com/github/TwilightCoders/deleted_at/badges/gpa.svg)](https://codeclimate.com/github/TwilightCoders/deleted_at)
[![Test Coverage](https://codeclimate.com/github/TwilightCoders/deleted_at/badges/coverage.svg)](https://codeclimate.com/github/TwilightCoders/deleted_at/coverage)

# DeletedAt

Deleting data is never good. A common solution is to use `default_scope`, but conventional wisdom (and for good reason) deams this a bad practice. So how do we achieve the same effect with minimal intervention. What we're looking for is the cliche "clean" solution.

DeletedAt leverages the power of SQL views to achieve the same effect. It also takes advantage of Ruby's flexibility.

## Requirements

`DeletedAt` requires PostgreSQL 9.1+ and Ruby 2.0.0+ (as the `pg` gem requires Ruby 2.0.0).

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

Using `DeletedAt` is very simple. It follows a familiar pattern seen throughout the rest of the Ruby/Rails community.

```ruby
class User < ActiveRecord::Base
  # Feel free to include/extend other modules before or after, as you see fit...

  with_deleted_at

  # the rest of your model code...
end
```

You'll (probably) need to migrate your database for `deleted_at` to work properly.

```ruby
class AddDeletedAtColumnToUsers < ActiveRecord::Migration

  def up
    add_column :users, :deleted_at, 'timestamp with time zone'

    DeletedAt.install(User)
  end

  def down
    DeletedAt.uninstall(User)

    remove_column :users, :deleted_at, 'timestamp with time zone'
  end

end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/deleted_at. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
