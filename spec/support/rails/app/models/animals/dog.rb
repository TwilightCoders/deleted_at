module Animals
  class Dog < ::ActiveRecord::Base
    with_deleted_at
  end
end
