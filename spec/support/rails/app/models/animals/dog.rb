module Animals
  class Dog < ::ActiveRecord::Base
    self.table_name = 'animal/dogs'
    with_deleted_at
  end
end
