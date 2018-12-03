require 'deleted_at/active_record'

module DeletedAt

  module Core

    def self.prepended(subclass)
      class << subclass
        cattr_accessor :deleted_at
        self.deleted_at = {}
      end

      subclass.extend(ClassMethods)
    end

    def self.raise_missing(klass)
      message = "Missing `#{klass.deleted_at[:column]}` in `#{klass.name}` when trying to employ `deleted_at`"
      raise(DeletedAt::MissingColumn, message)
    end

    def self.has_deleted_at_column?(klass)
      klass.columns.map(&:name).include?(klass.deleted_at_column.to_s)
    end

    module ClassMethods

      def with_deleted_at(options={}, &block)
        self.deleted_at = DeletedAt::DEFAULT_OPTIONS.merge(options)
        self.deleted_at[:proc] = block if block_given?

        # binding.pry
        return if ::DeletedAt.disabled? || !connected?

        DeletedAt::Core.raise_missing(self) unless Core.has_deleted_at_column?(self)

        self.prepend(DeletedAt::ActiveRecord)

        # default_scope { all.only_present }
      # Rescue so that we don't stop migrations from running.
      rescue ::ActiveRecord::StatementInvalid => e
      end

      def deleted_at_attributes
        attributes = {
          deleted_at[:column] => deleted_at[:proc].call
        }
      end

      def deleted_at_column
        deleted_at.dig(:column)
      end

      def with_deleted
        @with_deleted ||= Arel::Nodes::As.new(Arel::Table.new(table_name), arel_table.project(vanilla_deleted_at_projections).where(arel_table[:deleted_at].not_eq(nil))).freeze
      end

      def with_present
        @with_present ||= Arel::Nodes::As.new(Arel::Table.new(table_name), arel_table.project(vanilla_deleted_at_projections).where(arel_table[:deleted_at].eq(nil))).freeze
      end

      def vanilla_deleted_at_projections
        const_get(:All).projections
      end

      def init_deleted_at_relations
        instance_variable_get(:@relation_delegate_cache).each do |base, klass|
          klass.send(:prepend, DeletedAt::Relation)
        end
      end

    end # End ClassMethods

  end

end
