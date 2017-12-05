class User < ::ActiveRecord::Base
  with_deleted_at

  has_many :posts
  has_many :comments

end
