ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :email
    t.datetime :deleted_at
    t.timestamps null: false
  end
end
