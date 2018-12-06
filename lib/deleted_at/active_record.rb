require 'active_record'
require 'deleted_at/relation'

module DeletedAt
  module ActiveRecord

    def self.prepended(subclass)
      subclass.init_deleted_at_relations
      subclass.extend(ClassMethods)
    end

    def initialize(*args)
      super
      @destroyed = !deleted_at.nil?
    end

    private

    module ClassMethods

      def inherited(subclass)
        super
        subclass.init_deleted_at_relations
      end

      def deleted_at?
        true
      end

      def with_deleted
        # binding.pry
        # const_get(:All).where(arel_table[:deleted_at].not_eq(nil))#.as('foo').to_sql
        # Arel::Nodes::As.new(Arel::Table.new(table_name), const_get(:All).where(arel_table[:deleted_at].not_eq(nil)))
        @with_deleted ||= Arel::Nodes::As.new(Arel::Table.new(table_name), arel_table.project(vanilla_deleted_at_projections).where(arel_table[:deleted_at].not_eq(nil))).freeze
      end

      def with_all
        @with_all ||= Arel::Nodes::As.new(Arel::Table.new(table_name), arel_table.project(vanilla_deleted_at_projections)).freeze
      end

      def with_present
        @with_present ||= Arel::Nodes::As.new(Arel::Table.new(table_name), arel_table.project(vanilla_deleted_at_projections).where(arel_table[:deleted_at].eq(nil))).freeze
      end

    end

  end

end
