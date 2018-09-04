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
        vanilla.dup.where(table[klass.deleted_at[:column]].not_eq(nil))
      when :Present
        vanilla.dup.where(table[klass.deleted_at[:column]].eq(nil))
      end
    end

    def vanilla
      # @vanilla ||= klass.const_get(:All).unscope(:where).freeze
      @vanilla ||= klass.unscoped.tap do |rel|
        rel.deleted_at_scope = :All
      end.freeze
    end

    # Rails 4.x
    def from_value
      if (subselect = deleted_at_select)
        [subselect, ::ActiveRecord::Base.connection.quote_table_name(table_name)]
      else
        super
      end
    end

    # Rails 5.x
    def from_clause
      if (subselect = deleted_at_select)
        ::ActiveRecord::Relation::FromClause.new(subselect, ::ActiveRecord::Base.connection.quote_table_name(table_name))
      else
        super
      end
    end

    def delete_all(*args)
      if args.pop
        ActiveSupport::Deprecation.warn(<<~STR)
          Passing conditions to delete_all is not supported in DeletedAt
          To achieve the same use where(conditions).delete_all.
        STR
      end
      update_all(klass.deleted_at_attributes)
    end
  end
end
