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
        @with_deleted ||= Arel::Nodes::As.new(arel_table, User::All.where(User::All.arel_table[:deleted_at].not_eq(nil)).arel).freeze
      end

      def with_all
        nil
      end

      def with_present
        @with_present ||= Arel::Nodes::As.new(arel_table, User::All.where(User::All.arel_table[:deleted_at].eq(nil)).arel).freeze
      end

    end

  end

end
