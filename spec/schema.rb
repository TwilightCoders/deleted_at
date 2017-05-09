ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :email
    t.datetime :deleted_at
    t.timestamps null: false
  end

  create_table :documents, force: true do |t|
    t.string :title
    t.datetime :deleted_at
    t.timestamps null: false
  end

  create_table :dogs, force: true do |t|
    t.string :name
    t.datetime :deleted_at
    t.timestamps null: false
  end
end
