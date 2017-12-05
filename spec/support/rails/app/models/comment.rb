class Comment < ::ActiveRecord::Base
  with_deleted_at

  belongs_to :user
  belongs_to :post
end
