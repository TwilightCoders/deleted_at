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

  it 'should allow for deep nesting with deleted_at scope being maintained' do
    inner_query = User.all.from(User.where(name: 'bob').from(Admin.where(name: 'john'), 'johns').as('johns')).as('bobs')
    sql = User.select(inner_query[:name]).from(inner_query).to_sql

    sql_regex = Regexp.new(<<~SQL.squish)
      WITH "users" AS \\(SELECT "users".\\* FROM "users" WHERE "users"."deleted_at" IS NULL\\)
      SELECT bobs."name" FROM
      \\(SELECT "users".* FROM
        \\(SELECT "users".* FROM
          \\(WITH "users" AS
            \\(SELECT "users"."id", "users"."kind" FROM "users" WHERE "users"."deleted_at" IS NULL\\)
              SELECT "users"."id", "users"."kind" FROM "users" WHERE "users"."kind" = \\$1 AND "users"."name" = \\$2\\) johns
                WHERE "users"."name" = \\$3\\) johns\\) bobs
    SQL

    expect(sql).to match(sql_regex)
  end

end
