ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, schema: :public, force: true do |t|
    t.string :name
    t.string :email, index: :btree
    t.integer :kind, default: 0
    t.timestamps null: false, deleted_at: true
  end

  create_table :documents, force: true do |t|
    t.integer :user_id
    t.string :title
    t.integer :scope
    t.timestamps null: false, deleted_at: true
  end

  create_table :comments, force: true do |t|
    t.string :title
    t.integer :user_id
    t.integer :post_id
    t.timestamps null: false
  end

end
