module DeletedAt
  module Relation

    def self.prepended(subclass)
      subclass.class_eval do
        attr_writer :deleted_at_scope
        attr_reader :table_alias_name
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

    def as(other)
      @table_alias_name = Arel::Nodes::SqlLiteral.new(other)
      super
    end

    def table_name_literal
      table_alias_name || ::ActiveRecord::Base.connection.quote_table_name(table_name)
    end

    # Rails 4.x
    def from_value
      @table_alias_name ||= super&.first&.name
      if (subselect = deleted_at_select)
        [subselect, table_name_literal]
      else
        super
      end
    end

    # Rails 5.x
    def from_clause
      super_from_clause = super
      @table_alias_name ||= super_from_clause&.name || super_from_clause&.value&.right
      if (subselect = deleted_at_select)
        ::ActiveRecord::Relation::FromClause.new(subselect, table_name_literal)
      else
        super_from_clause
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
