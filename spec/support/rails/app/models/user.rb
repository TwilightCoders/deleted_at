class User < ::ActiveRecord::Base
  with_deleted_at

  has_many :posts, dependent: :destroy
  has_many :comments

  scope :admins, -> {
    # select(arel_table[Arel.star], arel_table[:tableoid])#
    where(kind: 1)
  }

  after_destroy :say_something

  def say_something
    # Doesn't need to do anything
  end

end
