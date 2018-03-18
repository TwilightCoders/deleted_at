require 'active_record'
require 'deleted_at/relation'

module DeletedAt
  module ActiveRecord
    module Base

      def self.prepended(subclass)
        class << subclass
          class_attribute :deleted_at_column
          self.deleted_at_column = nil
        end
        subclass.extend(ClassMethods)
      end

      module ClassMethods

        def with_deleted_at(options={})

          DeletedAt::ActiveRecord::Base.parse_options(self, options)

          return DeletedAt.logger.warn("Missing `#{deleted_at_column}` in `#{name}` when trying to employ `deleted_at`") unless
            has_deleted_at_column?

          present = const_get(:ActiveRecord_Relation).prepend(DeletedAt::Relation)

          define_singleton_method(:unfiltered_relation, method(:relation).unbind)

          define_singleton_method(:relation) do
            a = arel_table.project(arel_table[Arel.star]).where(arel_table[deleted_at_column].eq(nil))
            at = arel_table.create_table_alias(a, table_name)
            unfiltered_relation.from(at.to_sql)
          end

          define_singleton_method(:only_deleted) do
            a = arel_table.project(arel_table[Arel.star]).where(arel_table[deleted_at_column].not_eq(nil))
            at = arel_table.create_table_alias(a, table_name)
            unfiltered_relation.from(at.to_sql)
          end

          self.const_set(:All, self.unfiltered_relation)
          self.const_set(:Deleted, self.only_deleted)
        end

        def has_deleted_at_column?
          columns.map(&:name).include?(deleted_at_column)
        end

        def deleted_at_attributes
          attributes = {
            deleted_at_column => Time.now.utc
          }

          attributes
        end

      end # End ClassMethods

      def self.parse_options(model, options)
        model.deleted_at_column = (options.dig(:deleted_at, :column) || :deleted_at).to_s
      end

    end

  end
end
