class Post < ::ActiveRecord::Base
  with_deleted_at

  self.table_name = "documents"

  belongs_to :user
  has_many :comments
end
