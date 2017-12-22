[![Version      ](https://img.shields.io/gem/v/deleted_at.svg?maxAge=2592000)](https://rubygems.org/gems/deleted_at)
[![Build Status ](https://travis-ci.org/TwilightCoders/deleted_at.svg)](https://travis-ci.org/TwilightCoders/deleted_at)
[![Code Climate ](https://api.codeclimate.com/v1/badges/762cdcd63990efa768b0/maintainability)](https://codeclimate.com/github/TwilightCoders/deleted_at/maintainability)
[![Test Coverage](https://codeclimate.com/github/TwilightCoders/deleted_at/badges/coverage.svg)](https://codeclimate.com/github/TwilightCoders/deleted_at/coverage)
[![Dependencies ](https://gemnasium.com/badges/github.com/TwilightCoders/deleted_at.svg)](https://gemnasium.com/github.com/TwilightCoders/deleted_at)

# DeletedAt

Deleting data is never good. A common solution is to use `default_scope`, but conventional wisdom (and for good reason) deams this a bad practice. So how do we achieve the same effect with minimal intervention. What we're looking for is the cliche "clean" solution.

DeletedAt leverages the power of SQL views to achieve the same effect. It also takes advantage of Ruby's flexibility.

## Requirements

`DeletedAt` requires PostgreSQL 9.1+ and Ruby 2.0+ (as the `pg` gem requires Ruby 2.0.0).

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

To work properly, the tables that back these models must have a `deleted_at` timestamp column. Additionally, you'll (probably) need to set up the views for each particular model. This is done by invoking `DeletedAt.install(YourModel)`. _(Note the order of operations below for migrating up and down)_

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

If you're starting with a brand-new table, the existing `timestamps` DSL has been extended to accept `deleted_at: true` as an option, for convenience. Or you can do it seperately as shown above.

```ruby
class CreatCommentsTable < ActiveRecord::Migration

  def up
    create_table :comments do |t|
      # ...
      #  to the `timestamps` DSL
      t.timestamps null: false, deleted_at: true
    end

    DeletedAt.install(Comment)
  end

  def down
    DeletedAt.uninstall(Comment)

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
