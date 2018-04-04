module DeletedAt

  module Relation

    def self.prepended(subclass)
      subclass.class_eval do
        attr_writer :deleted_at_scope
      end
    end

    def deleted_at_scope
      @deleted_at_scope ||= :Present
    end

    def deleted_at_select
      scoped_arel = case deleted_at_scope
      when :Deleted
        table.where(table[deleted_at[:column]].not_eq(nil))
      when :Present
        table.where(table[deleted_at[:column]].eq(nil))
      end
    end


    def deleted_at_subselect(arel)
      if (subselect = deleted_at_select)
        subselect.project(arel_columns(columns.map(&:name)))
        Arel::Nodes::TableAlias.new(Arel::Nodes::Grouping.new(subselect.ast), table_name)
      end
    end

    def build_arel
      super.tap do |arel|
        if (subselect = deleted_at_subselect(arel)) && !arel.froms.include?(subselect)
          DeletedAt.logger.debug("DeletedAt sub-selecting from #{subselect.to_sql}")
          arel.from(subselect)
        end
      end
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
    def delete_all(*args)
      conditions = args.pop
      if conditions
        ActiveSupport::Deprecation.warn(<<-MESSAGE.squish)
          Passing conditions to delete_all is not supported in DeletedAt
          To achieve the same use where(conditions).delete_all.
        MESSAGE
      end
      update_all(klass.deleted_at_attributes)
    end
  end

end
