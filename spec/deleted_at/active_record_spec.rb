require "spec_helper"

describe DeletedAt::ActiveRecord do

  it 'should let other missing consts through' do
    expect{ Admin::Blarg }.to raise_error(NameError)
  end

  it 'should use the table_alias if given' do
    inner_query = User.where(name: 'bob').as('bobs')
    sql = User.select(inner_query[:name]).from(inner_query).to_sql

    expect(sql).to match(Regexp.new(<<~SQL.squish))
      SELECT bobs\\."name"
        FROM \\(SELECT "users".*
          FROM "users" .*
            AND "users"\\."deleted_at" IS NULL\\) bobs
          WHERE bobs\\."deleted_at" IS NULL
    SQL
  end

  it 'should allow for deep nesting with deleted_at scope being maintained' do
    inner_query = User.all.from(User.where(name: 'bob').from(Admin.where(name: 'john'), 'johns').as('johns')).as('bobs')
    sql = User.select(inner_query[:name]).from(inner_query).to_sql

    sql_regex = Regexp.new(<<~SQL.squish)
      SELECT bobs."name"
      FROM
        \\(SELECT "users".*
         FROM
           \\(SELECT "users".*
            FROM
              \\(SELECT "users"."id", "users"."kind" .*
                 AND "users"."deleted_at" IS NULL\\) johns .*
              AND johns."deleted_at" IS NULL\\) johns
         WHERE johns."deleted_at" IS NULL\\) bobs
      WHERE bobs."deleted_at" IS NULL
    SQL
    expect(sql).to match(sql_regex)
  end

end
