class User < ::ActiveRecord::Base
  with_deleted_at

end

class Book < ::ActiveRecord::Base
  self.table_name = :documents

  with_deleted_at
end

module Animals
  class Dog < ::ActiveRecord::Base
    with_deleted_at
  end
end
