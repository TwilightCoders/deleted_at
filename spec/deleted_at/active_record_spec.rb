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

end
