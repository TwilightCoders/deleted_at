module DeletedAt
  module Relation

    def self.prepended(subclass)
      subclass.class_eval do
        attr_writer :deleted_at_scope
        attr_reader :table_alias_name
        attr_reader :external_from
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
      # @vanilla ||= klass.const_get(:All).unscope(:where).freeze
      @vanilla ||= klass.unscoped.tap do |rel|
        rel.deleted_at_scope = :All
      end.freeze
    end

    def table_name_literal
      # ::ActiveRecord::Base.connection.quote_table_name(table_name)
      @table_alias || Arel::Nodes::SqlLiteral.new(table_name)
    end

    # def build_arel(*args)
    #   super.tap do |built_arel|
    #     binding.pry
    #     Thread.currently(:default_from, false) do
    #       built_arel.from(build_from) if build_deleted_at_from?
    #     end
    #   end
    # end

    def from(*args)
      @external_from = true
      super
    end

    def build_from
        binding.pry
      super
      # if (external_from)
      #   super.tap do |super_from|
      #     Thread.currently(:default_from, false) do
      #       super_from.from(deleted_at_from) if build_deleted_at_from?
      #     end
      #   end
      # elsif(build_deleted_at_from?)
      #   Thread.currently(:default_from, false) do
      #     deleted_at_from
      #   end
      # else
      #   warn "How'd we get here"
      # end
    end

    def as(other)
      @table_alias_name = Arel::Nodes::SqlLiteral.new(other)
      super
    end

    def table_name_literal
      table_alias_name || ::ActiveRecord::Base.connection.quote_table_name(table_name)
    end

    if Rails.gem_version < Gem::Version.new('5.0')
      def from_value
        if external_from && (super_from = super)
          super_from
        elsif (subselect = deleted_at_select)
          [subselect, table_name_literal]
        end
      end

      # Meant to mimic the way ActiveRecord checks if it should build the from statement
      def build_from?
        !!from_value
      end
    else
      def from_clause
        if external_from && !(super_from = super).empty?
          super_from
        elsif (subselect = deleted_at_select)
          ::ActiveRecord::Relation::FromClause.new(subselect, table_name_literal)
        end
      end

      def build_from?
        from_clause.empty?
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
