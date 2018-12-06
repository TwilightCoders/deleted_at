module DeletedAt
  module Relation

    def self.prepended(subclass)
      subclass.class_eval do
        attr_writer :deleted_at_scope

        def deleted_at_tables
          @deleted_at_tables ||= Set.new
        end

        private

        def deleted_at_scope
          @deleted_at_scope
        end

      end

    end

    def build_arel(*args)
      # binding.pry
      super
    end

    # def from(val, name = nil)
    #   # binding.pry
    #   case val
    #   when Arel::Nodes::TableAlias
    #     val, name = val.left, name || val.right
    #   end
    #   super
    # end

    # def build_arel
    #   Thread.currently(:first_time, Thread.current[:first_time].nil?) do
    #     super.tap do |ar|
    #       if Thread.current[:first_time]
    #         deleted_at_tables.each do |table|
    #           if table.engine.deleted_at? && table.engine.deleted_scope
    #             ar.with(table.engine.deleted_scope)
    #           end
    #         end
    #       end
    #     end
    #   end

    #   # Thread.currently(:first_time, Thread.current[:first_time].nil?) do
    #   #   Thread.currently(:do_not_with, true) do
    #   #     super.tap do |ar|
    #   #       if !Thread.current[:do_not_with] || Thread.current[:first_time]
    #   #         case klass.deleted_at_type
    #   #         when :all
    #   #           # noop
    #   #         when :deleted
    #   #           ar.with(klass.with_deleted)
    #   #         else
    #   #           ar.with(klass.with_present)
    #   #         end
    #   #       end
    #   #     end
    #   #   end
    #   # end
    # end

    # def from!(value, subquery_name = nil) # :nodoc:
    #   case value
    #   when ::ActiveRecord::Relation
    #     deleted_at_tables + value.deleted_at_tables
    #     bind_values += value.bind_values if bind_values
    #   else
    #     find_tables(value, deleted_at_tables)
    #   end

    #   lift_withs(value) do
    #     super
    #   end
    # end

    # def merge!(other) # :nodoc:
    #   case other
    #   when ::ActiveRecord::Relation
    #     deleted_at_tables + other.deleted_at_tables
    #   else
    #     find_tables(other, deleted_at_tables)
    #   end

    #   lift_withs(other) do
    #     super
    #   end
    # end

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

    def find_tables(ast, collector = Set.new)
      case ast
      when Arel::Table
        collector << ast
      when Arel::Nodes::TableAlias
        find_tables(ast.left, collector)
      when Arel::Nodes::Grouping
        find_tables(ast.expr, collector)
      when Arel::Nodes::SelectStatement
        find_tables(ast.cores, collector) # or (ast.with and ast)
      when Arel::SelectManager
        find_tables(ast.ast, collector)
      when Arel::Attributes::Attribute
        find_tables(ast.relation, collector)
      when Arel::Nodes::SelectCore
        find_tables(ast.source, collector)
        find_tables(ast.projections, collector)
        find_tables(ast.wheres, collector)
      when Arel::Nodes::As
        find_tables(ast.right, collector)
      when Array
        ast.inject(collector) { |sum, a| sum += find_tables(a, sum) }
      end
      collector
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
