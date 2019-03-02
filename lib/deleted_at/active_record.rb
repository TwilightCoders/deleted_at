require 'active_record'
require 'deleted_at/relation'

module DeletedAt
  module ActiveRecord

    def self.prepended(subclass)
      subclass.init_deleted_at_relations
      # subclass.extend(ClassMethods)
      class << subclass
        prepend ClassMethods
      end
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

      def all_without_deleted_at(*args, scope: false)
        DeletedAt.scoped(scope) do
          super(*args)
          # .tap do |ar|
          #   puts "UNSCOPING"
          #   ar.unscope_deleted_at
          # end
        end
      end

      def reset_table_name
        @present_table = @all_table = @deleted_table = nil
        super
      end

      def present_table
        @present_table ||= DeletedAt::Table.new(table_name, self, shadow: "/present").freeze
      end

      def all_table
        @all_table ||= DeletedAt::Table.new(table_name, self, shadow: "/all").freeze
      end

      def deleted_table
        @deleted_table ||= DeletedAt::Table.new(table_name, self, shadow: "/deleted").freeze
      end

      # def arel_table_without_deleted_at
      #   DeletedAt::Core.registry[self] || superclass&.arel_table_without_deleted_at || superclass.arel_table
      # end

      def deleted_at_scope
        case DeletedAt.scope
        when :deleted, :all, :present
          send("#{DeletedAt.scope}_records")
        when false
          nil
        else
          present_records
        end
      end

      def all_records
        @all_records ||= DeletedAt.scoped(false) do
          Arel::Nodes::As.new(all_table, relation.arel).freeze
        end
      end

      def deleted_records
        @deleted_records ||= DeletedAt.scoped(false) do
          Arel::Nodes::As.new(deleted_table, relation.where(arel_table_without_deleted_at[:deleted_at].not_eq(nil)).arel).freeze
        end
      end

      def present_records
        @present_records ||= DeletedAt.scoped(false) do
          Arel::Nodes::As.new(present_table, relation.where(arel_table_without_deleted_at[:deleted_at].eq(nil)).arel).freeze
        end
      end

    end
  end
end
