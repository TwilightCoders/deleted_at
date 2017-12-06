class Comment < ::ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  self.primary_key = :id
end
