
module DeletedAt
  module ActiveRecord
    # = Active Record Relation
    module Relation

      def deleted_at_attributes
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

      # Deletes the row with a primary key matching the +id+ argument, using a
      # SQL +DELETE+ statement, and returns the number of rows deleted. Active
      # Record objects are not instantiated, so the object's callbacks are not
      # executed, including any <tt>:dependent</tt> association options.
      #
      # You can delete multiple rows at once by passing an Array of <tt>id</tt>s.
      #
      # Note: Although it is often much faster than the alternative,
      # <tt>#destroy</tt>, skipping callbacks might bypass business logic in
      # your application that ensures referential integrity or performs other
      # essential jobs.
      #
      # ==== Examples
      #
      #   # Delete a single row
      #   Todo.delete(1)
      #
      #   # Delete multiple rows
      #   Todo.delete([2,3,4])
      def delete(id_or_array)
        where(primary_key => id_or_array).delete_all
      end

      # Destroy an object (or multiple objects) that has the given id. The object is instantiated first,
      # therefore all callbacks and filters are fired off before the object is deleted. This method is
      # less efficient than ActiveRecord#delete but allows cleanup methods and other actions to be run.
      #
      # This essentially finds the object (or multiple objects) with the given id, creates a new object
      # from the attributes, and then calls destroy on it.
      #
      # ==== Parameters
      #
      # * +id+ - Can be either an Integer or an Array of Integers.
      #
      # ==== Examples
      #
      #   # Destroy a single object
      #   Todo.destroy(1)
      #
      #   # Destroy multiple objects
      #   todos = [1,2,3]
      #   Todo.destroy(todos)
      def destroy(id)
        if id.is_a?(Array)
          id.map { |one_id| destroy(one_id) }
        else
          find(id).destroy
        end
      end
    end
  end
end
