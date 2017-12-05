
module DeletedAt
  module ActiveRecord
    # = Active Record Relation
    module Relation

      def deleted_at_attributes
        # We _do_ have klass at this point
        { klass.deleted_at_column => Time.now.utc }
      end

      # Deletes the records matching +conditions+ without instantiating the records
      # first, and hence not calling the +destroy+ method nor invoking callbacks. This
      # is a single SQL DELETE statement that goes straight to the database, much more
      # efficient than +destroy_all+. Be careful with relations though, in particular
      # <tt>:dependent</tt> rules defined on associations are not honored. Returns the
      # number of rows affected.
      #
      #   Post.delete_all("person_id = 5 AND (category = 'Something' OR category = 'Else')")
      #   Post.delete_all(["person_id = ? AND (category = ? OR category = ?)", 5, 'Something', 'Else'])
      #   Post.where(person_id: 5).where(category: ['Something', 'Else']).delete_all
      #
      # Both calls delete the affected posts all at once with a single DELETE statement.
      # If you need to destroy dependent associations or call your <tt>before_*</tt> or
      # +after_destroy+ callbacks, use the +destroy_all+ method instead.
      #
      # If an invalid method is supplied, +delete_all+ raises an ActiveRecord error:
      #
      #   Post.limit(100).delete_all
      #   # => ActiveRecord::ActiveRecordError: delete_all doesn't support limit
      def delete_all(conditions = nil)
        if archive_with_deleted_at?
          where(conditions).update_all(deleted_at_attributes)
        else
          super
        end
      end
    end
  end
end
