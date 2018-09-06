require "spec_helper"

describe DeletedAt::ActiveRecord do

  it 'should let other missing consts through' do
    expect{ Admin::Blarg }.to raise_error(NameError)
  end

  it 'should use the table_alias if given' do
    inner_query = User.where(name: 'bob').as('bobs')
    sql = User.select(inner_query[:name]).from(inner_query).to_sql

    expect(sql).to eql(<<~SQL.squish)
      SELECT bobs."name" FROM (SELECT "users".* FROM "users" WHERE "users"."deleted_at" IS NULL) bobs
    SQL
  end

  it 'should allow for deep nesting with deleted_at sub-select as most inner query' do
    inner_query = User.all.from(User.where(name: 'bob').from(Admin.where(name: 'john'), 'johns').as('johns')).as('bobs')
    sql = User.select(inner_query[:name]).from(inner_query).to_sql

    expect(sql).to eql(<<~SQL.squish)
      SELECT bobs."name"
        FROM (SELECT "users".*
          FROM (SELECT "users".*
            FROM (SELECT "users"."id", "users"."kind"
              FROM (SELECT "users".* FROM "users" WHERE "users"."deleted_at" IS NULL)
                "users"
              WHERE "users"."kind" = 1 AND "users"."name" = 'john')
              johns
            WHERE "users"."name" = 'bob')
          johns)
        bobs
    SQL
  end

  it 'should let other missing consts through' do
    binding.pry
    User.all.as('foo')
    sql = User.from(User.where(name: 'foo'), 'users').to_sql

    expect(sql).to match(Regexp.new <<~SQL.squish
      SELECT .* FROM
        (SELECT .* FROM
          (SELECT .* FROM "comments"
            WHERE "comments"."deleted_at" IS NULL)
          WHERE "comments"."title" = 'foo') comments
      SQL
    )
  end

end
