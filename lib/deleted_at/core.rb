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
      raise(DeletedAt::MissingColumnError, message)
    end

    def self.has_deleted_at_column?(klass)
      klass.columns.map(&:name).include?(klass.deleted_at.dig(:column).to_s)
    end

    def self.deleted_at_ready?(klass)
      !::DeletedAt.disabled? &&
      klass != ::ActiveRecord::Base &&
      !klass.abstract_class? &&
      klass.connected? &&
      klass.table_exists? &&
      !(klass < DeletedAt::ActiveRecord)
    end

    module ClassMethods

      def with_deleted_at(options={}, &block)
        self.deleted_at = DeletedAt::DEFAULT_OPTIONS.merge(options)
        self.deleted_at[:proc] = block if block_given?

        return unless Core.deleted_at_ready?(self)
        DeletedAt::Core.raise_missing(self) unless Core.has_deleted_at_column?(self)

        self.prepend(DeletedAt::ActiveRecord)
      end
    end # End ClassMethods

  end

end
