module DeletedAt
  module Relation

    def self.prepended(subclass)
      subclass.class_eval do
        attr_writer :deleted_at_scope
        attr_reader :subquery_name
        attr_reader :selecting_from_deleted_at
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
      else
        nil
      end
    end

    def build_deleted_at_from?
      [:Deleted, :Present].include?(deleted_at_scope)
    end

    def deleted_at_from
      deleted_at_select&.as(table_name_literal)
    end

    def vanilla
      @vanilla ||= klass.unscoped.tap do |rel|
        rel.deleted_at_scope = :All
      end.freeze
    end

    def set_subquery_name(value, subquery_name = nil)
      @subquery_name ||= subquery_name || if Arel::Nodes::SqlLiteral == value&.right
        value.right
      end
    end

    def table_name_literal
      subquery_name || ::ActiveRecord::Base.connection.quote_table_name(table_name)
    end

    if Rails.gem_version < Gem::Version.new('5.0')
      def from_value
        super || if (subselect = deleted_at_select)
          [subselect, table_name_literal]
        end
      end
    else
      def from_clause
        if !(super_from = super)&.empty?
          super_from
        elsif !Thread.current[:no_deleted_at_from] && build_deleted_at_from?
          Thread.currently(:no_deleted_at_from, true) do
            return ::ActiveRecord::Relation::FromClause.new(deleted_at_select, table_name_literal)
          end
        else
          super_from
        end
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
