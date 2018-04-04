module DeletedAt #:nodoc:
  module TableDefinition

    def timestamps(**options)
      super
      column(:deleted_at, :datetime, options.merge(null: true)) if options[:deleted_at]
    end

  end
end
