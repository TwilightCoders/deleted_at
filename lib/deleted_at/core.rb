require 'deleted_at/active_record'

module DeletedAt

  module Core

    def self.prepended(subclass)
      class << subclass
        cattr_accessor :deleted_at
        self.deleted_at = {}
        alias all_without_deleted_at all
      end

      subclass.extend(ClassMethods)
    end

    def self.raise_missing(klass)
      message = "Missing `#{klass.deleted_at[:column]}` in `#{klass.name}` when trying to employ `deleted_at`"
      raise(DeletedAt::MissingColumn, message)
    end

    def self.has_deleted_at_column?(klass)
      klass.columns.map(&:name).include?(klass.deleted_at.dig(:column).to_s)
    end

    module ClassMethods

      def with_deleted_at(options={}, &block)
        self.deleted_at = DeletedAt::DEFAULT_OPTIONS.merge(options)
        self.deleted_at[:proc] = block if block_given?

        return if ::DeletedAt.disabled?

        DeletedAt::Core.raise_missing(self) unless Core.has_deleted_at_column?(self)

        self.prepend(DeletedAt::ActiveRecord)

      end

      def deleted_at_attributes
        attributes = {
          deleted_at[:column] => deleted_at[:proc].call
        }
      end

    end # End ClassMethods

  end

end
