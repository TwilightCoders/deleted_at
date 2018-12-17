require "spec_helper"

describe DeletedAt::ActiveRecord do

  it 'should let other missing consts through' do
    expect{ Admin::Blarg }.to raise_error(NameError)
  end

  it 'should use the table_alias if given' do
    inner_query = User.where(User.arel_table[:name].eq('bob')).as('bobs')
    sql = User.select(inner_query[:name]).from(inner_query).to_sql

    expect(sql).to match(Regexp.new(<<~SQL.squish))
      WITH "users" AS
        \\(SELECT "users"\\.\\* FROM "users" WHERE "users"\\."deleted_at" IS NULL\\)
          SELECT bobs\\."name" FROM
          \\(SELECT "users"\\.\\* FROM "users" WHERE "users"\\."name" = 'bob'\\) bobs
    SQL
  end

  it 'ensure projection is present' do
    inner_query = User.select(:name).where(name: 'bob').as('bobs')
    results = User.select(inner_query[:name]).from(inner_query)
    sql = results.to_sql

    expect(sql).to match(Regexp.new(<<~SQL.squish))
      WITH "users" AS
        \\(SELECT "users".\\* FROM "users" WHERE "users"."deleted_at" IS NULL\\)
          SELECT bobs."name" FROM
            \\(SELECT "users"."name" FROM "users" WHERE "users"."name" = \\$1\\) bobs
    SQL
  end

  it 'does not affect insert and deletion' do
    expect{ User.create(name: 'bobby') }.to_not raise_error
  end

  it 'does arel properly' do
    inner_query = User::All.where(name: 'bob').merge(Admin.where(name: 'john'))
    # Admin.where(name: 'john').to_sql
    # User::All.where(name: 'bob').merge(Admin.where(name: 'john')).to_sql

    sql1 = User.select(inner_query[:name]).from(inner_query.arel).to_sql
    sql2 = User.select(inner_query[:name]).from(inner_query, 'admin_users').to_sql
    expect(sql1).to eq(sql2)
  end

  it 'should allow for deep nesting with deleted_at scope being maintained' do
    # inner_query = User.all.from(User.where(name: 'bob').from(Admin.where(name: 'john').arel, 'johns').arel.as('johns')).as('bobs')
    User.where(name: 'bob').as('foo')
    # So, here's the deal. Rails (ActiveRecord, or Arel more specifically) in it's infinite wisdom,
    # doesn't think to use the table name
    Admin.connection.unprepared_statement do
      inner_query = User.from(User.where(name: 'bob').merge(Admin.where(name: 'john')), 'users')
      inner = inner_query.as('admin_users')
      sql = User.select(inner[:name]).from(inner).to_sql
    end

    sql_regex = Regexp.new(<<~SQL.squish)
      WITH "users" AS \\(SELECT "users".\\* FROM "users" WHERE "users"."deleted_at" IS NULL\\)
      SELECT bobs."name" FROM
      \\(SELECT "users".* FROM
        \\(SELECT "users".* FROM
          \\(WITH "users" AS
            \\(SELECT "users"."id", "users"."kind" FROM "users" WHERE "users"."deleted_at" IS NULL\\)
              SELECT "users"."id", "users"."kind" FROM "users" WHERE "users"."kind" = 1 AND "users"."name" = 'bob') johns
                WHERE "users"."name" = 'john') bobs_not_johns\\) bobs
    SQL

    expect(sql).to match(sql_regex)
  end

end
