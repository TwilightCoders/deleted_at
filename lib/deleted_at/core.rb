require 'deleted_at/active_record'

module DeletedAt
  module Core

    def self.prepended(subclass)
      class << subclass
        cattr_accessor :deleted_at_column do
          nil
        end
      end
      subclass.extend(ClassMethods)
    end

    module ClassMethods

      def with_deleted_at(options={})

        # DeletedAt::ActiveRecord::Base.parse_options(self, options)
        self.deleted_at_column = (options.dig(:deleted_at, :column) || :deleted_at).to_s

        raise(DeletedAt::MissingColumn, "Missing `#{deleted_at_column}` in `#{name}` when trying to employ `deleted_at`") unless
            has_deleted_at_column?

        return if ::DeletedAt.disabled?

        self.prepend(DeletedAt::ActiveRecord)

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

  end

end
