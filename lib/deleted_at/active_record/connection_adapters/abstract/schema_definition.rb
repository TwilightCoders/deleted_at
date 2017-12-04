module DeletedAt
  module ActiveRecord
    module ConnectionAdapters #:nodoc:
      module TableDefinition

        def timestamps(**options)
          options[:null] = false if options[:null].nil?

          column(:created_at, :datetime, options)
          column(:updated_at, :datetime, options)
          column(:deleted_at, :datetime, options.merge(null: true)) if options[:deleted_at]
        end

      end
    end
  end
end
