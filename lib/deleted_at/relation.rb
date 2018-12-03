module DeletedAt
  module Relation

    def self.prepended(subclass)
      subclass.class_eval do
        attr_writer :deleted_at_scope

        private

        def deleted_at_scope
          @deleted_at_scope
        end
      end
    end

    def build_arel
      if cte = deleted_at_subquery
        super.with(cte)
      else
        super
      end
    end

    def from!(value, subquery_name = nil) # :nodoc:
      lift_withs(value) do
        super
      end
    end

    def merge!(other) # :nodoc:
      lift_withs(other) do
        super
      end
    end

    def lift_withs(query)
      if (select_with = find_with(query)) && (withs = deleted_at_withs(select_with.with))
        remove_withs(select_with, *withs)
        yield.with(withs) if block_given?
      else
        yield if block_given?
      end
    end

    def deleted_at_withs(with)
      [klass.with_deleted, klass.with_present] & (with&.expr || [])
    end

    def remove_withs(select, *withs)
      puts "Removing #{withs.count}"
      select.with = (select.with.expr -= withs).any? ? select.with : nil
    end

    def find_with(obj)
      case obj
      when Arel::Nodes::TableAlias
        find_with(obj.left)
      when Arel::Nodes::Grouping
        find_with(obj.expr)
      when Arel::Nodes::SelectStatement
        find_with(obj.cores) or (obj.with and obj)
      when Arel::SelectManager
        find_with(obj.ast)
      when Arel::Nodes::SelectCore
        find_with(obj.source)
      when Arel::Nodes::As
        find_with(obj.right)
      when Array
        obj.find { |a| find_with(a) }
      else
        nil
      end
    end

    def deleted_at_subquery
      case deleted_at_scope
      when :Deleted
        klass.with_deleted
      when :Present, nil
        klass.with_present
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
