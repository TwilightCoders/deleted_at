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

      def all_without_deleted_at
        DeletedAt.table_spoofing(false) do
          super
          # .tap do |ar|
          #   puts "UNSCOPING"
          #   ar.unscope_deleted_at
          # end
        end
      end

      def arel_table(spoof: false)
        if DeletedAt.table_spoofing? || spoof
          present_table
        else
          original_arel_table
        end
      end

      def all_records
        @all_records ||= DeletedAt.table_spoofing(false) do
          Arel::Nodes::As.new(all_table, relation.arel).freeze
        end
      end

      def only_deleted_records
        @only_deleted_records ||= DeletedAt.table_spoofing(false) do
          # binding.pry
          Arel::Nodes::As.new(deleted_table, relation.where(original_arel_table[:deleted_at].not_eq(nil)).arel).freeze
        end
      end

      def only_present_records
        @only_present_records ||= DeletedAt.table_spoofing(false) do
          Arel::Nodes::As.new(present_table, relation.where(original_arel_table[:deleted_at].eq(nil)).arel).freeze
        end
      end

      protected

      def original_arel_table
        DeletedAt::Core.registry[self] || superclass&.original_arel_table || superclass.arel_table
      end

    end

  end

end
