module DeletedAt
  module Relation

    def self.prepended(subclass)

    end

    def initialize(*args)
      super.tap do
        # We duplicate this because we may modify it inflight
        # but we don't want to infect the base class arel_table
        # @original_table = @table
        # @table = DeletedAt::Table.new(@table.name, @table.engine)
      end
    end

    def set_deleted_at(table, scope)
      @original_table = @table
      puts "Setting table: #{table.shadow}, scope: #{scope.to_sql}"
      # binding.pry if table.shadow == '/present'
      @table = table
      @deleted_at_scope = scope
    end

    def unscope_deleted_at
      puts "Unscoping DeletedAt"
      @table = @original_table || @table
      @deleted_at_scope = nil
    end

    # To mimic what would be delegated to a model class.
    def arel_table
      @table
    end


    def exec_queries
      Thread.currently(:selecting_deleted_at, true) do
        super
      end
      # @records = eager_loading? ? find_with_associations : @klass.find_by_sql(arel, arel.bind_values + bind_values)

      # preload = preload_values
      # preload +=  includes_values unless eager_loading?
      # preloader = build_preloader
      # preload.each do |associations|
      #   preloader.preload @records, associations
      # end

      # @records.each { |record| record.readonly! } if readonly_value

      # @loaded = true
      # @records
    end

    def build_arel(*args)
      # Thread.currently(:selecting_deleted_at, false) do |selecting_deleted_at_orig, selecting_deleted_at_curr|
        # if selecting_deleted_at_orig
        #   def table
        #     super.tap do |t|
        #       t.name = select_table_name
        #     end
        #   end
        # end

        super.tap do |ar|
          lift_withs(ar){ar}
          # puts "Attaching WITH: #{@table.shadow}, #{deleted_at_scope}"
          unless @deleted_at_scope.nil?
            puts @deleted_at_scope.to_sql
            ar.with(@deleted_at_scope)
          end
        end
        # ar.engine.table_name = select_table_name
        # if klass.deleted_scope
        #   puts "Adding #{klass.name} With:"
        #   puts klass.deleted_scope.to_sql
        #   ar.with(klass.deleted_scope)
        # end
      # end
    end

    def engage_deleted_at
      Thread.currently(:selecting_deleted_at, true) do
        yield if block_given?
      end
    end

    def exec_queries(*args)
      engage_deleted_at do
        super
      end
    end

    def to_sql(*args)
      engage_deleted_at do
        super
      end
    end

    def from!(value, subquery_name = nil) # :nodoc:
      super.tap do |ar|
        lift_withs(value) do
          ar
        end
      end
    end

    def merge!(other) # :nodoc:
      # binding.pry
      # lift_withs(other) do
      #   binding.pry
      #   super
      # end
      # binding.pry
      super.tap do |ar|
        # binding.pry
        lift_withs(other) do
          ar
        end
      end

      # lift_withs(other) do
      #   self
      # end
      # super
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
      [klass.all_records, klass.only_deleted_records, klass.only_present_records] & (with&.expr || [])
    end

    def remove_withs(select, *withs)
      puts "Removing #{withs.count}"
      select.with = (select.with.expr -= withs).any? ? select.with : nil
    end

    def find_with(obj)
      case obj
      when ::ActiveRecord::Relation
        find_with(obj.ast)
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
