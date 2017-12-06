class Post < ::ActiveRecord::Base
  self.table_name = "documents"
  with_deleted_at

  belongs_to :user
  has_many :comments
end
